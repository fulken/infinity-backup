/**
 * main.c  (UEFI side — memory.efi)  —  v7
 * =================================================================
 * Entry point of the UEFI bridge module.
 *
 * Build variants (see Makefile):
 *   make          -> SAFE build (INFINITY_ENABLE_RUNTIME_HOOKS off).
 *                    Loads, installs the ExitBootServices hook only.
 *   make RT=1     -> RT build. v7: installs the gRT hooks IMMEDIATELY
 *                    at load time (InstallEarly), BEFORE bootmgr/
 *                    winload snapshot the runtime services table.
 *                    (v6 installed them at the SetVirtualAddressMap
 *                    event — the v6 phase-D run proved Windows never
 *                    calls through the live post-SVAM table, so those
 *                    hooks were invisible to the OS.)
 *
 * Startup-fix notes carried from the QEMU bring-up (R1-R6, without
 * which the module #GP-crashes on first load — the CI never executed
 * its own binary):
 *   R1  gnu-efi 3.0.13 headers have no C++ linkage guards -> every
 *       efi.h/efilib.h include site is wrapped in extern "C".
 *   R2/R5  gnu-efi's crt0 calls `efi_main` as a PLAIN SysV function
 *       (rdi/rsi) and never calls InitializeLib — so the entry is a
 *       plain-SysV efi_main that calls InitializeLib itself.
 *   R3  gInfinityMemVarGuid is declared inside namespace UEFIBridge
 *       by SharedMemoryPool.h, so the definition lives in the
 *       namespace too.
 *   R4  -fvisibility=hidden (C++ vague-linkage GOT relocation fix).
 *   R6  Vendored linker script with .bss* wildcards (C++ named .bss
 *       sections were orphaned outside the PE).
 * =================================================================
 */
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
#include "SharedMemoryPool.h"
#include "PhysicalMemory.h"
#include "ProcessMemory.h"
#include "ProcessFinder.h"
#include "CR3Capture.h"
#include "RequestHandler.h"
#include "RuntimeHook.h"
#include "ConvertPtr.h"
#include "SharedMemoryProtocol.h"

namespace UEFIBridge {

    // R3: definition inside the namespace to match the extern
    // declaration in SharedMemoryPool.h / Diag.h.
    // {A1B2C3D4-E5F6-4789-9ABC-DEF012345678}
    EFI_GUID gInfinityMemVarGuid = {
        0xA1B2C3D4, 0xE5F6, 0x4789,
        { 0x9A, 0xBC, 0xDE, 0xF0, 0x12, 0x34, 0x56, 0x78 }
    };

    // Globals — owned by efi_main, lifetime = entire boot.
    static PhysicalMemory   g_phys_mem;
    static SharedMemoryPool g_pool;
    static ProcessMemory    g_proc_mem;
    static ProcessFinder    g_finder;
    static CR3Capture       g_cr3_capture;
    static RequestHandler   g_handler;
    static RuntimeHook      g_runtime_hook;

    // Pointer graph handed to the VA-change event handler.
    static ConvertGraph g_va_graph;

#ifdef INFINITY_ENABLE_RUNTIME_HOOKS
    static const char kBuildLine[] = "  Build: v27 RT - anchors + exports + walk + pte-space (chain A)";
#else
    static const char kBuildLine[] = "  Build: v27 SAFE (phase F4)";
#endif

    // v6 diagnostic: print our image's LoadedImage memory types and
    // every EFI memory-map descriptor that overlaps [lo, hi). Answers
    // "did the firmware load our .text as EfiRuntimeServicesCode (5)?"
    // — the OS maps RT code executable; anything else becomes NX and
    // kernel-called gRT hooks would fault on instruction fetch.
    static VOID DumpImageMemoryInfo(EFI_HANDLE image_handle, UINT64 lo, UINT64 hi) {
        EFI_LOADED_IMAGE* li = nullptr;
        EFI_GUID lipGuid = gEfiLoadedImageProtocolGuid;
        EFI_STATUS s = gBS->HandleProtocol(image_handle, &lipGuid, (VOID**)&li);
        if (!EFI_ERROR(s) && li) {
            SerialTrace::KV("IMG", "ImageBase ", (UINT64)li->ImageBase);
            SerialTrace::KVD("IMG", "ImageCodeType ", (UINT64)li->ImageCodeType);
            SerialTrace::KVD("IMG", "ImageDataType ", (UINT64)li->ImageDataType);
            lo = (UINT64)li->ImageBase;
            hi = lo + 0x20000;
        } else {
            SerialTrace::Status("IMG", "LoadedImage query failed", (UINT64)s);
        }

        static EFI_MEMORY_DESCRIPTOR map[512];
        UINTN mapSize = sizeof(map), mapKey = 0, descSize = 0;
        UINT32 descVer = 0;
        s = gBS->GetMemoryMap(&mapSize, map, &mapKey, &descSize, &descVer);
        if (EFI_ERROR(s)) {
            SerialTrace::Status("MMAP", "GetMemoryMap failed", (UINT64)s);
            return;
        }
        SerialTrace::KVD("MMAP", "descriptors ", (mapSize / (descSize ? descSize : 1)));
        for (UINTN off = 0; off + descSize <= mapSize; off += descSize) {
            EFI_MEMORY_DESCRIPTOR* d = (EFI_MEMORY_DESCRIPTOR*)((UINT8*)map + off);
            UINT64 start = d->PhysicalStart;
            UINT64 end = start + ((UINT64)d->NumberOfPages << 12);
            // v6.1: dump EVERY runtime-services descriptor (type 5/6) so we
            // can compare our region against the firmware's own RT regions.
            bool is_rt = (d->Type == 5 || d->Type == 6);
            bool overlaps = (end > lo && start < hi);
            if (!is_rt && !overlaps) continue;
            SerialTrace::Begin("MMAP");
            SerialTrace::Puts("type=");
            SerialTrace::Dec(d->Type);
            SerialTrace::Puts(" attr=0x");
            SerialTrace::Hex64(d->Attribute);
            SerialTrace::Puts(" phys=0x");
            SerialTrace::Hex64(start);
            SerialTrace::Puts("-0x");
            SerialTrace::Hex64(end);
            SerialTrace::Puts(" npages=");
            SerialTrace::Dec(d->NumberOfPages);
            if (overlaps) SerialTrace::Puts(" <OUR_IMAGE>");
        }
    }

