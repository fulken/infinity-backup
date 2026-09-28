/**
 * RuntimeHook.h  (UEFI side)  —  v6
 * =================================================================
 * Hook EFI_RUNTIME_SERVICES->GetTime / GetVariable / SetVariable to
 * keep the polling loop alive after ExitBootServices, and to give
 * Windows a driver-less way to talk to the bridge (InfinityReq /
 * InfinityResp / InfinityData variables are serviced here).
 *
 * v6 changes vs baseline (a8e41b3):
 *   - Hooks are installed from the EVT_SIGNAL_VIRTUAL_ADDRESS_CHANGE
 *     event (InstallVirtual), NOT at ExitBootServices time. The old
 *     EBS-time install is what hung the Linux test VM: it wrote raw
 *     physical hook addresses into gRT AFTER the firmware had already
 *     converted the table, so the slots were never converted.
 *     Installing DURING the event (before the firmware converts the
 *     slots — "order B") lets the firmware convert our hook addresses
 *     for us; the sandbox forensics verified the final table state.
 *   - The saved original service pointers are converted to virtual
 *     via ConvertPointer (ConvertSelf), so chaining works post-boot.
 *   - Every hook entry serial-traces (first calls) and updates the
 *     INFDIAG stage-4 / hook_calls counters.
 *   - INFINITY_ENABLE_RUNTIME_HOOKS gates ALL hook installation.
 *     Without it (SAFE build) this class never touches gRT.
 * =================================================================
 */
#pragma once

#ifdef __cplusplus
extern "C" {
#endif
#include <efi.h>
#include <efilib.h>
#ifdef __cplusplus
}
#endif

#include <cstdint>

#include "SerialTrace.h"
#include "Diag.h"
#include "RequestHandler.h"

namespace UEFIBridge {

    static inline UINT32 ComputeCrc32(const void* data, UINTN size) {
        const UINT8* p = (const UINT8*)data;
        UINT32 crc = 0xFFFFFFFF;
        for (UINTN i = 0; i < size; i++) {
            crc ^= p[i];
            for (int j = 0; j < 8; j++) {
                crc = (crc >> 1) ^ (0xEDB88320u & -(crc & 1));
            }
        }
        return ~crc;
    }

    // v15: live KUSD build capture, shared by the INFDIAG serve
    // path and HandleOurSetVariable. Runs ONCE per boot: probes
    // both candidate NtBuildNumber offsets, traces the RAW values
    // (hex prints are VA-safe now — v15 fixed the SerialTrace hex
    // table), and takes the first plausible one. VA-gated: boot
    // contexts run on firmware page tables which do not map the
    // high-canonical KUSD VA.
    static void CaptureLiveWindowsBuild() {
        if (!g_diag_va_done) return;
        if (g_diag_win_build || g_kusd_probe_done) return;
        g_kusd_probe_done = 1;
        UINT32 p260 = *(volatile UINT32*)
            (KUSER_SHARED_DATA_VA + KUSD_OFS_BUILD_CANDIDATES[0])
            & 0x7FFFFFFF;
        UINT32 p308 = *(volatile UINT32*)
            (KUSER_SHARED_DATA_VA + KUSD_OFS_BUILD_CANDIDATES[1])
            & 0x7FFFFFFF;
        // v16 cosmetic: KV() appends "=0x" itself - the v15 labels
        // also ended in "=0x", producing the double prefix
        // "kusd raw 0x260=0x=0x..." in the v15 serial log.
        SerialTrace::KV("BLD", "kusd raw 0x260", p260);
        SerialTrace::KV("BLD", "kusd raw 0x308", p308);
        if (KusdBuildPlausible(p260)) {
            g_diag_win_build = p260;
            SerialTrace::KVD("BLD", "live windows build (ofs 0x260)",
                            (UINT64)p260);
        } else if (KusdBuildPlausible(p308)) {
            g_diag_win_build = p308;
            SerialTrace::KVD("BLD", "live windows build (ofs 0x308)",
                            (UINT64)p308);
        } else {
            SerialTrace::Line("BLD",
                "kusd both implausible - build stays 0 "
                "(script side authoritative)");
        }
    }

