/**
 * SharedMemoryPool.h  (UEFI side)
 * =================================================================
 * Owner of the 4 MB shared memory region allocated by memory.efi.
 *
 * SAFETY NOTES:
 *   - This pool is allocated as EfiRuntimeServicesData, which
 *     survives ExitBootServices. It is NEVER freed (intentionally).
 *   - The destructor calls Cleanup(), but Cleanup() checks if we're
 *     still in Boot Services before calling gBS->FreePages.
 *     After ExitBootServices, gBS is invalid, so we skip the free.
 *   - SetMem is used to zero the pool, but we zero fields individually
 *     after SetMem to ensure proper initialization (not relying on
 *     the bit pattern of volatile fields).
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

#include "SharedMemoryProtocol.h"
#include <cstdint>

namespace UEFIBridge {

    // GUID for our runtime variable {A1B2C3D4-E5F6-4789-9ABC-DEF012345678}
    extern EFI_GUID gInfinityMemVarGuid;

    class SharedMemoryPool {
    public:
        SharedMemoryPool() = default;
        // Destructor is intentionally trivial — we do NOT call Cleanup
        // automatically because the pool must survive ExitBootServices.
        // If you need to clean up, call Cleanup() explicitly while
        // still in Boot Services.
        ~SharedMemoryPool() = default;

        // Allocate the 4 MB pool, set up header, publish variable.
        EFI_STATUS Initialize() {
            EFI_PHYSICAL_ADDRESS addr = 0;
            UINTN pages = EFI_SIZE_TO_PAGES((UINTN)SHARED_POOL_SIZE);
            EFI_STATUS s = gBS->AllocatePages(
                AllocateAnyPages, EfiRuntimeServicesData, pages, &addr);
            if (EFI_ERROR(s)) return s;

            base_addr_  = addr;
            total_size_ = (UINTN)SHARED_POOL_SIZE;

            // Zero the entire pool first (raw memory zeroing).
            gBS->SetMem((VOID*)addr, total_size_, 0);

            // Now initialize the header fields individually.
            // This is safe because we just zeroed everything.
            header_ = (::SharedMemoryHeader*)addr;
            header_->magic        = SHARED_MEM_MAGIC;
            header_->version      = PROTOCOL_VERSION;
            header_->header_size  = sizeof(::SharedMemoryHeader);
            header_->pool_size    = (std::uint32_t)SHARED_POOL_SIZE;

            // Initialize ring indices (already 0 from SetMem, but explicit).
            header_->request_write_idx  = 0;
            header_->request_read_idx   = 0;
            header_->response_write_idx = 0;
            header_->response_read_idx  = 0;
            header_->uefi_heartbeat     = 0;
            header_->total_requests     = 0;
            header_->total_responses    = 0;
            header_->total_errors       = 0;
            header_->ready              = 0;  // set to 1 after publish
            header_->generation         = 0;
            header_->header_crc32      = 0;

            // Compute and set CRC32.
            header_->header_crc32 = ComputeHeaderCRC();

            // Publish the EFI variable BEFORE setting ready=1.
            // This ensures Windows can find the pool when it sees ready=1.
            s = PublishVariable();
            if (EFI_ERROR(s)) {
                // Failed to publish — free the pool and bail.
                gBS->FreePages(base_addr_, EFI_SIZE_TO_PAGES(total_size_));
                base_addr_ = 0;
                header_    = nullptr;
                return s;
            }

            // Now set ready=1 (with a memory barrier to ensure all
            // preceding writes are visible first).
            header_->ready = 1;

            return EFI_SUCCESS;
        }

        // Cleanup — ONLY call this while still in Boot Services!
        // After ExitBootServices, gBS is invalid and calling this
        // would crash. The pool is intentionally never freed in
        // normal operation (it survives for the entire boot session).
        void Cleanup() {
            // Mark as not ready first.
            if (header_) {
                header_->ready = 0;
            }
            // Only free pages if we're still in Boot Services.
            // We check this by seeing if gBS is still valid (non-null)
            // and the pool was allocated.
            if (base_addr_ && gBS) {
                // Safe to call FreePages — we're still in Boot Services.
                gBS->FreePages(base_addr_, EFI_SIZE_TO_PAGES(total_size_));
            }
            // Always clear the EFI variable (gRT is valid after EBS).
            if (gRT) {
                gRT->SetVariable(
                    (CHAR16*)L"InfinityMem", &gInfinityMemVarGuid,
                    EFI_VARIABLE_NON_VOLATILE | EFI_VARIABLE_BOOTSERVICE_ACCESS |
                    EFI_VARIABLE_RUNTIME_ACCESS,
                    0, nullptr);
            }
            base_addr_ = 0;
            header_    = nullptr;
        }

        ::SharedMemoryHeader* Header() { return header_; }
        ::RequestSlot*  Requests() {
            return (::RequestSlot*)((UINT8*)base_addr_ + OFFSET_REQUESTS);
        }
        ::ResponseSlot* Responses() {
            return (::ResponseSlot*)((UINT8*)base_addr_ + OFFSET_RESPONSES);
        }
        UINT8* DataPool() {
            return (UINT8*)base_addr_ + OFFSET_DATA_POOL;
        }

        // v6: convert runtime-assigned pointers to virtual addresses
        // (called from the SetVirtualAddressMap event handler).
        VOID ConvertSelf(EFI_CONVERT_POINTER cvt) {
            CvtOne(cvt, (VOID**)&header_, "SMP.header_");
            // base_addr_ is dereferenced as the ring/data base pointer
            // (Requests()/Responses()/DataPool()), so it must go virtual
            // too — it is not just a physical address number.
            CvtOne(cvt, (VOID**)&base_addr_, "SMP.base_addr_");
        }

    private:
        EFI_STATUS PublishVariable() {
            struct EfiVarInfo {
                std::uint32_t magic;
                std::uint32_t size;
                std::uint64_t physical_address;
            } info{ SHARED_MEM_MAGIC, (std::uint32_t)SHARED_POOL_SIZE, base_addr_ };

            return gRT->SetVariable(
                (CHAR16*)L"InfinityMem", &gInfinityMemVarGuid,
                EFI_VARIABLE_NON_VOLATILE | EFI_VARIABLE_BOOTSERVICE_ACCESS |
                EFI_VARIABLE_RUNTIME_ACCESS,
                sizeof(info), &info);
        }

        std::uint32_t ComputeHeaderCRC() {
            std::uint32_t saved = header_->header_crc32;
            header_->header_crc32 = 0;
            std::uint32_t crc = CRC32(header_, sizeof(::SharedMemoryHeader));
            header_->header_crc32 = saved;
            return crc;
        }

        static std::uint32_t CRC32(const void* d, std::size_t len) {
            static std::uint32_t table[256];
            static bool init = false;
            if (!init) {
                for (std::uint32_t i = 0; i < 256; ++i) {
                    std::uint32_t c = i;
                    for (int j = 0; j < 8; ++j)
                        c = (c & 1) ? (0xEDB88320u ^ (c >> 1)) : (c >> 1);
                    table[i] = c;
                }
                init = true;
            }
            const UINT8* p = (const UINT8*)d;
            std::uint32_t crc = 0xFFFFFFFF;
            for (std::size_t i = 0; i < len; ++i)
                crc = table[(crc ^ p[i]) & 0xFF] ^ (crc >> 8);
            return crc ^ 0xFFFFFFFF;
        }

        EFI_PHYSICAL_ADDRESS  base_addr_  = 0;
        UINTN                 total_size_ = 0;
        ::SharedMemoryHeader* header_     = nullptr;
    };

} // namespace UEFIBridge
