/**
 * ConvertPtr.h  (UEFI side)  —  v6 pointer graph conversion
 * =================================================================
 * Converts every RUNTIME-ASSIGNED pointer in the driver to the OS
 * virtual address space, from inside the
 * EVT_SIGNAL_VIRTUAL_ADDRESS_CHANGE event (which the OS fires by
 * calling SetVirtualAddressMap, BEFORE the firmware rewrites the gRT
 * function slots — verified empirically in the sandbox forensics,
 * "order B").
 *
 * Why this is needed:
 *   - Our image is a runtime driver: the firmware re-applies its ELF
 *     relocations at SetVirtualAddressMap, which fixes LINK-TIME
 *     pointers only.
 *   - Pointers assigned at RUNTIME (instance_ = &obj, handler_->pool_,
 *     saved original gRT services, gnu-efi's ST/RT variables...) are
 *     NOT relocations. If left physical they dereference garbage once
 *     the OS page tables take over → #PF inside a kernel-called hook.
 *
 * Ordering rule (CRITICAL):
 *   All conversions go through the CURRENT (physical) value of
 *   gRT->ConvertPointer captured ONCE at entry. The RT/ST variables
 *   themselves are converted LAST, and nothing may dereference gRT /
 *   gST inside this file after that point (during the event the new
 *   virtual addresses are not mapped yet — they only become valid
 *   when the OS loader switches page tables AFTER SetVirtualAddressMap
 *   returns).
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

#include "SerialTrace.h"
#include "Diag.h"
#include "PhysicalMemory.h"
#include "ProcessMemory.h"
#include "ProcessFinder.h"
#include "SharedMemoryPool.h"
#include "RequestHandler.h"
#include "RuntimeHook.h"
#include "CR3Capture.h"

namespace UEFIBridge {

// Everything the VA event handler needs a handle on.
// (CvtOne lives in Diag.h to avoid a circular include.)
struct ConvertGraph {
    PhysicalMemory*   pm;
    SharedMemoryPool* pool;
    ProcessMemory*    pmem;
    ProcessFinder*    finder;
    RequestHandler*   handler;
    RuntimeHook*      rthook;
    CR3Capture*       cr3;
};

// Convert the whole runtime-assigned pointer graph.
// Called ONLY from the VA-change event handler.
inline VOID ConvertPointersAll(ConvertGraph* g) {
    SerialTrace::Line("VA", "ConvertPointers: begin");

    // Physical ConvertPointer — still valid during the event (order B).
    EFI_CONVERT_POINTER cvt = gRT->ConvertPointer;

    if (g) {
        if (g->rthook)  g->rthook->ConvertSelf(cvt);
        if (g->handler) g->handler->ConvertSelf(cvt);
        if (g->finder)  g->finder->ConvertSelf(cvt);
        if (g->pmem)    g->pmem->ConvertSelf(cvt);
        if (g->pool)    g->pool->ConvertSelf(cvt);
        // PhysicalMemory: uefi_cr3_ / os_cr3_ are CR3 *values* — they
        // must stay physical (the CR3 register takes physical roots).

        // Static instance pointers used by post-boot hooks.
        CvtOne(cvt, (VOID**)&RuntimeHook::instance_, "RuntimeHook::instance_");

        // CR3Capture internals are only used inside the EBS callback,
        // which still runs on the loader's identity-mapped tables —
        // deliberately NOT converted.
    }

    // LAST: gnu-efi's table pointer variables (ST/RT live inside our
    // image, extern "C", see efilib.h). BS is dead after EBS — skip.
    CvtOne(cvt, (VOID**)&RT, "RT");
    CvtOne(cvt, (VOID**)&ST, "ST");

    DiagSetFlag(kDiagFlagVirtual);
    SerialTrace::Line("VA", "ConvertPointers: done");
}

} // namespace UEFIBridge