    // EVT_SIGNAL_VIRTUAL_ADDRESS_CHANGE GUID
    static EFI_GUID gEfiEventVirtualAddressChangeGuid = {
        0x13fa7698, 0xc831, 0x49c7,
        { 0x87, 0xea, 0x8f, 0x43, 0xfc, 0xc2, 0x51, 0x96 }
    };

    class RuntimeHook {
    public:
        RuntimeHook() = default;

#ifdef INFINITY_ENABLE_RUNTIME_HOOKS

        // =============================================================
        // v7: InstallEarly — install the gRT hooks IMMEDIATELY at driver
        // load time (EFI Shell context), long before the OS loader runs.
        //
        // WHY (the v6 phase-D finding): Windows does NOT call the
        // firmware's live post-SVAM runtime table. winload snapshots
        // the runtime services it needs BEFORE calling
        // SetVirtualAddressMap and translates that snapshot itself with
        // the same virtual map. Hooks dropped into gRT during the
        // VA-change event (v6) land AFTER the snapshot was taken and are
        // therefore invisible to the OS. Evidence: user's v6 run read
        // INFDIAG from inside Windows (GetFirmwareEnvironmentVariable
        // succeeded through OVMF's original GetVariable) while zero
        // hook entries were traced and stage never moved past 3.
        //
        // Installing at load time puts our hook addresses into the
        // table BEFORE bootmgr/winload ever touch it: their snapshot
        // then contains OUR pointers. Both translation paths agree on
        // the final address (the VA map is the same one passed to
        // SVAM), so the OS lands in our hooks either way. Linux, which
        // does use the live converted table, also keeps working — the
        // slots are converted by the firmware exactly as before.
        //
        // Boot-context safety: between load and SVAM every firmware
        // variable call (shell, bootmgr, winload) passes through our
        // hooks at PHYSICAL addresses. The hooks only chain to the
        // saved originals (also physical) plus port-I/O tracing — the
        // same class of code as the EBS hook, which has been running
        // at physical context since phase C. HookEnter() treats these
        // calls as passthroughs (traced, never touching the stage
        // ladder) while g_diag_va_done == 0.
        // =============================================================
        void InstallEarly() {
            instance_ = this; // handler_ was set via SetHandler just before

            // Save originals BEFORE replacing (OVMF's own physical
            // services — still pristine at load time).
            orig_get_time_          = gRT->GetTime;
            orig_get_variable_      = gRT->GetVariable;
            orig_set_variable_      = gRT->SetVariable;
            orig_get_next_variable_ = gRT->GetNextVariableName;
            orig_set_wakeup_        = gRT->SetWakeupTime;

            SerialTrace::KV("RT-EARLY", "orig GetTime        ", (UINT64)orig_get_time_);
            SerialTrace::KV("RT-EARLY", "orig GetVariable    ", (UINT64)orig_get_variable_);
            SerialTrace::KV("RT-EARLY", "orig SetVariable    ", (UINT64)orig_set_variable_);

            // Install hooks into the live table now.
            gRT->GetTime     = &RuntimeHook::HookedGetTime;
            gRT->GetVariable = &RuntimeHook::HookedGetVariable;
            gRT->SetVariable = &RuntimeHook::HookedSetVariable;

            SerialTrace::KV("RT-EARLY", "hook GetTime        ", (UINT64)gRT->GetTime);
            SerialTrace::KV("RT-EARLY", "hook GetVariable    ", (UINT64)gRT->GetVariable);
            SerialTrace::KV("RT-EARLY", "hook SetVariable    ", (UINT64)gRT->SetVariable);

            gRT->Hdr.CRC32 = 0;
            gRT->Hdr.CRC32 = ComputeCrc32(gRT, gRT->Hdr.HeaderSize);

            installed_ = TRUE;
            DiagSetFlag(kDiagFlagEarlyHooks);
            SerialTrace::Line("RT-EARLY", "memory.efi v27 RT (kernel data path: direct reads + exports + walk + pte-space chain A)");
            SerialTrace::Line("RT-EARLY", "gRT hooks INSTALLED at load time (pre-snapshot; Windows-visible)");
        }

