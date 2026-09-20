#!/usr/bin/env python3
"""
patch-v13.py — turn the v7 source tree into the v13 source tree.

v13 = "safe observability" — the BSOD fix for the v12 freshen crash.

v12 field result (2026-09-20, infinity-qemu-test-v12-TestReport):
  * Boot chain fully green, v12 RT early hooks, stages 1..4, all
    ConvertPointers clean, kernel reached desktop.
  * Desktop INFDIAG read (script step A) REACHED HookedGetVariable
    (read path works!) — then the v12 "freshen" (a DiagWrite = an
    ORIGINAL SetVariable call from INSIDE the Windows GetVariable
    dispatch) crashed the kernel: KMODE_EXCEPTION_NOT_HANDLED, serial
    truncated mid-line at the DiagWrite print.
  * The script's 5 cleanup deletes on our-namespace names produced
    ZERO "S OURVAR" traces -> desktop SetVariable BYPASSES the hook.

v13 design (mechanism unchanged, observability made SAFE):
  D1  trigger-seen flag constant (as v12)
  D2  g_diag_req_count — RAM-only, no NVRAM mirror
  R1  cumulative HookEnter counter (as v12, no DiagWrite in hooks)
  R2  INFDIAG + INFCNT reads are SERVED FROM LIVE RAM in
      HookedGetVariable (GUID-checked, va_done-gated, standard
      GetVariable buffer protocol). NO original call, NO NVRAM
      write — the crash class is eliminated. Plus the unbounded
      "G OURVAR read" trace.
  R3  our-namespace SetVariable block: trace + flag + counter ONLY
      (RAM) — no WriteReqCount, no DiagWrite (both removed).
  R5  INFTRIGGER joins IsOurVariable (as v12)
  R6  HandleOurSetVariable accepts INFTRIGGER (as v12)
  R7/R8  v13 boot-log markers

Usage: python3 patch-v13.py <tree-root>
"""
import sys
import pathlib

MARKER = "memory.efi v13 RT (safe observability)"

def apply_edit(files, tag, fname, old, new):
    if old not in files[fname]:
        sys.exit(f"FATAL [{tag}]: anchor not found in {fname}:\n{old[:200]}")
    if files[fname].count(old) != 1:
        sys.exit(f"FATAL [{tag}]: anchor not unique in {fname}")
    files[fname] = files[fname].replace(old, new)
    print(f"[patch-v13] {tag}: {fname} OK")

