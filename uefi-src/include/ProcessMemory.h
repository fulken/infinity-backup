/**
 * ProcessMemory.h  (UEFI side — REWRITTEN)
 * =================================================================
 * Process-aware memory access through PhysicalMemory.
 *
 * This is a thin wrapper that uses PhysicalMemory (with CR3
 * switching) to read/write virtual addresses in a target process.
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
#include "Diag.h"
#include "KernelAnchor.h"

namespace UEFIBridge {

    class ProcessMemory {
    public:
        ProcessMemory() = default;

        // Initialize with the physical memory accessor.
        void Initialize(PhysicalMemory* pm) {
            phys_ = pm;
        }

        // v6: convert runtime-assigned pointers to virtual addresses
        // (called from the SetVirtualAddressMap event handler).
        // target_cr3_ is a CR3 VALUE and stays physical.
        void ConvertSelf(EFI_CONVERT_POINTER cvt) {
            CvtOne(cvt, (VOID**)&phys_, "PM.phys_");
        }

        // Set the target process's CR3.
        void SetTargetCR3(UINT64 cr3) { target_cr3_ = cr3; }
        void ClearTargetCR3() { target_cr3_ = 0; }
        UINT64 GetTargetCR3() const { return target_cr3_; }

        // =========================================================
        // Read N bytes from a virtual address (crosses pages).
        // =================================================================
        BOOLEAN ReadVA(UINT64 va, VOID* out, UINTN size) {
            if (!phys_ || !target_cr3_) return FALSE;
            return phys_->ReadVA(va, target_cr3_, out, size);
        }

        // =========================================================
        // Write N bytes to a virtual address.
        // =================================================================
        BOOLEAN WriteVA(UINT64 va, const VOID* src, UINTN size) {
            if (!phys_ || !target_cr3_) return FALSE;
            return phys_->WriteVA(va, target_cr3_, src, size);
        }

        // =========================================================
        // v18: kernel-space read for the data-path proof.
        // DIRECT volatile read through the CALLER's CR3 (the hook
        // runs in the calling Windows thread's context, so the
        // current mapping IS the Windows mapping). No page walk, no
        // CR3 switching. The v17 body walked the tables and read
        // the leaves via ReadPhysical, which switches CR3 to the
        // boot-time firmware tables (uefi_cr3_) - under Windows
        // those map NEITHER our hook code (0xFFFFF800...) nor the
        // OS IDT/stack, so the first fetch after the switch faults
        // and the fault cannot be dispatched: fault storm, VM death
        // (the v19 attach walk and the v20 kernel read both died
        // exactly there; root-caused 2026-09-22 from the v17
        // source). v18 reads ONLY the two KUSER_SHARED_DATA windows
        // that every address space maps (user alias
        // 0x7FFE0000-0x7FFEFFFF, kernel alias
        // 0xFFFFF78000000000-0xFFFFF7800000FFFF), so the
        // dereference cannot fault; anything else fails the gate
        // cleanly BEFORE any access.
        // =================================================================
        BOOLEAN ReadKernelVA(UINT64 va, VOID* out, UINTN size) {
            if (!out || size == 0 || size > 4096) return FALSE;
            UINT64 end = va + (UINT64)size - 1;
            if (end < va) return FALSE;          // wrap-around guard
            BOOLEAN in_user =
                (va >= 0x7FFE0000ULL) && (end <= 0x7FFEFFFFULL);
            BOOLEAN in_kern =
                (va >= 0xFFFFF78000000000ULL) &&
                (end <= 0xFFFFF7800000FFFFULL);
            // v19 (F1): the THIRD gate — the VALIDATED kernel-image
            // range [pe_base, pe_base+pe_size), unlocked ONLY while the
            // anchor stack is CONVERGED (SIDT + 3 independent walk-backs
            // + full PE structural validation + containment — all
            // fail-closed in KernelAnchor.h). Anything else: exactly
            // the v18 behavior.
            BOOLEAN in_validated = FALSE;
            if (ka::g_result.state == ka::kAnchorConverged) {
                UINT64 vb = ka::g_result.pe_base;
                UINT64 ve = vb + ka::g_result.pe_size - 1;
                if (va >= vb && end <= ve) in_validated = TRUE;
            }
            if (!in_user && !in_kern && !in_validated) return FALSE;
            volatile UINT8* src = (volatile UINT8*)(UINTN)va;
            UINT8* dst = (UINT8*)out;
            for (UINTN i = 0; i < size; i++) dst[i] = src[i];
            return TRUE;
        }

        // =========================================================
        // Convenience: read a typed value.
        // =================================================================
        template <typename T>
        T Read(UINT64 va) {
            T v{};
            ReadVA(va, &v, sizeof(T));
            return v;
        }

        template <typename T>
        BOOLEAN Write(UINT64 va, const T& v) {
            return WriteVA(va, &v, sizeof(T));
        }

        // =========================================================
        // Allocate memory in the target process (placeholder).
        // Real implementation would find a free VA range and
        // allocate physical pages, then map them.
        // For now, returns 0 (failure).
        // =================================================================
        UINT64 Allocate(UINT64 size) {
            (void)size;
            return 0;
        }

        BOOLEAN Free(UINT64 /*addr*/, UINT64 /*size*/) {
            return FALSE;
        }

    private:
        PhysicalMemory* phys_      = nullptr;
        UINT64          target_cr3_ = 0;
    };

} // namespace UEFIBridge