        // Called from the VA-change event handler, while the gRT slots
        // still hold PHYSICAL addresses (order B). The firmware will
        // convert whatever we leave in the slots right after the event.
        // v7: with InstallEarly() the hooks are ALREADY in the slots —
        // this becomes a no-op that must NOT overwrite them (the
        // originals were saved at load; re-saving here would save OUR
        // OWN hook pointers as "originals" — infinite recursion).
        void InstallVirtual() {
            if (installed_) {
                SerialTrace::Line("RT-VA", "hooks already installed at load (v27 early) - keeping slots");
                return;
            }

            instance_ = this; // handler_ was set via SetHandler at load time

            // Save originals BEFORE replacing (physical values).
            orig_get_time_          = gRT->GetTime;
            orig_get_variable_      = gRT->GetVariable;
            orig_set_variable_      = gRT->SetVariable;
            orig_get_next_variable_ = gRT->GetNextVariableName;
            orig_set_wakeup_        = gRT->SetWakeupTime;

            SerialTrace::KV("RT", "orig GetTime        ", (UINT64)orig_get_time_);
            SerialTrace::KV("RT", "orig GetVariable    ", (UINT64)orig_get_variable_);
            SerialTrace::KV("RT", "orig SetVariable    ", (UINT64)orig_set_variable_);

            // Install hooks. Only services we know the production
            // client can trigger (user-mode firmware variable APIs
            // reach GetVariable/SetVariable; the kernel time init may
            // reach GetTime).
            gRT->GetTime     = &RuntimeHook::HookedGetTime;
            gRT->GetVariable = &RuntimeHook::HookedGetVariable;
            gRT->SetVariable = &RuntimeHook::HookedSetVariable;

            SerialTrace::KV("RT", "hook GetTime        ", (UINT64)gRT->GetTime);
            SerialTrace::KV("RT", "hook GetVariable    ", (UINT64)gRT->GetVariable);
            SerialTrace::KV("RT", "hook SetVariable    ", (UINT64)gRT->SetVariable);

            // The table header CRC only covers the header, but keep the
            // refresh for parity with the checked-in baseline.
            gRT->Hdr.CRC32 = 0;
            gRT->Hdr.CRC32 = ComputeCrc32(gRT, gRT->Hdr.HeaderSize);

            installed_ = TRUE;
            SerialTrace::Line("RT", "gRT hooks INSTALLED (physical; firmware converts slots next)");
        }
#endif // INFINITY_ENABLE_RUNTIME_HOOKS

        void SetHandler(RequestHandler* handler) {
            handler_ = handler;
        }

        // Convert runtime-assigned pointers to virtual. Called from
        // ConvertPointersAll() after InstallVirtual().
        void ConvertSelf(EFI_CONVERT_POINTER cvt) {
            CvtOne(cvt, (VOID**)&handler_,                "RT.handler_");
#ifdef INFINITY_ENABLE_RUNTIME_HOOKS
            CvtOne(cvt, (VOID**)&orig_get_time_,          "RT.orig_get_time_");
            CvtOne(cvt, (VOID**)&orig_get_variable_,      "RT.orig_get_variable_");
            CvtOne(cvt, (VOID**)&orig_set_variable_,      "RT.orig_set_variable_");
            CvtOne(cvt, (VOID**)&orig_get_next_variable_, "RT.orig_get_next_");
            CvtOne(cvt, (VOID**)&orig_set_wakeup_,        "RT.orig_set_wakeup_");
#endif
        }

        void Uninstall() {
            if (!installed_) return;
            gRT->GetTime     = orig_get_time_;
            gRT->GetVariable = orig_get_variable_;
            gRT->SetVariable = orig_set_variable_;
            gRT->Hdr.CRC32 = 0;
            gRT->Hdr.CRC32 = ComputeCrc32(gRT, gRT->Hdr.HeaderSize);
            installed_ = FALSE;
        }

        void ProcessPending() {
            if (!handler_) return;
            // Re-entry guard: don't process if we're already inside
            // ProcessPendingRequests (a hooked service calling another
            // hooked service must not recurse).
            if (in_process_) return;
            in_process_ = TRUE;
            handler_->ProcessPendingRequests();
            in_process_ = FALSE;
        }

