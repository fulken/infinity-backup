/**
 * PhysicalMemory.h  (UEFI side)
 * =================================================================
 * Runtime-safe physical memory access after ExitBootServices.
 *
 * Uses CR3 switching to access physical RAM:
 *   1. Save current CR3 (OS page tables).
 *   2. Disable interrupts.
 *   3. Switch to UEFI's saved CR3 (UEFI identity-maps all of RAM).
 *   4. Do the memory operation.
 *   5. Switch back to OS CR3.
 *   6. Restore interrupt flag.
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

namespace UEFIBridge {

    // =========================================================
    // Inline assembly helpers (x86-64).
    // gnu-efi 3.0.x doesn't provide AsmReadCr3 etc., so we use
    // GCC inline assembly.
    // =================================================================
    static inline UINT64 ReadCr3() {
        UINT64 cr3;
        __asm__ __volatile__("mov %%cr3, %0" : "=r"(cr3));
        return cr3;
    }

    static inline void WriteCr3(UINT64 cr3) {
        __asm__ __volatile__("mov %0, %%cr3" : : "r"(cr3));
    }

    static inline UINT64 ReadFlags() {
        UINT64 flags;
        __asm__ __volatile__("pushfq; pop %0" : "=r"(flags));
        return flags;
    }

    static inline void WriteFlags(UINT64 flags) {
        __asm__ __volatile__("push %0; popfq" : : "r"(flags));
    }

    static inline void DisableInterrupts() {
        __asm__ __volatile__("cli");
    }

    static inline void EnableInterrupts() {
        __asm__ __volatile__("sti");
    }

    class PhysicalMemory {
    public:
        PhysicalMemory() = default;

        // =========================================================
        // Initialize during Boot Services — save UEFI's CR3.
        // =================================================================
        void Initialize() {
            uefi_cr3_ = ReadCr3();
            initialized_ = TRUE;
        }

        // Set the OS CR3 after we capture it from ExitBootServices hook.
        void SetOSCR3(UINT64 os_cr3) {
            os_cr3_ = os_cr3;
        }

        // =========================================================
        // Read N bytes from a physical address.
        // =================================================================
        BOOLEAN ReadPhysical(UINT64 pa, VOID* out, UINTN size) {
            if (!initialized_) return FALSE;
            // Validate physical address range.
            // We assume max 64 GB of RAM (0x1000000000 = 64GB).
            // This prevents reading from invalid physical addresses.
            if (pa == 0 || pa > 0x1000000000ULL) return FALSE;
            if (size == 0) return TRUE;
            if (size > 0x1000000000ULL || pa > 0x1000000000ULL - size) return FALSE;

            UINT64 saved_cr3 = ReadCr3();
            UINT64 flags = ReadFlags();

            DisableInterrupts();
            WriteCr3(uefi_cr3_);

            // UEFI identity-maps all of RAM, so virtual == physical.
            CopyMem(out, (VOID*)(UINTN)pa, size);

            WriteCr3(saved_cr3);
            WriteFlags(flags);
            return TRUE;
        }

        // =========================================================
        // Write N bytes to a physical address.
        // =================================================================
        BOOLEAN WritePhysical(UINT64 pa, const VOID* src, UINTN size) {
            if (!initialized_) return FALSE;
            // Validate physical address range.
            if (pa == 0 || pa > 0x1000000000ULL) return FALSE;
            if (size == 0) return TRUE;
            if (size > 0x1000000000ULL || pa > 0x1000000000ULL - size) return FALSE;

            UINT64 saved_cr3 = ReadCr3();
            UINT64 flags = ReadFlags();

            DisableInterrupts();
            WriteCr3(uefi_cr3_);

            CopyMem((VOID*)(UINTN)pa, src, size);

            WriteCr3(saved_cr3);
            WriteFlags(flags);
            return TRUE;
        }

        // =========================================================
        // Convenience: read a single value.
        // =================================================================
        template <typename T>
        T Read(UINT64 pa) {
            T value{};
            ReadPhysical(pa, &value, sizeof(T));
            return value;
        }

        template <typename T>
        BOOLEAN Write(UINT64 pa, const T& value) {
            return WritePhysical(pa, &value, sizeof(T));
        }

        // =========================================================
        // Translate a virtual address in a process (with given CR3)
        // to a physical address.
        // =================================================================
        UINT64 TranslateVA(UINT64 va, UINT64 process_cr3) {
            const UINT64 PTE_PRESENT   = (1ULL << 0);
            const UINT64 PTE_LARGE     = (1ULL << 7);
            const UINT64 PTE_ADDR_MASK = 0x000FFFFFFFFFF000ULL;

            // Validate virtual address canonicality (x86-64).
            // Bits 48-63 must all be the same as bit 47.
            UINT64 canonical_check = (va >> 47) & 1;
            if (canonical_check) {
                // Bits 48-63 must all be 1
                if ((va & 0xFFFF000000000000ULL) != 0xFFFF000000000000ULL) {
                    return 0;  // non-canonical
                }
            } else {
                // Bits 48-63 must all be 0
                if ((va & 0xFFFF000000000000ULL) != 0) {
                    return 0;  // non-canonical
                }
            }

            // Validate CR3 (must be page-aligned).
            if (process_cr3 & 0xFFF) return 0;

            UINT64 pml4_idx = (va >> 39) & 0x1FF;
            UINT64 pdpt_idx = (va >> 30) & 0x1FF;
            UINT64 pd_idx   = (va >> 21) & 0x1FF;
            UINT64 pt_idx   = (va >> 12) & 0x1FF;

            UINT64 pml4_base = process_cr3 & PTE_ADDR_MASK;
            UINT64 pml4e = Read<UINT64>(pml4_base + pml4_idx * 8);
            if (!(pml4e & PTE_PRESENT)) return 0;

            UINT64 pdpt_base = pml4e & PTE_ADDR_MASK;
            UINT64 pdpte = Read<UINT64>(pdpt_base + pdpt_idx * 8);
            if (!(pdpte & PTE_PRESENT)) return 0;
            if (pdpte & PTE_LARGE) {
                return (pdpte & PTE_ADDR_MASK) + (va & 0x3FFFFFFF);
            }

            UINT64 pd_base = pdpte & PTE_ADDR_MASK;
            UINT64 pde = Read<UINT64>(pd_base + pd_idx * 8);
            if (!(pde & PTE_PRESENT)) return 0;
            if (pde & PTE_LARGE) {
                return (pde & PTE_ADDR_MASK) + (va & 0x1FFFFF);
            }

            UINT64 pt_base = pde & PTE_ADDR_MASK;
            UINT64 pte = Read<UINT64>(pt_base + pt_idx * 8);
            if (!(pte & PTE_PRESENT)) return 0;

            return (pte & PTE_ADDR_MASK) + (va & 0xFFF);
        }

        // =========================================================
        // Read from a virtual address in a process.
        // =================================================================
        BOOLEAN ReadVA(UINT64 va, UINT64 process_cr3, VOID* out, UINTN size) {
            UINTN read = 0;
            while (read < size) {
                UINT64 pa = TranslateVA(va + read, process_cr3);
                if (!pa) return FALSE;

                UINT64 page_off   = (va + read) & 0xFFF;
                UINT64 chunk_size  = 0x1000 - page_off;
                UINT64 remaining   = size - read;
                if (chunk_size > remaining) chunk_size = remaining;

                if (!ReadPhysical(pa, (UINT8*)out + read, (UINTN)chunk_size))
                    return FALSE;

                read += chunk_size;
            }
            return TRUE;
        }

        BOOLEAN WriteVA(UINT64 va, UINT64 process_cr3, const VOID* src, UINTN size) {
            UINTN written = 0;
            while (written < size) {
                UINT64 pa = TranslateVA(va + written, process_cr3);
                if (!pa) return FALSE;

                UINT64 page_off   = (va + written) & 0xFFF;
                UINT64 chunk_size  = 0x1000 - page_off;
                UINT64 remaining   = size - written;
                if (chunk_size > remaining) chunk_size = remaining;

                if (!WritePhysical(pa, (const UINT8*)src + written,
                                   (UINTN)chunk_size))
                    return FALSE;

                written += chunk_size;
            }
            return TRUE;
        }

    private:
        UINT64 uefi_cr3_    = 0;
        UINT64 os_cr3_      = 0;
        BOOLEAN initialized_ = FALSE;
    };

} // namespace UEFIBridge
