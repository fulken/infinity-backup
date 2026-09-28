/**
 * Diag.h  (UEFI side)  —  INFDIAG v6
 * =================================================================
 * The INFDIAG non-volatile variable under our vendor GUID
 * {A1B2C3D4-E5F6-4789-9ABC-DEF012345678}. Size is EXACTLY 32 bytes
 * (dmpstore shows DataSize = 0x20).
 *
 * Stage ladder (same semantics as v5):
 *   1 = driver loaded OK (pool + request handler + EBS hook installed)
 *   2 = ExitBootServices FIRED  (os_cr3 + win_build captured)
 *   3 = RT build: gRT hooks installed at SetVirtualAddressMap event
 *   4 = RT build: Windows CALLED a hooked service (full chain)
 *
 * Field layout (little endian):
 *   0x00 u32 magic       'DFNI' bytes 44 46 4E 49  (0x494E4644)
 *   0x04 u32 stage       see ladder above
 *   0x08 u32 flags       bit0=loaded bit1=EBS fired bit2=virtual mode
 *                        bit3=RT hooks installed EARLY at load (v7)
 *   0x0C u32 win_build   NtBuildNumber from KUSER_SHARED_DATA, 0=unknown
 *   0x10 u64 os_cr3      CR3 captured at ExitBootServices
 *   0x18 u32 hook_calls  hooked-service calls serviced AFTER virtual
 *                        mode began (v7: boot-context passthrough calls
 *                        are counted separately and only traced)
 *   0x1C u32 last_status EFI_STATUS of the last INFDIAG SetVariable
 *
 * v6 addition: last_status. v5 proved that post-virtual NVRAM writes
 * can silently fail (stage 3 was the last successful write); with
 * last_status + the serial traces we can see the exact error code.
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

namespace UEFIBridge {

// Defined in main.c (inside this namespace — R3 fix).
extern EFI_GUID gInfinityMemVarGuid;

#pragma pack(push, 1)
struct InfinityDiag {
    UINT32 magic;
    UINT32 stage;
    UINT32 flags;
    UINT32 win_build;
    UINT64 os_cr3;
    UINT32 hook_calls;
    UINT32 last_status;
};
#pragma pack(pop)

static_assert(sizeof(InfinityDiag) == 32, "INFDIAG must remain exactly 32 bytes");

enum : UINT32 {
    kDiagStageLoaded         = 1,
    kDiagStageEbsFired       = 2,
    kDiagStageHooksInstalled = 3,
    kDiagStageHookCalled     = 4,
};

enum : UINT32 {
    kDiagFlagLoaded      = 0x1,
    kDiagFlagEbsFired    = 0x2,
    kDiagFlagVirtual     = 0x4,
    kDiagFlagEarlyHooks  = 0x8,   // v7: gRT hooks installed at load time
    kDiagFlagTriggerSeen = 0x20,  // v8/v13: our-namespace write seen by hook
};

// Runtime-updated mirror of the variable. Written from any mode; the
// serial trace on every write is what makes failures visible.
inline UINT32 g_diag_stage       = 0;
inline UINT32 g_diag_flags       = 0;
inline UINT32 g_diag_win_build   = 0;
inline UINT64 g_diag_os_cr3      = 0;
inline UINT32 g_diag_hook_calls  = 0;
inline UINT32 g_diag_last_status = 0;

// v13: our-namespace SetVariable calls that reached the hook
// after virtual mode (InfinityReq / INFTRIGGER with non-empty
// data). RAM-ONLY observability. (v15 revision: the v12 BSOD
// was finally root-caused to SerialTrace's stale hex-table
// pointer — NOT to chaining orig SetVariable, which the v13
// and v14 runs proved safe 8 times. The counter stays
// RAM-mirrored by design.) The counter is observable through
// the RAM-served INFCNT read.
inline UINT32 g_diag_req_count = 0;

// v15: one-shot KUSD build probe (both candidate offsets are
// traced once per boot; see RuntimeHook CaptureLiveWindowsBuild).
inline UINT32 g_kusd_probe_done = 0;

// v7: virtual-mode boundary. 0 while the firmware still runs at
// physical addresses (driver load, shell, bootmgr/winload up to and
// including the VA-change event). Set to 1 at the very end of the
// VA-change handler. Hooked-service calls that arrive while it is 0
// are boot-context passthroughs (shell / bootmgr / winload) — they
// are traced and counted separately and never touch the stage
// ladder. Calls that arrive while it is 1 come from the booted OS at
// runtime — those are the ones that prove the chain (stage 4).
inline volatile UINT32 g_diag_va_done = 0;
inline UINT32 g_diag_boot_calls = 0;   // pre-VA hook calls (traced only)

// Re-entrancy guard: in the RT build, gRT->SetVariable IS our hook,
// so DiagWrite() would re-enter HookedSetVariable. The hook checks
// this flag and services diag writes through the original only.
inline UINT32 g_diag_busy = 0;

// Write the current snapshot to INFDIAG. Safe at load time (physical
// gRT), inside the VA event (gRT slots still physical — v5 proved
// this works), at EBS (RT mapped both ways) and from the gRT hooks
// post-boot (gRT converted by ConvertPointers).
//
// NOTE: in the RT build the SetVariable slot may already point at our
// own HookedSetVariable; the call then round-trips through our hook
// and chains to the original. That is intentional and is itself a
// live test of the hook chain.
inline VOID DiagWrite() {
    InfinityDiag d;
    d.magic       = 0x494E4644;
    d.stage       = g_diag_stage;
    d.flags       = g_diag_flags;
    d.win_build   = g_diag_win_build;
    d.os_cr3      = g_diag_os_cr3;
    d.hook_calls  = g_diag_hook_calls;
    d.last_status = g_diag_last_status; // previous write's status

    UINT32 prev_status = g_diag_last_status;

    g_diag_busy = 1;
    EFI_STATUS s = gRT->SetVariable(
        (CHAR16*)L"INFDIAG", &gInfinityMemVarGuid,
        EFI_VARIABLE_NON_VOLATILE | EFI_VARIABLE_BOOTSERVICE_ACCESS |
            EFI_VARIABLE_RUNTIME_ACCESS,
        sizeof(d), &d);
    g_diag_busy = 0;

    g_diag_last_status = (UINT32)s;

    SerialTrace::Begin("DIAG");
    SerialTrace::Puts("write stage=");
    SerialTrace::Dec(g_diag_stage);
    SerialTrace::Puts(" flags=0x");
    SerialTrace::Hex32(g_diag_flags);
    SerialTrace::Puts(" prev_st=0x");
    SerialTrace::Hex32(prev_status);
    SerialTrace::Puts(" st=0x");
    SerialTrace::Hex32((UINT32)s);
}

inline VOID DiagSetStage(UINT32 stage) { g_diag_stage = stage; }
inline VOID DiagSetFlag(UINT32 flag)   { g_diag_flags |= flag; }

// Convert one runtime-assigned pointer via the ConvertPointer service.
// Defined here (not in ConvertPtr.h) so RuntimeHook::ConvertSelf can
// use it without a circular include.
inline VOID CvtOne(EFI_CONVERT_POINTER cvt, VOID** pp, const char* tag) {
    if (!pp || !*pp) {
        SerialTrace::Begin("CVT");
        SerialTrace::Puts(tag);
        SerialTrace::Puts(" (null, skip)");
        return;
    }
    UINT64 before = (UINT64)*pp;
    EFI_STATUS s = cvt(0, pp);
    SerialTrace::Begin("CVT");
    SerialTrace::Puts(tag);
    SerialTrace::Puts(" 0x");
    SerialTrace::Hex64(before);
    SerialTrace::Puts(" -> 0x");
    SerialTrace::Hex64((UINT64)*pp);
    SerialTrace::Puts(" st=0x");
    SerialTrace::Hex32((UINT32)s);
}

} // namespace UEFIBridge