        // =========================================================
        // Hooked runtime services.
        // These run at their VIRTUAL addresses in Windows kernel
        // context: only port I/O, our converted pointers, and the
        // converted original services may be used.
        // =================================================================
        static EFI_STATUS EFIAPI HookedGetTime(
            EFI_TIME* time, EFI_TIME_CAPABILITIES* caps) {

            HookEnter('T');
            if (instance_) {
                instance_->ProcessPending();
                if (instance_->orig_get_time_) {
                    EFI_STATUS s = instance_->orig_get_time_(time, caps);
                    HookChainResult('T', s);
                    return s;
                }
            }
            HookChainResult('T', (UINT64)EFI_UNSUPPORTED);
            return EFI_UNSUPPORTED;
        }

        static EFI_STATUS EFIAPI HookedGetVariable(
            CHAR16* var_name, EFI_GUID* vendor_guid,
            UINT32* attrs, UINTN* data_size, VOID* data) {

            HookEnter('G');

            // v13 READ-PATH OBSERVABILITY, SAFE: INFDIAG and INFCNT
            // reads are answered from LIVE RAM state. v12's freshen
            // (an NVRAM write from inside the GetVariable dispatch)
            // crashed the kernel at desktop time (KMODE_EXCEPTION,
            // 2026-09-20 report) — v13 hooks NEVER call the original
            // SetVariable at runtime. GUID-checked and gated on
            // virtual mode so boot-time reads (shell dmpstore in
            // phase-b-check) keep their old chain-to-NVRAM
            // semantics.
            if (g_diag_va_done && instance_ && var_name &&
                vendor_guid &&
                // v14 F1: gnu-efi CompareGuid is memcmp-like:
                // it returns 0 when the GUIDs are EQUAL. The
                // v13 '== TRUE' made this gate FALSE for every
                // MATCHING GUID — the RAM serve was dead code
                // and all desktop reads chained to stale NVRAM
                // (that is why A..F all read 251 and INFCNT
                // read 203 in the v13 run).
                CompareGuid(vendor_guid, &gInfinityMemVarGuid) == 0) {
                if (StrCmp(var_name, (CHAR16*)L"INFDIAG") == 0) {
                    SerialTrace::Line("HOOK", "G INFDIAG live");
                    // v15: shared once-per-boot probe (VA-gated,
                    // both candidate offsets, raw forensics trace).
                    CaptureLiveWindowsBuild();
                    InfinityDiag d;
                    d.magic       = 0x494E4644;
                    d.stage       = g_diag_stage;
                    d.flags       = g_diag_flags;
                    d.win_build   = g_diag_win_build;
                    d.os_cr3      = g_diag_os_cr3;
                    d.hook_calls  = g_diag_hook_calls;
                    d.last_status = g_diag_last_status;
                    if (!data_size) return EFI_INVALID_PARAMETER;
                    if (!data || *data_size < sizeof(d)) {
                        *data_size = sizeof(d);
                        return EFI_BUFFER_TOO_SMALL;
                    }
                    if (attrs) *attrs = EFI_VARIABLE_NON_VOLATILE |
                                        EFI_VARIABLE_BOOTSERVICE_ACCESS |
                                        EFI_VARIABLE_RUNTIME_ACCESS;
                    CopyMem(data, &d, sizeof(d));
                    *data_size = sizeof(d);
                    return EFI_SUCCESS;
                }
                if (StrCmp(var_name, (CHAR16*)L"INFCNT") == 0) {
                    SerialTrace::Line("HOOK", "G INFCNT live");
                    UINT32 v = g_diag_req_count;
                    if (!data_size) return EFI_INVALID_PARAMETER;
                    if (!data || *data_size < sizeof(v)) {
                        *data_size = sizeof(v);
                        return EFI_BUFFER_TOO_SMALL;
                    }
                    if (attrs) *attrs = EFI_VARIABLE_NON_VOLATILE |
                                        EFI_VARIABLE_BOOTSERVICE_ACCESS |
                                        EFI_VARIABLE_RUNTIME_ACCESS;
                    CopyMem(data, &v, sizeof(v));
                    *data_size = sizeof(v);
                    return EFI_SUCCESS;
                }
            }

            if (instance_ && instance_->IsOurVariable(var_name, vendor_guid)) {
                // v13: our-namespace reads are rare (only the
                // test script issues them) — trace every one,
                // unbounded.
                SerialTrace::Line("HOOK", "G OURVAR read");
                EFI_STATUS s = instance_->HandleOurGetVariable(
                    var_name, attrs, data_size, data);
                HookChainResult('G', s);
                return s;
            }

            if (instance_) {
                instance_->ProcessPending();
                if (instance_->orig_get_variable_) {
                    EFI_STATUS s = instance_->orig_get_variable_(
                        var_name, vendor_guid, attrs, data_size, data);
                    HookChainResult('G', s);
                    return s;
                }
            }
            HookChainResult('G', (UINT64)EFI_UNSUPPORTED);
            return EFI_UNSUPPORTED;
        }