    static VOID PrintBanner() {
        gST->ConOut->ClearScreen(gST->ConOut);
        gST->ConOut->SetAttribute(gST->ConOut,
            EFI_BACKGROUND_BLUE | EFI_WHITE);
        for (int i = 0; i < 30; ++i) {
            Print((CHAR16*)L"                                                          \r\n");
        }
        gST->ConOut->SetAttribute(gST->ConOut, EFI_WHITE);
        gST->ConOut->SetCursorPosition(gST->ConOut, 0, 10);
        Print((CHAR16*)L"  INFINITY UEFI BRIDGE LOADED                              \r\n");
        Print((CHAR16*)L"  Made by: fulken                                          \r\n");
#ifdef INFINITY_ENABLE_RUNTIME_HOOKS
        Print((CHAR16*)L"  Build: v27 RT - anchors + walk + pte-space (F4)          \r\n");
#else
        Print((CHAR16*)L"  Build: v27 SAFE (phase F4)                               \r\n");
#endif
        Print((CHAR16*)L"  Driver has been loaded. You can now boot to the OS.       \r\n");
        Print((CHAR16*)L"\r\n");
    }

    // =================================================================
    // SetVirtualAddressMap event handler.
    //
    // Fired by the firmware while processing the OS loader's
    // SetVirtualAddressMap call, BEFORE the firmware rewrites the gRT
    // function slots ("order B", verified in sandbox forensics).
    //
    // RT build sequence (v7):
    //   1. InstallVirtual: NO-OP when InstallEarly() already placed the
    //      hooks at load time (v7 normal path). The fallback install
    //      (v6 path) only runs if the early install never happened.
    //      The firmware converts the slot contents — our hook
    //      addresses — right after this event returns.
    //   2. DiagWrite(stage 3) while gRT is still physical (proven path
    //      in v5).
    //   3. ConvertPointersAll: convert every runtime-assigned pointer
    //      (graph + saved originals + RT/ST themselves) to virtual.
    //   4. g_diag_va_done = 1: from here on, hooked-service calls are
    //      OS RUNTIME calls — the ones that count for stage 4.
    //
    // SAFE build: only step 3 runs.
    // =================================================================
    static VOID EFIAPI VaChangeHandler(EFI_EVENT /*event*/, VOID* /*context*/) {
        SerialTrace::Line("VA", "SetVirtualAddressMap event FIRED");

#ifdef INFINITY_ENABLE_RUNTIME_HOOKS
        g_va_graph.rthook->InstallVirtual();
        DiagSetStage(kDiagStageHooksInstalled);
        DiagWrite();
#else
        SerialTrace::Line("VA", "SAFE build: no gRT hooks installed");
#endif

        ConvertPointersAll(&g_va_graph);
        g_diag_va_done = 1;   // v7: runtime-context boundary
        SerialTrace::Line("VA", "virtual mode armed - OS runtime hook calls now count (stage 4)");
        SerialTrace::Line("VA", "SetVirtualAddressMap event handler done");
    }

} // namespace UEFIBridge

