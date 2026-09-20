#!/usr/bin/env python3
"""
patch-v12.py — apply the v12 OBSERVABILITY change set onto the
reconstructed v7 driver source tree.

PREREQUISITE (built by scripts/build-v12.sh):
    <tree>  =  repo fulken/Infinity @ a8e41b3  +  patches/v7-on-a8e41b3.diff
              (i.e. the exact source that produced the v7 binaries)

WHY v12 EXISTS (the v11 lesson):
    The v11 run (v9 package + trigger-test-v11.ps1) was 100% clean but
    could not attribute the desktop paths: v8's persist policy made
    INFDIAG a STALE snapshot (written only at load / EBS / VA-event),
    so hook_calls stayed frozen at 151 across every script step even
    if calls had arrived. The ONLY hard facts were: NVRAM landing
    works, no response served. Which path (read / write) bypasses our
    hooks stayed UNKNOWN. v12 makes every signal observable.

v12 = v7 base + v8's PROVEN counter policy + v12 observability layer:

  (1) HookEnter counter is CUMULATIVE from load (v8 binary evidence:
      trace numbers ran 1..192 continuously across the virtual-mode
      boundary; INFDIAG at the VA event already carried all 151
      boot-context + winload calls). Boot-context calls are still
      TRACED as BOOT-CTX but now also advance the counter. The
      per-64th VIRT traces gain the " VIRT" suffix (matches the v8
      boot log format). The DiagWrite() call inside HookEnter is
      REMOVED (v8 removed it — that removal is what froze INFDIAG).
  (2) READ-PATH ATTRIBUTION: every INFDIAG read (post-virtual only)
      first persists the LIVE state (DiagWrite freshen), so INFDIAG
      reads return fresh counter/flags instead of the stale snapshot.
      Bonus: each freshen prints a [INF][DIAG] serial line, so the
      serial log alone proves whether desktop reads reach the hook.
  (3) WRITE-PATH ATTRIBUTION: our-namespace SetVariable calls (incl.
      INFTRIGGER, newly added to IsOurVariable) set the 0x20 trigger
      flag, print an unbounded "S OURVAR write/delete" serial trace,
      bump g_diag_req_count, persist it as a REAL NVRAM variable
      INFCNT through the ORIGINAL SetVariable (readable by the script
      no matter which read path Windows uses), and persist INFDIAG.
  (4) our-namespace GetVariable reads print "G OURVAR read".
  (5) INFTRIGGER is accepted by HandleOurSetVariable (probe target).
  INFDIAG / INFCNT are deliberately NOT in IsOurVariable: they must
  chain to the original so raw NVRAM read-back keeps working.

EXPECTED SIGNATURES (trigger-test-v12.ps1):
  both paths work : hook_moves, INFCNT=2, flags 0x2B, Resp ANSWERED
  read works only : hook_moves, INFCNT absent, flags 0xB, Resp absent
  write works only: hook frozen, INFCNT=2, flags 0x2B (in F read),
                    Resp absent (nothing processed)
  both bypassed   : hook frozen, INFCNT absent, flags 0xB, Resp absent

Every edit below is anchored to EXACT v7 source text (verified against
patches/v7-on-a8e41b3.diff). An anchor that does not match exactly once
= FAIL LOUD with exit 1 and NO files modified.
"""
import sys
from pathlib import Path

MARKER = "memory.efi v12"


def fail(edit_id: str, why: str) -> None:
    print(f"[patch-v12] FAIL  {edit_id}: {why}")
    print("[patch-v12] The tree is NOT modified. If an anchor text differs,")
    print("[patch-v12] compare it against patches/v7-on-a8e41b3.diff and")
    print("[patch-v12] update the anchor in this script.")
    sys.exit(1)


def apply_edit(files: dict, edit_id: str, rel: str, old: str, new: str) -> None:
    """Replace `old` with `new` in files[rel]; old must occur exactly once."""
    text = files[rel]
    n = text.count(old)
    if n != 1:
        fail(edit_id, f"anchor occurs {n} times (need exactly 1) in {rel}")
    files[rel] = text.replace(old, new)
    print(f"[patch-v12] ok    {edit_id}  ({rel})")