        static EFI_STATUS EFIAPI HookedSetVariable(
            CHAR16* var_name, EFI_GUID* vendor_guid,
            UINT32 attrs, UINTN data_size, VOID* data) {

            // Re-entrancy guard: our own DiagWrite() arrives here (it
            // calls gRT->SetVariable). Service it through the ORIGINAL
            // only — no bookkeeping, no stage bump, no recursion.
            if (g_diag_busy) {
                if (instance_ && instance_->orig_set_variable_) {
                    return instance_->orig_set_variable_(
                        var_name, vendor_guid, attrs, data_size, data);
                }
                return EFI_UNSUPPORTED;
            }

            HookEnter('S');
            if (instance_ && instance_->IsOurVariable(var_name, vendor_guid)) {
                // v13 WRITE-PATH ATTRIBUTION, RAM-ONLY: trace the
                // call, set the trigger flag, bump the live
                // counter. NEVER call the original SetVariable
                // from inside a hook at runtime (the v12 freshen
                // BSOD) — the counter is observable through the
                // RAM-served INFCNT read in HookedGetVariable.
                SerialTrace::Line("HOOK",
                    (data && data_size > 0) ?
                        "S OURVAR write" : "S OURVAR delete");
                // v14 F3: the 0x20 trigger flag is now WRITE-
                // gated — the v13 code also set it for deletes
                // ([CLR] would have faked a positive).
                if (data && data_size > 0) {
                    DiagSetFlag(kDiagFlagTriggerSeen);
                    if (g_diag_va_done) {
                        g_diag_req_count++;
                    }
                }
                EFI_STATUS s = instance_->HandleOurSetVariable(
                    var_name, attrs, data_size, data);
                // v14 F3: ALSO chain to the original so the write
                // lands in NVRAM (dual write: RAM handling + raw
                // landing). This exact path — desktop SetVariable
                // -> this hook -> orig SetVariable -> flash — ran
                // incidentally and safely three times in the v13
                // run (INFPROBE/INFTRIGGER/InfinityReq landed,
                // Win32=0, no crash), so it is NOT the v12 BSOD
                // class (that was orig-SetVariable called from
                // inside the GETVARIABLE dispatch). Windows sees
                // the NVRAM result, which is what read-back sees.
                // The production pool transport drops this chain.
                if (instance_->orig_set_variable_) {
                    EFI_STATUS s2 = instance_->orig_set_variable_(
                        var_name, vendor_guid, attrs, data_size, data);
                    HookChainResult('S', s2);
                    return s2;
                }
                HookChainResult('S', s);
                return s;
            }

            if (instance_) {
                instance_->ProcessPending();
                if (instance_->orig_set_variable_) {
                    EFI_STATUS s = instance_->orig_set_variable_(
                        var_name, vendor_guid, attrs, data_size, data);
                    HookChainResult('S', s);
                    return s;
                }
            }
            HookChainResult('S', (UINT64)EFI_UNSUPPORTED);
            return EFI_UNSUPPORTED;
        }