// =====================================================================
// Entry point — plain SysV ABI (gnu-efi crt0 calls efi_main(rdi, rsi)
// and does NOT call InitializeLib; doing both wrong was startup bug R5).
// =====================================================================
extern "C" EFI_STATUS
efi_main(IN EFI_HANDLE image_handle, IN EFI_SYSTEM_TABLE* sys_table) {
    using namespace UEFIBridge;

    InitializeLib(image_handle, sys_table);

    SerialTrace::Line("MAIN", "efi_main v27 boot");
#ifdef INFINITY_ENABLE_RUNTIME_HOOKS
    SerialTrace::Line("MAIN", "variant: RT (EARLY gRT hooks - v27)");
#else
    SerialTrace::Line("MAIN", "variant: SAFE (no runtime hooks)");
#endif

    PrintBanner();

    g_phys_mem.Initialize();
    SerialTrace::KV("MAIN", "UEFI CR3 ", ReadCr3());

    // Diagnostic: our image's memory typing (decides OS exec permission).
    DumpImageMemoryInfo(image_handle, 0, 0);

    EFI_STATUS s = g_pool.Initialize();
    if (EFI_ERROR(s)) {
        Print((CHAR16*)L"  Failed to allocate shared memory pool: 0x%lx\r\n", s);
        SerialTrace::Status("MAIN", "pool init FAILED", (UINT64)s);
        return s;
    }
    SerialTrace::Line("MAIN", "shared pool OK (4MB, EfiRuntimeServicesData)");

    g_proc_mem.Initialize(&g_phys_mem);
    g_proc_mem.SetTargetCR3(0);

    g_finder.Initialize(&g_phys_mem);

    CR3Capture::instance_ = &g_cr3_capture;
    RuntimeHook::instance_ = &g_runtime_hook;

    // The request handler must be fully ready before the EBS hook is
    // installed (it fires later, when the OS boots).
    s = g_handler.Start(&g_pool, &g_proc_mem, &g_finder);
    if (EFI_ERROR(s)) {
        Print((CHAR16*)L"  Failed to start request handler: 0x%lx\r\n", s);
        SerialTrace::Status("MAIN", "handler start FAILED", (UINT64)s);
        g_pool.Cleanup();
        return s;
    }
    SerialTrace::Line("MAIN", "request handler started (1ms timer)");

    // RuntimeHook's handler pointer (used by the hooks).
    g_runtime_hook.SetHandler(&g_handler);

#ifdef INFINITY_ENABLE_RUNTIME_HOOKS
    // v7: install the gRT hooks NOW — at load time, still inside the
    // EFI Shell — so that bootmgr/winload snapshot OUR hook pointers
    // into the runtime services table copy they hand to the OS. v6
    // installed the hooks at the VA event, i.e. AFTER the winload
    // snapshot was taken, and the user's v6 phase-D run proved the OS
    // then never reaches them. Must run AFTER SetHandler (the hooks
    // call ProcessPending -> handler_) and can safely run BEFORE the
    // EBS hook install below (see RuntimeHook::InstallEarly notes).
    g_runtime_hook.InstallEarly();
#endif

    // Pointer graph for the VA-change event handler (must be filled
    // BEFORE we return — the event fires when the OS boots).
    g_va_graph.pm      = &g_phys_mem;
    g_va_graph.pool    = &g_pool;
    g_va_graph.pmem    = &g_proc_mem;
    g_va_graph.finder  = &g_finder;
    g_va_graph.handler = &g_handler;
    g_va_graph.rthook  = &g_runtime_hook;
    g_va_graph.cr3     = &g_cr3_capture;
    SerialTrace::Line("MAIN", "VA graph populated");

    s = g_cr3_capture.Install(&g_phys_mem, &g_finder, &g_runtime_hook, &g_handler);
    if (EFI_ERROR(s)) {
        Print((CHAR16*)L"  Failed to install ExitBootServices hook: 0x%lx\r\n", s);
        SerialTrace::Status("MAIN", "EBS hook install FAILED", (UINT64)s);
        g_handler.Stop();
        g_pool.Cleanup();
        return s;
    }

    // Register for the SetVirtualAddressMap notification. Must happen
    // during Boot Services; the event fires when the OS loader calls
    // SetVirtualAddressMap (before ExitBootServices).
    {
        EFI_EVENT va_evt = nullptr;
        EFI_STATUS va_st = gBS->CreateEventEx(
            EVT_NOTIFY_SIGNAL, TPL_NOTIFY,
            &VaChangeHandler,
            nullptr, &gEfiEventVirtualAddressChangeGuid, &va_evt);
        SerialTrace::Status("MAIN", "VA event registration", (UINT64)va_st);
        if (EFI_ERROR(va_st)) {
            Print((CHAR16*)L"  WARNING: VA-change event registration failed: 0x%lx\r\n", va_st);
            // Continue anyway: in the SAFE build nothing depends on it;
            // in the RT build the hooks simply never get installed.
        }
    }

    // Milestone 1: everything installed, variable published.
    DiagSetStage(kDiagStageLoaded);
    DiagSetFlag(kDiagFlagLoaded);
    g_diag_hook_calls = 0;
    DiagWrite();

    Print((CHAR16*)L"  SUCCESS: Bridge ready. Returning to boot menu.\r\n");
    Print((CHAR16*)L"  When you boot to Windows, Infinity.exe will detect\r\n");
    Print((CHAR16*)L"  the bridge and use it automatically.\r\n");

    // Show the blue banner briefly, then return to the EFI Shell.
    // This image is a UEFI Runtime Driver: it stays resident after
    // efi_main returns, so the EBS hook and (RT build) the gRT hooks
    // remain armed for the OS boot.
    gBS->Stall(3 * 1000000);  // 3 seconds
    SerialTrace::Line("MAIN", "efi_main returning to shell");
    return EFI_SUCCESS;
}
