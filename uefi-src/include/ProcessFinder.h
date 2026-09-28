/**
 * ProcessFinder.h  (UEFI side)
 * =================================================================
 * Find a target process by image name and return its CR3.
 *
 * Strategy:
 *   1. Read PsActiveProcessHead from ntoskrnl.exe.
 *   2. Walk the ActiveProcessLinks list in each EPROCESS.
 *   3. Compare ImageFileName field with target name.
 *   4. Return CR3 (DirectoryTableBase) of matching process.
 *
 * Finding PsActiveProcessHead:
 *   This is a non-exported symbol in ntoskrnl.exe. We can find it
 *   by pattern scanning, OR by using the well-known fact that the
 *   Idle process (PID 0) is the first entry. So we can start from
 *   System process (PID 4) which we find by scanning kernel memory
 *   for the EPROCESS signature.
 *
 * Simpler approach (used here):
 *   Brute-force scan EPROCESS structures by reading physical
 *   memory at common EPROCESS locations. Each EPROCESS has a
 *   distinctive signature:
 *     - UniqueProcessId is in range [0, 0xFFFF]
 *     - ActiveProcessLinks points to a kernel address (0xFFFF...).
 *     - ImageFileName is a printable ASCII string.
 *
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
#include "PhysicalMemory.h"
#include "WindowsOffsets.h"
#include "Diag.h"

namespace UEFIBridge {

    struct ProcessInfo {
        UINT64 eprocess_va;     // Virtual address of EPROCESS
        UINT64 cr3;             // DirectoryTableBase
        UINT32 pid;             // UniqueProcessId
        CHAR8   image_name[16]; // ImageFileName
    };

    class ProcessFinder {
    public:
        ProcessFinder() = default;

        void Initialize(PhysicalMemory* pm) {
            phys_ = pm;
        }

        // v6: convert runtime-assigned pointers to virtual addresses
        // (called from the SetVirtualAddressMap event handler).
        // os_cr3_ is a CR3 VALUE and stays physical.
        void ConvertSelf(EFI_CONVERT_POINTER cvt) {
            CvtOne(cvt, (VOID**)&phys_, "PF.phys_");
        }

        // =========================================================
        // Set the OS CR3 (Windows kernel page table root).
        // Must be called after ExitBootServices capture.
        // =========================================================
        void SetOSCR3(UINT64 os_cr3, UINT32 build) {
            os_cr3_   = os_cr3;
            build_    = build;
            // #110 fix: fail closed for unknown builds.
            if (!GetOffsetsForBuild(build, offsets_)) {
                // Unknown build — set offsets to zero to prevent
                // using wrong offsets.
                offsets_ = WinKernelOffsets{};
                build_supported_ = false;
            } else {
                build_supported_ = true;
            }
        }

        // =========================================================
        // Find a process by image name. Returns TRUE on success.
        // =================================================================
        BOOLEAN FindByName(const CHAR8* target_name, ProcessInfo* out) {
            if (!phys_ || !out) return FALSE;
            if (os_cr3_ == 0) return FALSE;
            // v14 F2: the EBS-time build capture always read 0
            // (firmware page tables at ExitBootServices — the
            // KUSD VA is not mapped there), which left
            // build_supported_ = false forever. RuntimeHook now
            // captures the LIVE build from KUSER_SHARED_DATA in
            // desktop kernel contexts; re-resolve the offsets
            // lazily once it is available.
            if (!build_supported_ && g_diag_win_build) {
                SetOSCR3(g_diag_os_cr3 ? g_diag_os_cr3 : os_cr3_,
                         g_diag_win_build);
            }
            // #110 fix: don't search if build is unknown (offsets unreliable).
            if (!build_supported_) return FALSE;

            // Strategy: We need to find PsActiveProcessHead.
            // Approach: Use the Idle/Swapper (PID 0) EPROCESS as the anchor.
            // The Idle EPROCESS in Windows is statically allocated in
            // ntoskrnl.exe and its ActiveProcessLinks point to the
            // first "real" process. We can find it by:
            //   (a) brute-force scanning kernel memory for known
            //       EPROCESS signature, or
            //   (b) using a fixed kernel VA for PsActiveProcessHead
            //       that we know for this build.
            //
            // For a PoC, we use approach (b) — PsActiveProcessHead
            // is at a fixed offset in ntoskrnl.exe. We need the
            // kernel base address, which we can read from the IDT.
            //
            // The IDT base is in the IDTR register. We can read it
            // via SIDT instruction. The first IDT entry points to
            // KiDivideErrorFault, which is in ntoskrnl.exe. From
            // there, we compute the kernel base.

            UINT64 kernel_base = FindKernelBase();
            if (!kernel_base) return FALSE;

            // PsActiveProcessHead RVA (per build). These must be
            // filled in for the specific build you're targeting.
            // For now we use a heuristic approach: scan common kernel
            // memory for EPROCESS signatures.

            return ScanForProcessByName(target_name, out);
        }

    private:
        // =========================================================
        // Find ntoskrnl.exe base address via IDT.
        // =================================================================
        UINT64 FindKernelBase() {
            // Read IDTR (Interrupt Descriptor Table Register).
            // SIDT stores 10 bytes: 2-byte limit + 8-byte base.
            // Use a union to avoid strict-aliasing warnings.
            union {
                UINT8 bytes[10];
                struct {
                    UINT16 limit;
                    UINT64 base;
                } data;
            } idtr;
            __builtin_memset(&idtr, 0, sizeof(idtr));
            __asm__ __volatile__("sidt %0" : "=m"(idtr));
            UINT64 idt_base = idtr.data.base;

            // Read the first IDT entry (KiDivideErrorFault handler).
            // In x86-64 long mode, each IDT entry is 16 bytes (not 8).
            // The handler VA is split across:
            //   bytes 0-1   : low 16 bits of handler
            //   bytes 6-7   : mid 16 bits of handler
            //   bytes 8-11  : high 32 bits of handler
            //   bytes 2-3   : segment selector
            //   bytes 4-5   : attributes
            //   bytes 12-15 : reserved
            // We need to read all 16 bytes.
            UINT8 idt_entry[16];
            if (!phys_->ReadVA(idt_base, os_cr3_, idt_entry, 16))
                return 0;

            // Use memcpy to avoid strict-aliasing warnings.
            UINT16 low16, mid16;
            UINT32 high32;
            __builtin_memcpy(&low16,  &idt_entry[0], 2);
            __builtin_memcpy(&mid16,  &idt_entry[6], 2);
            __builtin_memcpy(&high32, &idt_entry[8], 4);
            UINT64 handler_va = ((UINT64)high32 << 32) | ((UINT64)mid16 << 16) | low16;

            // #105 fix: scan more pages (up to 16 MB backwards).
            // The kernel image base can be several MB before the handler.
            // #104 fix: kernel_base was computed but never used — removed.
            for (int i = 0; i < 4096; ++i) {
                UINT64 candidate = handler_va - (i * 0x1000);
                // Check MZ signature.
                UINT16 mz = 0;
                if (phys_->ReadVA(candidate, os_cr3_, &mz, 2) && mz == 0x5A4D) {
                    return candidate;
                }
            }
            return 0;
        }

        // =========================================================
        // Scan common kernel memory for an EPROCESS matching name.
        // Slow but reliable.
        // =================================================================
        BOOLEAN ScanForProcessByName(const CHAR8* target_name, ProcessInfo* out) {
            // Target name length.
            UINTN name_len = 0;
            while (target_name[name_len] && name_len < 15) name_len++;

            // Scan kernel VA range. EPROCESS is typically in
            // 0xFFFFE000'00000000 - 0xFFFFE000'00FFFFFF (PagedPool).
            // But that's a huge range. We use a heuristic:
            // EPROCESS begins on a page boundary and the first 4 bytes
            // are a header. We can find a starting point by looking
            // at the System process (PID 4), which is at a known RVA
            // in ntoskrnl.exe.

            // For a PoC: try common addresses used by Windows for
            // InitialProcess. In most builds, the System EPROCESS is
            // statically allocated in ntoskrnl.exe.
            //
            // We use this approach: scan physical RAM (low addresses
            // 0x10000 - 0x10000000) for any EPROCESS whose
            // ImageFileName matches our target.

            for (UINT64 pa = 0x10000; pa < 0x10000000ULL; pa += 0x1000) {
                UINT8 page[0x1000];
                if (!phys_->ReadPhysical(pa, page, sizeof(page))) continue;

                // Try interpreting each 16-byte aligned offset as an EPROCESS.
                for (UINTN off = 0; off + offsets_.EPROCESS_ImageFileName + 16 <= 0x1000; off += 0x10) {
                    // Check ImageFileName matches target.
                    if (CompareMem(page + off + offsets_.EPROCESS_ImageFileName,
                                   target_name, name_len) == 0) {
                        if (off + offsets_.EPROCESS_ActiveProcessLinks + 16 > 0x1000) continue;
                        UINT32 pid = *(UINT32*)(page + off + offsets_.EPROCESS_UniqueProcessId);
                        if (pid == 0 || pid > 0xFFFFF) continue;

                        UINT64 cr3 = *(UINT64*)(page + off + offsets_.EPROCESS_DirectoryTableBase);
                        if ((cr3 & 0xFFF) != 0) continue;

                        out->eprocess_va = pa + off;
                        out->cr3         = cr3;
                        out->pid         = pid;
                        CopyMem(out->image_name, page + off + offsets_.EPROCESS_ImageFileName, 15);
                        out->image_name[15] = 0;
                        return TRUE;
                    }
                }
            }
            return FALSE;
        }

        PhysicalMemory* phys_ = nullptr;
        UINT64          os_cr3_ = 0;
        UINT32          build_ = 0;
        bool            build_supported_ = false;
        WinKernelOffsets offsets_{};
    };

} // namespace UEFIBridge