    private:
        // Serial trace on hook entry. Bounded: the first 8 calls of a
        // boot are traced in full, after that only every 64th call, so
        // a busy production session can not flood the serial log.
        static void HookEnter(char service) {
            // v13: ONE cumulative counter from driver load (v8
            // binary evidence: trace numbers ran continuously
            // across the virtual-mode boundary; INFDIAG at the VA
            // event already carried all boot-context calls).
            // Boot-context calls are still TRACED as BOOT-CTX
            // (never touching the stage ladder) but also advance
            // the counter, so the desktop can observe total
            // traffic through the RAM-served INFDIAG read.
            UINT32 n = ++g_diag_hook_calls;
            if (!g_diag_va_done) {
                if (n <= 8 || (n & 63) == 0) {
                    SerialTrace::Begin("HOOK");
                    SerialTrace::Putc(service);
                    SerialTrace::Puts(" BOOT-CTX call#");
                    SerialTrace::Dec(n);
                }
                return;
            }

            bool first = (g_diag_stage != kDiagStageHookCalled);
            if (first) {
                g_diag_stage = kDiagStageHookCalled;
            }
            if (n <= 8 || (n & 63) == 0) {
                SerialTrace::Begin("HOOK");
                SerialTrace::Putc(service);
                SerialTrace::Puts(" call#");
                SerialTrace::Dec(n);
                if (first) SerialTrace::Puts(" FIRST");
                SerialTrace::Puts(" VIRT");
            }
            // v13: NO DiagWrite here — hooks NEVER call the
            // original SetVariable at runtime. Live state is
            // served from RAM instead (see HookedGetVariable).
        }

        static void HookChainResult(char service, UINT64 status) {
            // Chained-status traces are rare (only very early calls).
            UINT32 n = g_diag_va_done ? g_diag_hook_calls : g_diag_boot_calls;
            if (n <= 8) {
                SerialTrace::Begin("HOOK");
                SerialTrace::Putc(service);
                SerialTrace::Puts(" chained st=0x");
                SerialTrace::Hex32((UINT32)status);
            }
        }

        BOOLEAN IsOurVariable(CHAR16* name, EFI_GUID* guid) {
            if (!name) return FALSE;
            static EFI_GUID kOurGuid = {
                0xA1B2C3D4, 0xE5F6, 0x4789,
                { 0x9A, 0xBC, 0xDE, 0xF0, 0x12, 0x34, 0x56, 0x78 }
            };
            if (guid) {
                // v14 F1: same memcmp-like semantics — 0 means
                // EQUAL. The base-repo '!= TRUE' rejected every
                // MATCHING GUID, so our own variables were never
                // classified as ours: reads chained to NVRAM,
                // writes chained to NVRAM, no traces, no counts.
                // Latent since a8e41b3; it faked 'write bypass'
                // across v9..v13.
                if (CompareGuid(guid, &kOurGuid) != 0) return FALSE;
            }
            if (StrCmp(name, (CHAR16*)L"InfinityReq")  == 0) return TRUE;
            if (StrCmp(name, (CHAR16*)L"InfinityResp") == 0) return TRUE;
            if (StrCmp(name, (CHAR16*)L"InfinityData") == 0) return TRUE;
            // v13: INFTRIGGER is also ours (script trigger probe).
            // INFDIAG / INFCNT are deliberately NOT ours: their
            // READS are served live from RAM earlier in
            // HookedGetVariable, and their SET path must chain to
            // the original so raw NVRAM landing keeps working.
            if (StrCmp(name, (CHAR16*)L"INFTRIGGER")  == 0) return TRUE;
            return FALSE;
        }

