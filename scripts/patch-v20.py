#!/usr/bin/env python3
# ============================================================================
# patch-v20.py — v19 -> v20 driver source transformation (Phase F2 entry)
#
# WHAT HAPPENED IN THE FIELD (v25 run, 2026-09-26):
#   The anchors were perfect (SIDT -> IDT base 0xFFFFF8047246C000, real
#   #PF/#BP handler VAs, real LSTAR), all three walks converged — but on
#   0xFFFFF8046BD60000, a structurally-valid PE that does NOT contain
#   the anchors (they sit +0x2AB540..+0x2B1C00 above it). WalkBackToPE
#   accepted the FIRST valid PE below the anchor instead of the first
#   CONTAINING one -> V4 containment backstop fired (reason=6) -> clean
#   fail-closed. The safety contract held; the discovery just stopped
#   at a nested/in-between PE (host-test T8's exact trap, for real).
#
# WHAT v20 CHANGES (one surgical rule + observability; everything else
# byte-equivalent strategy):
#   KernelAnchor.h — THE CONTAINING-WALK: a walk candidate is accepted
#     ONLY if [base, base+SizeOfImage) CONTAINS the anchor VA it was
#     walked from. Valid-but-not-containing PEs are skipped, COUNTED
#     (per-walk skip counter + last-skipped base, new Result fields,
#     new [AN] serial lines) and the walk continues down. The 512-step
#     / 32 MB hard bound, V1/V2/V3 convergence and V4 structural +
#     containment validation are UNCHANGED (containment becomes a
#     TOCTOU/defense-in-depth backstop: per-walk acceptance already
#     guarantees it on the fast path). The op-9 32-byte wire payload
#     is UNCHANGED (v25/v26 script compatible).
#     Probe-safety note: on the walk path every probe page lies inside
#     the anchor's own mapped image (the containing base terminates the
#     walk); the skip path only continues inside the TRUE image's span
#     (a skipped nested PE is by construction inside the same image
#     that contains the anchor). Same envelope as v19's walkbound case.
#   main.c / RuntimeHook.h — v20 banners/markers only.
#
# Semantics that shift (documented, host-tested):
#   - anchor ABOVE its image end (T5 class): was Contain(6) at V4, now
#     the containing-walk finds no container -> WalkBound1/2/3 (still
#     fail-closed, just a more honest reason).
#   - nested PE below the anchors (T8 class = THE FIELD CASE): was
#     Contain(6), now the nested PE is skipped and the walks converge
#     on the TRUE containing image -> gate OPENS on the right range.
#   - KNOWN CORNER (host-test T10, documented): a nested PE whose range
#     COVERS all three anchors is accepted (first-hit-wins). The opened
#     range is still a fully-validated PE containing every anchor — the
#     safe-subset contract holds; outermost-preference is deliberately
#     NOT attempted (walking below an accepted base can exit mapped
#     memory = #PF risk; that needs F4's page-table validation).
#
# Usage: python3 scripts/patch-v20.py <v19-tree>
# ============================================================================
import sys, pathlib

