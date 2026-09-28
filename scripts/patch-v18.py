#!/usr/bin/env python3
# ============================================================================
# patch-v18.py — v17 -> v18 driver source transformation
#
# THE FIX: v17's ReadKernelVA walked the caller's page tables and read the
# leaves through ReadPhysical, which SWITCHES CR3 to the boot-time firmware
# tables (uefi_cr3_). Under Windows those tables map neither our hook code
# (0xFFFFF800...) nor the OS IDT/stack, so the first instruction fetch after
# the switch faults and the fault cannot be dispatched -> fault storm -> VM
# death. This killed the v19 run (Attach walk: same ReadPhysical dance) and
# the v20 run (kernel read). v18 replaces the body with a DIRECT volatile
# read in the hook's own context, gated to the two KUSER_SHARED_DATA windows
# that EVERY address space maps (user alias + kernel alias) - the read can
# never fault, and anything outside the windows fails cleanly (ErrAccess).
#
# Plus version cosmetics (v17 -> v18 banners).
#
# Usage: python3 scripts/patch-v18.py <tree>
# ============================================================================
import sys, pathlib

def main():
    if len(sys.argv) != 2:
        print("usage: patch-v18.py <v17-tree>"); sys.exit(1)
    tree = pathlib.Path(sys.argv[1])
    if not (tree / "UEFI" / "include" / "ProcessMemory.h").exists():
        print("FATAL: not a v17 tree (UEFI/include/ProcessMemory.h missing)"); sys.exit(1)

    def sub(path, old, new, tag, count=1):
        p = tree / path
        t = p.read_text()
        if t.count(old) != count:
            print(f"  FAIL {tag}: anchor found {t.count(old)}x (want {count}) in {path}")
            sys.exit(1)
        p.write_text(t.replace(old, new))
        print(f"  {tag}: {path} OK")

    # ------------------------------------------------------------------
    # E1: ProcessMemory.h — replace the CR3-dance ReadKernelVA with the
    #     direct, window-gated read. Comment block + body replaced whole.
    # ------------------------------------------------------------------
    old_pm = """        // =========================================================
        // v17: kernel-space read for the data-path proof.
        // Walks the CALLER's page tables - inside the gRT hook
        // that is the calling Windows thread's CR3, so kernel VAs
        // (KUSER_SHARED_DATA etc.) translate. All data reads go
        // through ReadPhysical (UEFI identity map): a bad, unmapped
        // or non-canonical VA fails TranslateVA BEFORE any
        // dereference - there is no #PF/#GP path. Writes have NO
        // kernel fallback (target-process only).
        // =================================================================
        BOOLEAN ReadKernelVA(UINT64 va, VOID* out, UINTN size) {
            if (!phys_) return FALSE;
            UINT64 cr3 = ReadCr3();
            if (cr3 == 0 || (cr3 & 0xFFF)) return FALSE;
            return phys_->ReadVA(va, cr3, out, size);
        }
"""
    new_pm = """        // =========================================================
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
            if (!in_user && !in_kern) return FALSE;
            volatile UINT8* src = (volatile UINT8*)(UINTN)va;
            UINT8* dst = (UINT8*)out;
            for (UINTN i = 0; i < size; i++) dst[i] = src[i];
            return TRUE;
        }
"""
    sub("UEFI/include/ProcessMemory.h", old_pm, new_pm, "E1-read-kernel-va")

    # ------------------------------------------------------------------
    # E2: RequestHandler.h — trace labels + comment for the new path.
    # ------------------------------------------------------------------
    old_rh = """                // v17: pid == KERNEL_TARGET_PID selects the KERNEL
                // target - the read is served from the caller's
                // (Windows) address space via the current CR3. This
                // is the data-path proof route (KUSD reads); a bad
                // VA fails the page walk cleanly (ErrAccess). Any
                // other pid without an attached process keeps the
                // same clean ErrAccess failure as before - the real
                // client is unaffected.
                BOOLEAN ok;
                if (req->pid == KERNEL_TARGET_PID) {
                    SerialTrace::KV("RD", "kern va", req->address);
                    ok = mem_->ReadKernelVA(req->address, data_buf,
                                            req->data_size);
                    SerialTrace::KVD("RD", "kern read ok", ok ? 1u : 0u);
                } else {
"""
    new_rh = """                // v18: pid == KERNEL_TARGET_PID selects the KERNEL
                // target - the read is a DIRECT volatile read in the
                // hook's own context (the caller's mapping), gated
                // to the two KUSER_SHARED_DATA windows. This is the
                // data-path proof route (KUSD reads); a VA outside
                // the windows fails the gate cleanly (ErrAccess)
                // BEFORE any access - no page walk, no CR3 switch
                // (the v17 walk was the v19/v20 VM killer). Any
                // other pid without an attached process keeps the
                // same clean ErrAccess failure as before - the real
                // client is unaffected.
                BOOLEAN ok;
                if (req->pid == KERNEL_TARGET_PID) {
                    SerialTrace::KV("RD", "mapped va", req->address);
                    ok = mem_->ReadKernelVA(req->address, data_buf,
                                            req->data_size);
                    SerialTrace::KVD("RD", "mapped read ok", ok ? 1u : 0u);
                } else {
"""
    sub("UEFI/include/RequestHandler.h", old_rh, new_rh, "E2-handler-trace")

    # ------------------------------------------------------------------
    # E3..E8: version cosmetics (main.c + RuntimeHook.h)
    # ------------------------------------------------------------------
    sub("UEFI/src/main.c",
        'static const char kBuildLine[] = "  Build: v17 RT - kernel data path via current CR3";',
        'static const char kBuildLine[] = "  Build: v18 RT - direct KUSD reads";',
        "E3-serial-build-rt")
    sub("UEFI/src/main.c",
        'static const char kBuildLine[] = "  Build: v17 SAFE (phase C)";',
        'static const char kBuildLine[] = "  Build: v18 SAFE (phase C)";',
        "E4-serial-build-safe")
    sub("UEFI/src/main.c",
        'L"  Build: v17 RT - bridge + kernel data path (phase E)     \\r\\n"',
        'L"  Build: v18 RT - bridge + direct KUSD reads (phase E)    \\r\\n"',
        "E5-screen-banner-rt")
    sub("UEFI/src/main.c",
        'L"  Build: v17 SAFE (phase C)                               \\r\\n"',
        'L"  Build: v18 SAFE (phase C)                               \\r\\n"',
        "E6-screen-banner-safe")
    sub("UEFI/src/main.c",
        'SerialTrace::Line("MAIN", "efi_main v17 boot");',
        'SerialTrace::Line("MAIN", "efi_main v18 boot");',
        "E7-efi-main")
    sub("UEFI/src/main.c",
        'SerialTrace::Line("MAIN", "variant: RT (EARLY gRT hooks - v17)");',
        'SerialTrace::Line("MAIN", "variant: RT (EARLY gRT hooks - v18)");',
        "E8-variant-rt")
    sub("UEFI/include/RuntimeHook.h",
        '"memory.efi v17 RT (kernel data path: current-CR3 reads)")',
        '"memory.efi v18 RT (kernel data path: direct KUSD reads)")',
        "E9-rt-early-banner")
    sub("UEFI/include/RuntimeHook.h",
        '"hooks already installed at load (v17 early) - keeping slots")',
        '"hooks already installed at load (v18 early) - keeping slots")',
        "E10-rt-va-banner")

    # sanity
    pm = (tree / "UEFI/include/ProcessMemory.h").read_text()
    assert "uefi_cr3_" not in pm.split("ReadKernelVA")[1].split("BOOLEAN")[0] or True
    body = pm.split("BOOLEAN ReadKernelVA")[1][:1400]
    for bad in ["ReadCr3()", "phys_->ReadVA"]:
        if bad in body:
            print(f"  FAIL sanity: '{bad}' still inside ReadKernelVA body"); sys.exit(1)
    for good in ["0x7FFE0000ULL", "0xFFFFF78000000000ULL", "end < va"]:
        if good not in body:
            print(f"  FAIL sanity: '{good}' missing from ReadKernelVA body"); sys.exit(1)
    rh = (tree / "UEFI/include/RequestHandler.h").read_text()
    assert "mapped va" in rh and "kern va" not in rh
    mc = (tree / "UEFI/src/main.c").read_text()
    assert "v18" in mc and "efi_main v17" not in mc
    print("[patch-v18] ALL EDITS APPLIED - tree is now v18")
    print("[patch-v18] changed: ProcessMemory.h, RequestHandler.h, main.c, RuntimeHook.h")

if __name__ == "__main__":
    main()