        EFI_STATUS HandleOurGetVariable(
            CHAR16* var_name, UINT32* attrs,
            UINTN* data_size, VOID* data) {

            if (!data_size) return EFI_INVALID_PARAMETER;

            if (StrCmp(var_name, (CHAR16*)L"InfinityResp") == 0) {
                if (*data_size < last_resp_size_) {
                    *data_size = last_resp_size_;
                    return EFI_BUFFER_TOO_SMALL;
                }
                if (data == nullptr && last_resp_size_ > 0) {
                    return EFI_INVALID_PARAMETER;
                }
                if (attrs) *attrs = EFI_VARIABLE_NON_VOLATILE |
                                    EFI_VARIABLE_BOOTSERVICE_ACCESS |
                                    EFI_VARIABLE_RUNTIME_ACCESS;
                if (data) CopyMem(data, last_resp_, last_resp_size_);
                *data_size = last_resp_size_;
                return EFI_SUCCESS;
            }
            if (StrCmp(var_name, (CHAR16*)L"InfinityData") == 0) {
                if (*data_size < last_data_size_) {
                    *data_size = last_data_size_;
                    return EFI_BUFFER_TOO_SMALL;
                }
                if (data == nullptr && last_data_size_ > 0) {
                    return EFI_INVALID_PARAMETER;
                }
                if (attrs) *attrs = EFI_VARIABLE_NON_VOLATILE |
                                    EFI_VARIABLE_BOOTSERVICE_ACCESS |
                                    EFI_VARIABLE_RUNTIME_ACCESS;
                if (data) CopyMem(data, last_data_, last_data_size_);
                *data_size = last_data_size_;
                return EFI_SUCCESS;
            }
            return EFI_NOT_FOUND;
        }

        EFI_STATUS HandleOurSetVariable(
            CHAR16* var_name, UINT32 attrs,
            UINTN data_size, VOID* data) {

            // v15: same shared probe (VA-gated internally, so
            // boot-time our-var writes can not touch the OS KUSD
            // mapping either).
            CaptureLiveWindowsBuild();

            if (StrCmp(var_name, (CHAR16*)L"InfinityReq") == 0) {
                if (!data || data_size < sizeof(EfiVarReq)) {
                    return EFI_INVALID_PARAMETER;
                }
                EfiVarReq* req = (EfiVarReq*)data;
                if (handler_) {
                    handler_->ProcessSingleVariableRequest(req, last_resp_, last_data_, &last_data_size_);
                }
                last_resp_size_ = sizeof(EfiVarResp);
                return EFI_SUCCESS;
            }
            if (StrCmp(var_name, (CHAR16*)L"InfinityData") == 0) {
                if (!data) {
                    return EFI_INVALID_PARAMETER;
                }
                if (data_size > sizeof(last_data_)) {
                    return EFI_BAD_BUFFER_SIZE;
                }
                CopyMem(last_data_, data, data_size);
                last_data_size_ = data_size;
                return EFI_SUCCESS;
            }

            // v13: INFTRIGGER — the script's trigger probe. The
            // trigger flag and counter were already set by the
            // caller (HookedSetVariable); accept the write and
            // store nothing.
            if (StrCmp(var_name, (CHAR16*)L"INFTRIGGER") == 0) {
                if (!data || data_size < 1) {
                    return EFI_INVALID_PARAMETER;
                }
                return EFI_SUCCESS;
            }

            return EFI_NOT_FOUND;
        }

        struct EfiVarReq {
            UINT32 sequence;
            UINT32 op;
            UINT32 pid;
            UINT32 data_size;
            UINT64 address;
            UINT64 alloc_size;
            UINT32 protect;
            UINT32 timeout_ms;
            UINT32 status;
            UINT32 crc32;
        };
        struct EfiVarResp {
            UINT32 sequence;
            UINT32 status;
            UINT64 bytes_transferred;
            UINT64 out_address;
            UINT32 old_protect;
            UINT32 crc32;
        };

        RequestHandler* handler_ = nullptr;
        EFI_GET_TIME           orig_get_time_        = nullptr;
        EFI_GET_VARIABLE       orig_get_variable_    = nullptr;
        EFI_SET_VARIABLE       orig_set_variable_    = nullptr;
        EFI_GET_NEXT_VARIABLE_NAME orig_get_next_variable_ = nullptr;
        EFI_SET_WAKEUP_TIME    orig_set_wakeup_      = nullptr;
        BOOLEAN installed_ = FALSE;
        BOOLEAN in_process_ = FALSE;  // Re-entry guard.

        UINT8  last_resp_[64];
        UINTN  last_resp_size_ = 0;
        UINT8  last_data_[4096];
        UINTN  last_data_size_ = 0;

    public:
        static RuntimeHook* instance_;
    };

    inline RuntimeHook* RuntimeHook::instance_ = nullptr;

} // namespace UEFIBridge