def main():
    if len(sys.argv) != 2:
        print("usage: patch-v20.py <v19-tree>")
        sys.exit(1)
    tree = pathlib.Path(sys.argv[1])
    pm = tree / "UEFI/include/ProcessMemory.h"
    rh = tree / "UEFI/include/RequestHandler.h"
    mc = tree / "UEFI/src/main.c"
    hk = tree / "UEFI/include/RuntimeHook.h"
    ka = tree / "UEFI/include/KernelAnchor.h"
    for p in (pm, rh, mc, hk, ka):
        if not p.exists():
            print(f"FATAL: not a v19 tree ({p} missing)")
            sys.exit(1)

    def sub(path, old, new, tag, count=1):
        t = path.read_text(encoding="utf-8")
        if t.count(old) != count:
            print(f"  FAIL {tag}: anchor found {t.count(old)}x (want {count}) in {path.name}")
            sys.exit(1)
        path.write_text(t.replace(old, new), encoding="utf-8")
        print(f"  {tag}: {path.name} OK")

    # ------------------------------------------------------------------
    # W1: KernelAnchor.h — the containing-walk
    # ------------------------------------------------------------------
    sub(ka,
        """    // ================= the walk (V1/V2/V3 core) =================
    // From a trusted kernel-text VA, step DOWN in 64 KB units at most
    // 512 steps (32 MB). Each probe reads ONE 2-byte 'MZ'; candidates
    // are fully PE-validated before acceptance. No valid PE inside the
    // bound => 0 (the caller fails closed).
    static inline u64 WalkBackToPE(u64 text_va) {
        u64 page = text_va & ~0xFFFFULL;
        for (u32 i = 0; i < 512u; i++, page -= 0x10000ULL) {
            if (AN_R16(page) != 0x5A4Du) continue;
            PEInfo p = ValidatePEAt(page);
            if (p.ok) return p.base;
        }
        return 0;
    }
""",
        """    // ================= the walk (V1/V2/V3 core) =================
    // From a trusted kernel-text VA, step DOWN in 64 KB units at most
    // 512 steps (32 MB). Each probe reads ONE 2-byte 'MZ'; candidates
    // are fully PE-validated before acceptance.
    //
    // v20 (F2) CONTAINING-WALK: a candidate is accepted ONLY if the
    // image range [base, base+SizeOfImage) CONTAINS the anchor VA it
    // was walked from. Structurally-valid PEs that do NOT contain the
    // anchor (nested PEs / unrelated images between the anchor and the
    // true base — the exact trap the v25 field run hit) are SKIPPED,
    // counted, and the walk continues DOWN. No containing PE inside
    // the bound => 0 (the caller fails closed).
    //   KNOWN CORNER: a nested PE whose range covers the anchor is
    //   accepted (first-hit-wins). The accepted range is still a fully
    //   validated PE containing the anchor — the safe-subset contract
    //   holds. (Outermost-preference would require probing below an
    //   accepted base, which can exit mapped memory: #PF risk. That
    //   needs F4 page-table validation, not a walk rule.)
    //   PROBE SAFETY: every probe page on the path lies inside the
    //   anchor's own mapped image (the containing base terminates the
    //   walk); skips only continue inside the same containing image.
    static inline u64 WalkBackToPE(u64 text_va, u32* skips, u64* last_skip) {
        u64 page = text_va & ~0xFFFFULL;
        u32 n = 0;
        u64 last = 0;
        for (u32 i = 0; i < 512u; i++, page -= 0x10000ULL) {
            if (AN_R16(page) != 0x5A4Du) continue;
            PEInfo p = ValidatePEAt(page);
            if (p.ok) {
                if (text_va >= p.base &&
                    text_va <  p.base + p.size_image) {
                    if (skips) *skips = n;
                    if (last_skip) *last_skip = last;
                    return p.base;              // the containing image
                }
                n++;                            // valid, not containing
                last = p.base;                  // (nested / in-between)
            }
        }
        if (skips) *skips = n;
        if (last_skip) *last_skip = last;
        return 0;
    }
""",
        "W1-containing-walk")

    # ------------------------------------------------------------------
    # W2: KernelAnchor.h — Result gains the per-walk skip observability
    # ------------------------------------------------------------------
    sub(ka,
        """    struct Result {
        u32 state;                   // kAnchor*
        u32 reason;                  // kAnReason*
        u64 idt_base;
        u64 lstar;
        u64 walk_v1, walk_v2, walk_v3;
        u64 pe_base, pe_size;
    };
""",
        """    struct Result {
        u32 state;                   // kAnchor*
        u32 reason;                  // kAnReason*
        u64 idt_base;
        u64 lstar;
        u64 walk_v1, walk_v2, walk_v3;
        u64 pe_base, pe_size;
        u32 v1_skips, v2_skips, v3_skips;         // v20: skipped
        u64 v1_last_skip, v2_last_skip, v3_last_skip; // candidates
    };
""",
        "W2-result-skips")

    # ------------------------------------------------------------------
    # W3: KernelAnchor.h — DiscoverCore wires the skip out-params
    # ------------------------------------------------------------------
    sub(ka,
        """        r->walk_v1 = WalkBackToPE(pf_va);                  // V1: IDT #PF
""",
        """        r->walk_v1 = WalkBackToPE(pf_va, &r->v1_skips,      // V1: IDT #PF
                                  &r->v1_last_skip);
""",
        "W3a-walk-v1")
    sub(ka,
        """        r->walk_v2 = WalkBackToPE(bp_va);                  // V2: IDT #BP
""",
        """        r->walk_v2 = WalkBackToPE(bp_va, &r->v2_skips,      // V2: IDT #BP
                                  &r->v2_last_skip);
""",
        "W3b-walk-v2")
    sub(ka,
        """        r->walk_v3 = WalkBackToPE(lstar_va);               // V3: LSTAR
""",
        """        r->walk_v3 = WalkBackToPE(lstar_va, &r->v3_skips,   // V3: LSTAR
                                  &r->v3_last_skip);
""",
        "W3c-walk-v3")

    # ------------------------------------------------------------------
    # W4: KernelAnchor.h — header doc: the v20 refinement
    # ------------------------------------------------------------------
    sub(ka,
        """ *   A3  walk-back     — from each anchor VA, step DOWN in 64 KB units
 *                       (module bases are 64 KB aligned), at most 512
 *                       steps (32 MB), probing a single 2-byte 'MZ'
 *                       per candidate page, then FULLY validating the
 *                       PE header found at the candidate base
""",
        """ *   A3  walk-back     — from each anchor VA, step DOWN in 64 KB units
 *                       (module bases are 64 KB aligned), at most 512
 *                       steps (32 MB), probing a single 2-byte 'MZ'
 *                       per candidate page, then FULLY validating the
 *                       PE header found at the candidate base.
 *                       v20: the candidate is accepted only if the
 *                       image CONTAINS the anchor (the containing-walk
 *                       — nested/in-between PEs are skipped + counted;
 *                       the v25 field run proved the first-valid-PE
 *                       rule stops at the wrong image)
""",
        "W4-doc-a3")
    sub(ka,
        " * KernelAnchor.h  (UEFI side — NEW in v19 / Phase F1)\n",
        " * KernelAnchor.h  (UEFI side — v19 / F1; containing-walk v20 / F2)\n",
        "W4b-doc-title")

    # ------------------------------------------------------------------
    # W5: RequestHandler.h — [AN] skip traces (fail-closed walks now
    #     name exactly what they refused to trust)
    # ------------------------------------------------------------------
    sub(rh,
        """        SerialTrace::KV("AN", "walk v1", r.walk_v1);
        SerialTrace::KV("AN", "walk v2", r.walk_v2);
        SerialTrace::KV("AN", "walk v3", r.walk_v3);
""",
        """        SerialTrace::KV("AN", "walk v1", r.walk_v1);
        SerialTrace::KV("AN", "walk v2", r.walk_v2);
        SerialTrace::KV("AN", "walk v3", r.walk_v3);
        // v20: what each walk SKIPPED (valid PEs that did not contain
        // the anchor) — the fail-closed serial trace names the refusals
        if (r.v1_skips) {
            SerialTrace::KVD("AN", "walk v1 skipped", r.v1_skips);
            SerialTrace::KV("AN", "walk v1 lastskip", r.v1_last_skip);
        }
        if (r.v2_skips) {
            SerialTrace::KVD("AN", "walk v2 skipped", r.v2_skips);
            SerialTrace::KV("AN", "walk v2 lastskip", r.v2_last_skip);
        }
        if (r.v3_skips) {
            SerialTrace::KVD("AN", "walk v3 skipped", r.v3_skips);
            SerialTrace::KV("AN", "walk v3 lastskip", r.v3_last_skip);
        }
""",
        "W5-an-skip-traces")

    # ------------------------------------------------------------------
    # W6: main.c — v20 banners
    # ------------------------------------------------------------------
    sub(mc,
        'static const char kBuildLine[] = "  Build: v19 RT - anchors + validated image reads";',
        'static const char kBuildLine[] = "  Build: v20 RT - anchors + containing walk";',
        "W6a-build-rt")
    sub(mc,
        'static const char kBuildLine[] = "  Build: v19 SAFE (phase F1)";',
        'static const char kBuildLine[] = "  Build: v20 SAFE (phase F2)";',
        "W6b-build-safe")
    sub(mc,
        'Print((CHAR16*)L"  Build: v19 RT - anchors + validated image reads (F1)    \\r\\n");',
        'Print((CHAR16*)L"  Build: v20 RT - anchors + containing walk (F2)          \\r\\n");',
        "W6c-print-rt")
    sub(mc,
        'Print((CHAR16*)L"  Build: v19 SAFE (phase F1)                               \\r\\n");',
        'Print((CHAR16*)L"  Build: v20 SAFE (phase F2)                               \\r\\n");',
        "W6d-print-safe")
    sub(mc,
        'SerialTrace::Line("MAIN", "efi_main v19 boot");',
        'SerialTrace::Line("MAIN", "efi_main v20 boot");',
        "W6e-boot-line")
    sub(mc,
        'SerialTrace::Line("MAIN", "variant: RT (EARLY gRT hooks - v19)");',
        'SerialTrace::Line("MAIN", "variant: RT (EARLY gRT hooks - v20)");',
        "W6f-variant-line")

    # ------------------------------------------------------------------
    # W7: RuntimeHook.h — v20 markers
    # ------------------------------------------------------------------
    sub(hk,
        'SerialTrace::Line("RT-EARLY", "memory.efi v19 RT (kernel data path: direct reads + anchors)");',
        'SerialTrace::Line("RT-EARLY", "memory.efi v20 RT (kernel data path: direct reads + containing anchors)");',
        "W7a-rt-early")
    sub(hk,
        'SerialTrace::Line("RT-VA", "hooks already installed at load (v19 early) - keeping slots");',
        'SerialTrace::Line("RT-VA", "hooks already installed at load (v20 early) - keeping slots");',
        "W7b-rt-va")

    # ------------------------------------------------------------------
    # sanity: the tree must now be exactly v20
    # ------------------------------------------------------------------
    kat = ka.read_text(encoding="utf-8")
    for good in ["containing-walk", "v1_skips", "v1_last_skip",
                 "text_va <  p.base + p.size_image", "512u", "0x5A4Du",
                 "kAnReason_Contain"]:
        if good not in kat:
            print(f"  FAIL sanity: '{good}' missing from KernelAnchor.h")
            sys.exit(1)
    for bad in ["SerialTrace", "efi.h", "gBS"]:
        if bad in kat:
            print(f"  FAIL sanity: '{bad}' must NOT be in KernelAnchor.h (purity)")
            sys.exit(1)
    rht = rh.read_text(encoding="utf-8")
    for good in ["lastskip", "walk v1 skipped", "case 9",
                 "DiscoverAnchorsOnce", "put64(24, an.idt_base)"]:
        if good not in rht:
            print(f"  FAIL sanity: '{good}' missing from RequestHandler.h")
            sys.exit(1)
    mct = mc.read_text(encoding="utf-8")
    assert "v20" in mct and "v19" not in mct, "main.c banners incomplete"
    hkt = hk.read_text(encoding="utf-8")
    assert "v20 RT" in hkt and "v19 early" not in hkt, "RuntimeHook.h markers incomplete"
    pmt = pm.read_text(encoding="utf-8")
    for good in ["in_validated", "ka::kAnchorConverged"]:
        if good not in pmt:
            print(f"  FAIL sanity: '{good}' missing from ProcessMemory.h")
            sys.exit(1)
    print("[patch-v20] ALL EDITS APPLIED - tree is now v20")
    print("[patch-v20] changed: KernelAnchor.h, RequestHandler.h, main.c, RuntimeHook.h")
    print("[patch-v20] unchanged: ProcessMemory.h gate, op-9 wire payload")
    print("[patch-v20] next: host-test-v20, then make (SAFE) and make RT=1")


if __name__ == "__main__":
    main()
