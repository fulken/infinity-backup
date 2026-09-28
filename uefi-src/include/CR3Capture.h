/**
 * CR3Capture.h  (UEFI side)  —  v6
 * =================================================================
 * Hook gBS->ExitBootServices to capture the OS CR3 and the Windows
 * build number, and to record milestone stage 2 in INFDIAG.
 *
 * v6 changes vs baseline (a8e41b3):
 *   - Full serial tracing of the hook path. v5 showed INFDIAG stuck at
 *     stage 3 (VA event ran) with stage 2 never recorded; the serial
 *     traces now tell us whether this hook fires at all and, if it
 *     does, the exact status of the INFDIAG SetVariable.
 *   - The EBS hook NO LONGER installs the gRT hooks. In the RT build
 *     they are installed earlier, from the SetVirtualAddressMap event
 *     (RuntimeHook::InstallVirtual); in the SAFE build they are never
 *     installed. (The old EBS-time install wrote unconverted physical
 *     pointers into an already-virtual gRT table — that is what hung
 *     the Linux test VM.)
 *   - CR3Capture internals are deliberately NOT pointer-converted:
 *     this hook only ever runs in the loader's identity-mapped context
 *     (the gBS table lives in boot-services memory and is never
 *     converted, so the firmware calls us at our physical address).
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
#include "PhysicalMemory.h"
#include "WindowsOffsets.h"
#include "ProcessFinder.h"
#include "RuntimeHook.h"

namespace UEFIBridge {

    class CR3Capture {
    public:
        CR3Capture() = default;

        EFI_STATUS Install(PhysicalMemory* pm, ProcessFinder* finder,
                           RuntimeHook* runtime_hook,
                           RequestHandler* handler) {
            phys_         = pm;
            finder_       = finder;
            runtime_hook_ = runtime_hook;
            handler_      = handler;

            orig_exit_bs_ = gBS->ExitBootServices;
            gBS->ExitBootServices = &CR3Capture::HookedExitBootServices;
            instance_ = this;

            // Update Boot Services Table CRC after modifying it.
            gBS->Hdr.CRC32 = 0;
            gBS->Hdr.CRC32 = ComputeCrc32(gBS, gBS->Hdr.HeaderSize);

            SerialTrace::KV("EBS", "hook installed, orig ExitBootServices ",
                            (UINT64)orig_exit_bs_);
            return EFI_SUCCESS;
        }

        UINT64 GetOSCR3() const { return os_cr3_; }

        static EFI_STATUS EFIAPI HookedExitBootServices(
            EFI_HANDLE image_handle, UINTN map_key) {

            // FIRST thing: pure port-I/O proof that the hook fired.
            // This line alone answers the v5 question "did EBS run?".
            SerialTrace::Line("EBS", "ExitBootServices hook FIRED");
            if (!instance_) {
                SerialTrace::Line("EBS", "instance_ null — bailing out");
                return EFI_NOT_FOUND;
            }

            // UNHOOK BEFORE calling original ExitBootServices.
            gBS->ExitBootServices = orig_exit_bs_;
            gBS->Hdr.CRC32 = 0;
            gBS->Hdr.CRC32 = ComputeCrc32(gBS, gBS->Hdr.HeaderSize);

            // Call the original ExitBootServices.
            // After this returns success, gBS is invalid.
            SerialTrace::Line("EBS", "calling original ExitBootServices");
            EFI_STATUS s = orig_exit_bs_(image_handle, map_key);
            SerialTrace::Status("EBS", "original ExitBootServices returned", (UINT64)s);

            if (EFI_ERROR(s)) {
                // OS will retry (stale map key). Re-install our hook.
                SerialTrace::Line("EBS", "retry expected — re-installing hook");
                gBS->ExitBootServices = &CR3Capture::HookedExitBootServices;
                gBS->Hdr.CRC32 = 0;
                gBS->Hdr.CRC32 = ComputeCrc32(gBS, gBS->Hdr.HeaderSize);
                return s;
            }

            // We are now in runtime context with the OS loader's page
            // tables: identity mapping for firmware memory is still
            // active, so physical pointers still work HERE (but nowhere
            // after this callback). gBS is invalid; gRT is virtual.
            instance_->os_cr3_ = UEFIBridge::ReadCr3();
            SerialTrace::KV("EBS", "os_cr3 ", instance_->os_cr3_);

            UINT32 build = DetectWindowsBuildNumber(instance_->phys_,
                                                    instance_->os_cr3_);
            instance_->win_build_ = build;
            // v16 cosmetic: this line read "windows build=0" in every
            // report since v6 and confused the analysis every time.
            // 0 at EBS time is NORMAL: the CPU still runs on the
            // FIRMWARE page tables (EBS CR3 == UEFI CR3 in every
            // serial log since v6) which do not map the high-
            // canonical KUSD VA, and NtBuildNumber is not
            // populated yet either. The authoritative capture is
            // the live desktop-time probe (RuntimeHook
            // CaptureLiveWindowsBuild, KUSD+0x260 - empirically
            // settled by the v15 run: 0x260=19045, 0x308=0).
            SerialTrace::KVD("EBS",
                "windows build (EBS-time; 0 is normal - live probe fills)",
                build);

            instance_->finder_->SetOSCR3(instance_->os_cr3_, build);

            // NOTE (v7): the gRT hooks are NOT installed here.
            //   RT build : installed EARLY at driver load (InstallEarly),
            //              before bootmgr/winload snapshot the table.
            //   SAFE build: never installed.

            // Record milestone 2 in INFDIAG. If this write fails, the
            // serial trace above still tells the whole story.
            g_diag_os_cr3    = instance_->os_cr3_;
            g_diag_win_build = build;
            DiagSetStage(kDiagStageEbsFired);
            DiagSetFlag(kDiagFlagEbsFired);
            DiagWrite();

            SerialTrace::Line("EBS", "handoff complete, returning to OS loader");
            return s;
        }

        // Static instance pointer (used only inside the EBS callback —
        // kept PHYSICAL on purpose, see file header).
        static CR3Capture* instance_;
        static EFI_EXIT_BOOT_SERVICES orig_exit_bs_;

    private:
        PhysicalMemory* phys_         = nullptr;
        ProcessFinder*  finder_       = nullptr;
        RuntimeHook*    runtime_hook_ = nullptr;
        RequestHandler* handler_      = nullptr;
        UINT64          os_cr3_       = 0;
        UINT32          win_build_    = 0;
    };

    inline CR3Capture* CR3Capture::instance_ = nullptr;
    inline EFI_EXIT_BOOT_SERVICES CR3Capture::orig_exit_bs_ = nullptr;

} // namespace UEFIBridge