def main() -> None:
    if len(sys.argv) != 2:
        print(f"usage: {sys.argv[0]} <repo-tree-root>")
        print("       tree must be a8e41b3 + v7-on-a8e41b3.diff applied")
        sys.exit(2)
    root = Path(sys.argv[1])
    rh = root / "UEFI" / "include" / "RuntimeHook.h"
    dg = root / "UEFI" / "include" / "Diag.h"
    for p in (rh, dg):
        if not p.is_file():
            fail("PRE", f"missing {p}")

    files = {
        "RuntimeHook.h": rh.read_text(encoding="utf-8"),
        "Diag.h": dg.read_text(encoding="utf-8"),
    }
    if MARKER in files["RuntimeHook.h"]:
        print("[patch-v12] tree already carries the v12 marker — refusing "
              "to patch twice. Re-prepare a fresh v7 tree first.")
        sys.exit(1)

    # ================= Diag.h =================

    # D1: trigger-seen flag (v8 semantics, named constant for v12)
    apply_edit(
        files, "D1", "Diag.h",
        old="    kDiagFlagEarlyHooks  = 0x8,   // v7: gRT hooks installed at load time\n",
        new=("    kDiagFlagEarlyHooks  = 0x8,   // v7: gRT hooks installed at load time\n"
             "    kDiagFlagTriggerSeen = 0x20,  // v8/v12: our-namespace write seen by hook\n"),
    )

    # D2: our-namespace write counter (mirrored to the INFCNT variable)
    apply_edit(
        files, "D2", "Diag.h",
        old="inline UINT32 g_diag_last_status = 0;\n",
        new=("inline UINT32 g_diag_last_status = 0;\n"
             "\n"
             "// v12: our-namespace SetVariable calls that reached the hook\n"
             "// after virtual mode (InfinityReq / InfinityResp / INFTRIGGER\n"
             "// with non-empty data). Mirrored to the INFCNT NVRAM variable\n"
             "// via the ORIGINAL SetVariable (RuntimeHook::WriteReqCount).\n"
             "inline UINT32 g_diag_req_count = 0;\n"),
    )

    # ================= RuntimeHook.h =================

    # R1: HookEnter — cumulative counter (v8 policy), VIRT suffix,
    #     NO DiagWrite (the removal is what un-blinds the desktop).
    apply_edit(
        files, "R1", "RuntimeHook.h",
        old=(
            "        static void HookEnter(char service) {\n"
            "            // v7: boot-context calls (pre-VA: shell, bootmgr, winload)\n"
            "            // are passthroughs — trace the first few, count them, but\n"
            "            // never touch the stage ladder or the persisted hook_calls.\n"
            "            if (!g_diag_va_done) {\n"
            "                UINT32 bn = ++g_diag_boot_calls;\n"
            "                if (bn <= 8) {\n"
            "                    SerialTrace::Begin(\"HOOK\");\n"
            "                    SerialTrace::Putc(service);\n"
            "                    SerialTrace::Puts(\" BOOT-CTX call#\");\n"
            "                    SerialTrace::Dec(bn);\n"
            "                }\n"
            "                return;\n"
            "            }\n"
            "\n"
            "            UINT32 n = ++g_diag_hook_calls;\n"
            "            bool first = (g_diag_stage != kDiagStageHookCalled);\n"
            "            if (first) {\n"
            "                g_diag_stage = kDiagStageHookCalled;\n"
            "            }\n"
            "            if (n <= 8 || (n & 63) == 0) {\n"
            "                SerialTrace::Begin(\"HOOK\");\n"
            "                SerialTrace::Putc(service);\n"
            "                SerialTrace::Puts(\" call#\");\n"
            "                SerialTrace::Dec(n);\n"
            "                if (first) SerialTrace::Puts(\" FIRST\");\n"
            "            }\n"
            "            // Persist the milestone. Flash wear is bounded the same way\n"
            "            // as the traces; last write carries the final counter.\n"
            "            if (n <= 4 || first || (n & 63) == 0) {\n"
            "                DiagWrite();\n"
            "            }\n"
            "        }\n"
        ),
        new=(
            "        static void HookEnter(char service) {\n"
            "            // v12: ONE cumulative counter from driver load (v8\n"
            "            // binary evidence: trace numbers 1..192 ran\n"
            "            // continuously across the virtual-mode boundary and\n"
            "            // INFDIAG at the VA event already carried all 151\n"
            "            // boot-context + winload calls). Boot-context calls\n"
            "            // are still TRACED as BOOT-CTX (never touching the\n"
            "            // stage ladder) but now also advance the counter, so\n"
            "            // the desktop can observe total traffic.\n"
            "            UINT32 n = ++g_diag_hook_calls;\n"
            "            if (!g_diag_va_done) {\n"
            "                if (n <= 8 || (n & 63) == 0) {\n"
            "                    SerialTrace::Begin(\"HOOK\");\n"
            "                    SerialTrace::Putc(service);\n"
            "                    SerialTrace::Puts(\" BOOT-CTX call#\");\n"
            "                    SerialTrace::Dec(n);\n"
            "                }\n"
            "                return;\n"
            "            }\n"
            "\n"
            "            bool first = (g_diag_stage != kDiagStageHookCalled);\n"
            "            if (first) {\n"
            "                g_diag_stage = kDiagStageHookCalled;\n"
            "            }\n"
            "            if (n <= 8 || (n & 63) == 0) {\n"
            "                SerialTrace::Begin(\"HOOK\");\n"
            "                SerialTrace::Putc(service);\n"
            "                SerialTrace::Puts(\" call#\");\n"
            "                SerialTrace::Dec(n);\n"
            "                if (first) SerialTrace::Puts(\" FIRST\");\n"
            "                SerialTrace::Puts(\" VIRT\");\n"
            "            }\n"
            "            // v12: NO DiagWrite here. v8 removed it, and that\n"
            "            // removal is exactly what blinded the v11 run: INFDIAG\n"
            "            // became a stale snapshot of the last stage\n"
            "            // transition. Live state is now persisted at the v12\n"
            "            // freshen points instead: INFDIAG reads (see\n"
            "            // HookedGetVariable) and our-namespace writes (see\n"
            "            // HookedSetVariable).\n"
            "        }\n"
        ),
    )

    # R2: HookedGetVariable — INFDIAG read-freshen + our-var read trace
    apply_edit(
        files, "R2", "RuntimeHook.h",
        old=(
            "            HookEnter('G');\n"
            "            if (instance_ && instance_->IsOurVariable(var_name, vendor_guid)) {\n"
            "                EFI_STATUS s = instance_->HandleOurGetVariable(\n"
            "                    var_name, attrs, data_size, data);\n"
            "                HookChainResult('G', s);\n"
            "                return s;\n"
            "            }\n"
        ),
        new=(
            "            HookEnter('G');\n"
            "\n"
            "            // v12 READ-PATH ATTRIBUTION: an INFDIAG read first\n"
            "            // persists the LIVE state, so the reader observes the\n"
            "            // current counter/flags instead of the stale\n"
            "            // stage-transition snapshot that blinded v11. Gated\n"
            "            // on virtual mode so boot-time reads (shell dmpstore\n"
            "            // in phase-b-check) keep their old semantics and\n"
            "            // flash wear stays bounded. DiagWrite is busy-latched:\n"
            "            // its own SetVariable chains to the original inside\n"
            "            // HookedSetVariable, and that path never re-enters\n"
            "            // HookEnter, so the counter arithmetic stays clean.\n"
            "            if (g_diag_va_done && instance_ && var_name &&\n"
            "                StrCmp(var_name, (CHAR16*)L\"INFDIAG\") == 0) {\n"
            "                DiagWrite();\n"
            "            }\n"
            "\n"
            "            if (instance_ && instance_->IsOurVariable(var_name, vendor_guid)) {\n"
            "                // v12: our-namespace reads are rare (only the\n"
            "                // test script issues them) — trace every one,\n"
            "                // unbounded.\n"
            "                SerialTrace::Line(\"HOOK\", \"G OURVAR read\");\n"
            "                EFI_STATUS s = instance_->HandleOurGetVariable(\n"
            "                    var_name, attrs, data_size, data);\n"
            "                HookChainResult('G', s);\n"
            "                return s;\n"
            "            }\n"
        ),
    )

    # R3: HookedSetVariable — our-var write attribution block
    apply_edit(
        files, "R3", "RuntimeHook.h",
        old=(
            "            HookEnter('S');\n"
            "            if (instance_ && instance_->IsOurVariable(var_name, vendor_guid)) {\n"
            "                EFI_STATUS s = instance_->HandleOurSetVariable(\n"
            "                    var_name, attrs, data_size, data);\n"
            "                HookChainResult('S', s);\n"
            "                return s;\n"
            "            }\n"
        ),
        new=(
            "            HookEnter('S');\n"
            "            if (instance_ && instance_->IsOurVariable(var_name, vendor_guid)) {\n"
            "                // v12 WRITE-PATH ATTRIBUTION: our-namespace writes\n"
            "                // are rare (only the test script issues them), so\n"
            "                // every one is traced unbounded, the trigger flag\n"
            "                // is set, the INFCNT counter is bumped + persisted\n"
            "                // through the ORIGINAL SetVariable (a REAL NVRAM\n"
            "                // variable — readable by the script no matter which\n"
            "                // read path Windows uses), and live INFDIAG state\n"
            "                // is persisted — all BEFORE the handler runs, so\n"
            "                // even a handler fault leaves the attribution\n"
            "                // signals behind.\n"
            "                SerialTrace::Line(\"HOOK\",\n"
            "                    (data && data_size > 0) ?\n"
            "                        \"S OURVAR write\" : \"S OURVAR delete\");\n"
            "                DiagSetFlag(kDiagFlagTriggerSeen);\n"
            "                if (g_diag_va_done) {\n"
            "                    if (data && data_size > 0) {\n"
            "                        g_diag_req_count++;\n"
            "                        WriteReqCount();\n"
            "                    }\n"
            "                    DiagWrite();\n"
            "                }\n"
            "                EFI_STATUS s = instance_->HandleOurSetVariable(\n"
            "                    var_name, attrs, data_size, data);\n"
            "                HookChainResult('S', s);\n"
            "                return s;\n"
            "            }\n"
        ),
    )

    # R4: WriteReqCount helper (private static, uses orig pointer)
    apply_edit(
        files, "R4", "RuntimeHook.h",
        old=(
            "    private:\n"
            "        // Serial trace on hook entry. Bounded: the first 8 calls of a\n"
        ),
        new=(
            "    private:\n"
            "        // v12: persist the our-namespace write counter as a REAL\n"
            "        // NVRAM variable (INFCNT) through the ORIGINAL SetVariable.\n"
            "        // Unlike INFDIAG (whose desktop read path is the thing\n"
            "        // under test), INFCNT lands in NVRAM no matter which path\n"
            "        // Windows uses — the script can always observe it. The\n"
            "        // write status is serial-traced (post-VM NVRAM writes can\n"
            "        // silently fail — the v5 lesson — so the serial line is\n"
            "        // the ground truth, the variable is the convenience).\n"
            "        static void WriteReqCount() {\n"
            "            if (!instance_ || !instance_->orig_set_variable_) return;\n"
            "            UINT32 v = g_diag_req_count;\n"
            "            EFI_STATUS s = instance_->orig_set_variable_(\n"
            "                (CHAR16*)L\"INFCNT\", &gInfinityMemVarGuid,\n"
            "                EFI_VARIABLE_NON_VOLATILE |\n"
            "                    EFI_VARIABLE_BOOTSERVICE_ACCESS |\n"
            "                    EFI_VARIABLE_RUNTIME_ACCESS,\n"
            "                sizeof(v), &v);\n"
            "            SerialTrace::Begin(\"HOOK\");\n"
            "            SerialTrace::Puts(\"INFCNT write \");\n"
            "            SerialTrace::Dec(v);\n"
            "            SerialTrace::Puts(\" st=0x\");\n"
            "            SerialTrace::Hex32((UINT32)s);\n"
            "        }\n"
            "\n"
            "        // Serial trace on hook entry. Bounded: the first 8 calls of a\n"
        ),
    )

    # R5: INFTRIGGER joins the our-namespace list (INFDIAG / INFCNT stay out)
    apply_edit(
        files, "R5", "RuntimeHook.h",
        old=(
            "            if (StrCmp(name, (CHAR16*)L\"InfinityReq\")  == 0) return TRUE;\n"
            "            if (StrCmp(name, (CHAR16*)L\"InfinityResp\") == 0) return TRUE;\n"
            "            if (StrCmp(name, (CHAR16*)L\"InfinityData\") == 0) return TRUE;\n"
        ),
        new=(
            "            if (StrCmp(name, (CHAR16*)L\"InfinityReq\")  == 0) return TRUE;\n"
            "            if (StrCmp(name, (CHAR16*)L\"InfinityResp\") == 0) return TRUE;\n"
            "            if (StrCmp(name, (CHAR16*)L\"InfinityData\") == 0) return TRUE;\n"
            "            // v12: INFTRIGGER is also ours (script trigger probe).\n"
            "            // INFDIAG / INFCNT are deliberately NOT ours: they must\n"
            "            // chain to the original so raw NVRAM read-back keeps\n"
            "            // working for the script.\n"
            "            if (StrCmp(name, (CHAR16*)L\"INFTRIGGER\")  == 0) return TRUE;\n"
        ),
    )

    # R6: HandleOurSetVariable accepts INFTRIGGER (probe target)
    apply_edit(
        files, "R6", "RuntimeHook.h",
        old=(
            "                last_data_size_ = data_size;\n"
            "                return EFI_SUCCESS;\n"
            "            }\n"
            "            return EFI_NOT_FOUND;\n"
        ),
        new=(
            "                last_data_size_ = data_size;\n"
            "                return EFI_SUCCESS;\n"
            "            }\n"
            "\n"
            "            // v12: INFTRIGGER — the script's trigger probe. The\n"
            "            // trigger flag and INFCNT were already set by the\n"
            "            // caller (HookedSetVariable); accept the write and\n"
            "            // store nothing.\n"
            "            if (StrCmp(var_name, (CHAR16*)L\"INFTRIGGER\") == 0) {\n"
            "                if (!data || data_size < 1) {\n"
            "                    return EFI_INVALID_PARAMETER;\n"
            "                }\n"
            "                return EFI_SUCCESS;\n"
            "            }\n"
            "\n"
            "            return EFI_NOT_FOUND;\n"
        ),
    )

    # R7: version strings — boot-log identification (grep-able)
    apply_edit(
        files, "R7", "RuntimeHook.h",
        old="            SerialTrace::Line(\"RT-VA\", \"hooks already installed at load (v7 early) - keeping slots\");\n",
        new="            SerialTrace::Line(\"RT-VA\", \"hooks already installed at load (v12 early) - keeping slots\");\n",
    )
    apply_edit(
        files, "R8", "RuntimeHook.h",
        old="            SerialTrace::Line(\"RT-EARLY\", \"gRT hooks INSTALLED at load time (pre-snapshot; Windows-visible)\");\n",
        new=(
            "            SerialTrace::Line(\"RT-EARLY\", \"" + MARKER + " RT (observability build)\");\n"
            "            SerialTrace::Line(\"RT-EARLY\", \"gRT hooks INSTALLED at load time (pre-snapshot; Windows-visible)\");\n"
        ),
    )

    # ---- write results only after every edit succeeded ----
    rh.write_text(files["RuntimeHook.h"], encoding="utf-8")
    dg.write_text(files["Diag.h"], encoding="utf-8")
    print("[patch-v12] ALL EDITS APPLIED — tree is now v12")
    print("[patch-v12] changed: UEFI/include/RuntimeHook.h, UEFI/include/Diag.h")
    print("[patch-v12] next: make (SAFE) and make RT=1 (RT) in UEFI/build")


if __name__ == "__main__":
    main()