def main():
    if len(sys.argv) != 2:
        sys.exit("usage: patch-v13.py <tree-root>")
    tree = pathlib.Path(sys.argv[1])
    rh = tree / "UEFI" / "include" / "RuntimeHook.h"
    dg = tree / "UEFI" / "include" / "Diag.h"
    files = {
        "RuntimeHook.h": rh.read_text(encoding="utf-8"),
        "Diag.h": dg.read_text(encoding="utf-8"),
    }

    # ================= Diag.h =================

    # D1: trigger-seen flag
    apply_edit(
        files, "D1", "Diag.h",
        old="    kDiagFlagEarlyHooks  = 0x8,   // v7: gRT hooks installed at load time\n",
        new=("    kDiagFlagEarlyHooks  = 0x8,   // v7: gRT hooks installed at load time\n"
             "    kDiagFlagTriggerSeen = 0x20,  // v8/v13: our-namespace write seen by hook\n"),
    )

    # D2: our-namespace write counter (RAM-only)
    apply_edit(
        files, "D2", "Diag.h",
        old="inline UINT32 g_diag_last_status = 0;\n",
        new=("inline UINT32 g_diag_last_status = 0;\n"
             "\n"
             "// v13: our-namespace SetVariable calls that reached the hook\n"
             "// after virtual mode (InfinityReq / INFTRIGGER with non-empty\n"
             "// data). RAM-ONLY on purpose — no NVRAM mirror, because calling\n"
             "// the original SetVariable from inside a hook at runtime is what\n"
             "// crashed the kernel in v12 (KMODE_EXCEPTION, 2026-09-20). The\n"
             "// counter is observable through the RAM-served INFCNT read.\n"
             "inline UINT32 g_diag_req_count = 0;\n"),
    )

    # ================= RuntimeHook.h =================

    # R1: HookEnter — cumulative counter (v8/v12 policy), VIRT suffix,
    #     NO DiagWrite inside hooks.
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
            "            // v13: ONE cumulative counter from driver load (v8\n"
            "            // binary evidence: trace numbers ran continuously\n"
            "            // across the virtual-mode boundary; INFDIAG at the VA\n"
            "            // event already carried all boot-context calls).\n"
            "            // Boot-context calls are still TRACED as BOOT-CTX\n"
            "            // (never touching the stage ladder) but also advance\n"
            "            // the counter, so the desktop can observe total\n"
            "            // traffic through the RAM-served INFDIAG read.\n"
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
            "            // v13: NO DiagWrite here — hooks NEVER call the\n"
            "            // original SetVariable at runtime. Live state is\n"
            "            // served from RAM instead (see HookedGetVariable).\n"
            "        }\n"
        ),
    )

    # R2: HookedGetVariable — LIVE RAM serve for INFDIAG / INFCNT +
    #     our-var read trace (replaces the v12 freshen entirely)
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
            "            // v13 READ-PATH OBSERVABILITY, SAFE: INFDIAG and INFCNT\n"
            "            // reads are answered from LIVE RAM state. v12's freshen\n"
            "            // (an NVRAM write from inside the GetVariable dispatch)\n"
            "            // crashed the kernel at desktop time (KMODE_EXCEPTION,\n"
            "            // 2026-09-20 report) — v13 hooks NEVER call the original\n"
            "            // SetVariable at runtime. GUID-checked and gated on\n"
            "            // virtual mode so boot-time reads (shell dmpstore in\n"
            "            // phase-b-check) keep their old chain-to-NVRAM\n"
            "            // semantics.\n"
            "            if (g_diag_va_done && instance_ && var_name &&\n"
            "                vendor_guid &&\n"
            "                CompareGuid(vendor_guid, &gInfinityMemVarGuid) == TRUE) {\n"
            "                if (StrCmp(var_name, (CHAR16*)L\"INFDIAG\") == 0) {\n"
            "                    SerialTrace::Line(\"HOOK\", \"G INFDIAG live\");\n"
            "                    InfinityDiag d;\n"
            "                    d.magic       = 0x494E4644;\n"
            "                    d.stage       = g_diag_stage;\n"
            "                    d.flags       = g_diag_flags;\n"
            "                    d.win_build   = g_diag_win_build;\n"
            "                    d.os_cr3      = g_diag_os_cr3;\n"
            "                    d.hook_calls  = g_diag_hook_calls;\n"
            "                    d.last_status = g_diag_last_status;\n"
            "                    if (!data_size) return EFI_INVALID_PARAMETER;\n"
            "                    if (!data || *data_size < sizeof(d)) {\n"
            "                        *data_size = sizeof(d);\n"
            "                        return EFI_BUFFER_TOO_SMALL;\n"
            "                    }\n"
            "                    if (attrs) *attrs = EFI_VARIABLE_NON_VOLATILE |\n"
            "                                        EFI_VARIABLE_BOOTSERVICE_ACCESS |\n"
            "                                        EFI_VARIABLE_RUNTIME_ACCESS;\n"
            "                    CopyMem(data, &d, sizeof(d));\n"
            "                    *data_size = sizeof(d);\n"
            "                    return EFI_SUCCESS;\n"
            "                }\n"
            "                if (StrCmp(var_name, (CHAR16*)L\"INFCNT\") == 0) {\n"
            "                    SerialTrace::Line(\"HOOK\", \"G INFCNT live\");\n"
            "                    UINT32 v = g_diag_req_count;\n"
            "                    if (!data_size) return EFI_INVALID_PARAMETER;\n"
            "                    if (!data || *data_size < sizeof(v)) {\n"
            "                        *data_size = sizeof(v);\n"
            "                        return EFI_BUFFER_TOO_SMALL;\n"
            "                    }\n"
            "                    if (attrs) *attrs = EFI_VARIABLE_NON_VOLATILE |\n"
            "                                        EFI_VARIABLE_BOOTSERVICE_ACCESS |\n"
            "                                        EFI_VARIABLE_RUNTIME_ACCESS;\n"
            "                    CopyMem(data, &v, sizeof(v));\n"
            "                    *data_size = sizeof(v);\n"
            "                    return EFI_SUCCESS;\n"
            "                }\n"
            "            }\n"
            "\n"
            "            if (instance_ && instance_->IsOurVariable(var_name, vendor_guid)) {\n"
            "                // v13: our-namespace reads are rare (only the\n"
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

    # R3: HookedSetVariable — our-var write attribution, RAM-ONLY
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
            "                // v13 WRITE-PATH ATTRIBUTION, RAM-ONLY: trace the\n"
            "                // call, set the trigger flag, bump the live\n"
            "                // counter. NEVER call the original SetVariable\n"
            "                // from inside a hook at runtime (the v12 freshen\n"
            "                // BSOD) — the counter is observable through the\n"
            "                // RAM-served INFCNT read in HookedGetVariable.\n"
            "                SerialTrace::Line(\"HOOK\",\n"
            "                    (data && data_size > 0) ?\n"
            "                        \"S OURVAR write\" : \"S OURVAR delete\");\n"
            "                DiagSetFlag(kDiagFlagTriggerSeen);\n"
            "                if (g_diag_va_done && data && data_size > 0) {\n"
            "                    g_diag_req_count++;\n"
            "                }\n"
            "                EFI_STATUS s = instance_->HandleOurSetVariable(\n"
            "                    var_name, attrs, data_size, data);\n"
            "                HookChainResult('S', s);\n"
            "                return s;\n"
            "            }\n"
        ),
    )

    # R5: INFTRIGGER joins the our-namespace list
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
            "            // v13: INFTRIGGER is also ours (script trigger probe).\n"
            "            // INFDIAG / INFCNT are deliberately NOT ours: their\n"
            "            // READS are served live from RAM earlier in\n"
            "            // HookedGetVariable, and their SET path must chain to\n"
            "            // the original so raw NVRAM landing keeps working.\n"
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
            "            // v13: INFTRIGGER — the script's trigger probe. The\n"
            "            // trigger flag and counter were already set by the\n"
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
        new="            SerialTrace::Line(\"RT-VA\", \"hooks already installed at load (v13 early) - keeping slots\");\n",
    )
    apply_edit(
        files, "R8", "RuntimeHook.h",
        old="            SerialTrace::Line(\"RT-EARLY\", \"gRT hooks INSTALLED at load time (pre-snapshot; Windows-visible)\");\n",
        new=(
            "            SerialTrace::Line(\"RT-EARLY\", \"" + MARKER + "\");\n"
            "            SerialTrace::Line(\"RT-EARLY\", \"gRT hooks INSTALLED at load time (pre-snapshot; Windows-visible)\");\n"
        ),
    )

    # ---- write results only after every edit succeeded ----
    rh.write_text(files["RuntimeHook.h"], encoding="utf-8")
    dg.write_text(files["Diag.h"], encoding="utf-8")
    print("[patch-v13] ALL EDITS APPLIED — tree is now v13")
    print("[patch-v13] changed: UEFI/include/RuntimeHook.h, UEFI/include/Diag.h")
    print("[patch-v13] next: make (SAFE) and make RT=1 (RT) in UEFI/build")


if __name__ == "__main__":
    main()
