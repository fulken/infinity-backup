#!/usr/bin/env python3
"""
patch-v14.py — apply the v14 changes on top of the v13 source tree.

WHY v14 EXISTS (the v13 lesson):
    The v13 run was 100% BSOD-free and the script completed fully — the
    safe-observability goal was met. But EVERY signal in its verdict came
    back "both paths bypassed", and the follow-up NVRAM forensics on the
    user's two vars files proved that verdict was an ARTIFACT:

    ROOT CAUSE (found by disassembling gnu-efi 3.0.13's RtCompareGuid):
        gnu-efi's CompareGuid is memcmp-like — it returns 0 when the two
        GUIDs are EQUAL. Two call sites treated it like EDK2's BOOLEAN
        semantics (TRUE = equal):
        (1) RuntimeHook.h INFDIAG/INFCNT serve gate:
                CompareGuid(vendor_guid, &gInfinityMemVarGuid) == TRUE
            For a MATCHING GUID this evaluates 0 == 1 = FALSE — the
            RAM serve is DEAD CODE; every desktop INFDIAG/INFCNT read
            fell through and chained to the original -> stale NVRAM
            251 / 203. That is exactly what the v13 transcript showed
            (A=B=C=D=E=F=251, INFCNT absent).
        (2) RuntimeHook.h IsOurVariable (BASE REPO code, latent since
            day one):
                if (CompareGuid(guid, &kOurGuid) != TRUE) return FALSE;
            For a MATCHING GUID: 0 != 1 = TRUE -> return FALSE. Our own
            variables are NEVER classified as ours: reads chain to NVRAM
            (InfinityResp "absent"), writes chain to NVRAM (they LAND —
            proven: INFPROBE/INFTRIGGER/InfinityReq all in the vars file
            as live VAR_ADDED entries) with zero "S OURVAR" traces.

    So the "write path bypasses our hook" conclusion of v11/v12/v13 is
    UNPROVEN — the GUID bug suppresses the traces either way. The only
    SOLID path fact remains the v12 freshen (name-only gate): desktop
    GetVariable READS DO reach our hook. And the v13 run incidentally
    PROVED that HookedSetVariable -> orig SetVariable -> NVRAM is a safe
    path (the three script writes chained through it, Win32=0, no BSOD).

v14 = v13 + three surgical fixes (mechanism otherwise unchanged):
  F1  GUID semantics: fix both comparisons (== 0 / != 0).
  F2  Live Windows build capture: at INFDIAG serve and at
      HandleOurSetVariable entry (guaranteed desktop kernel contexts
      where the KUSER_SHARED_DATA page is mapped in every address
      space), read NtBuildNumber directly:
          *(volatile UINT32*)(0xFFFFF78000000000 + 0x308) & 0x7FFFFFFF
      This fixes the win_build=0-since-v6 problem: at ExitBootServices
      the CPU still runs on the FIRMWARE's page tables (EBS CR3 ==
      UEFI CR3 == 0x7FC01000 in every log since v6), so the old
      pm->ReadVA(KUSD_VA, ebs_cr3) could never translate the high
      canonical KUSD VA. A direct read needs no page walk at all.
      ProcessFinder::FindByName lazily re-resolves offsets once the
      live build is known (the EBS-time build=0 left it fail-closed).
  F3  S-hook our-var chain-after-handle: after HandleOurSetVariable,
      chain to the original SetVariable so the write ALSO lands in
      NVRAM (dual write). Keeps the script's read-back checks working;
      empirically proven safe by the v13 accidental chains. The v12
      BSOD class was orig-SetVariable called from inside the
      GETVARIABLE dispatch — calling it from inside the SETVARIABLE
      dispatch is a different, now-proven path. The trigger flag 0x20
      is now write-gated (deletes no longer set it).

EXPECTED trigger-test-v14 SIGNATURES (with F1 the verdict is real now):
  full bridge   : A/B moving, INFCNT=2, flags 0x2B, Resp ANSWERED
  reads only    : A/B moving, INFCNT=0, no S OURVAR traces, Resp absent
  both bypassed : A/B frozen, INFCNT absent, no traces, Resp absent

Anchors are EXACT v13 source text (verified against build-v13-tree).
An anchor that does not match exactly once = FAIL LOUD, no files
modified.
"""
import sys
from pathlib import Path

MARKER = "memory.efi v14"


def apply_edit(files, tag, relpath, old, new):
    p = files[relpath]
    text = p.read_text()
    n = text.count(old)
    if n != 1:
        print(f"FATAL: anchor {tag} in {relpath}: found {n} occurrences (need exactly 1)")
        sys.exit(1)
    p.write_text(text.replace(old, new))
    print(f"  {tag}: {relpath} OK")


def main():
    if len(sys.argv) != 2:
        print("usage: patch-v14.py <v13-source-tree-root>")
        sys.exit(1)
    root = Path(sys.argv[1])
    base = root / "UEFI" / "include"
    files = {
        "RuntimeHook.h": base / "RuntimeHook.h",
        "ProcessFinder.h": base / "ProcessFinder.h",
    }
    for f in files.values():
        if not f.exists():
            print(f"FATAL: missing {f}")
            sys.exit(1)

    print(f"patching v14 onto {root} ...")

    # -------------------------------------------------- F1a: serve gate
    apply_edit(
        files, "F1a-serve-gate", "RuntimeHook.h",
        old=(
            "            if (g_diag_va_done && instance_ && var_name &&\n"
            "                vendor_guid &&\n"
            "                CompareGuid(vendor_guid, &gInfinityMemVarGuid) == TRUE) {\n"
        ),
        new=(
            "            if (g_diag_va_done && instance_ && var_name &&\n"
            "                vendor_guid &&\n"
            "                // v14 F1: gnu-efi CompareGuid is memcmp-like:\n"
            "                // it returns 0 when the GUIDs are EQUAL. The\n"
            "                // v13 '== TRUE' made this gate FALSE for every\n"
            "                // MATCHING GUID — the RAM serve was dead code\n"
            "                // and all desktop reads chained to stale NVRAM\n"
            "                // (that is why A..F all read 251 and INFCNT\n"
            "                // read 203 in the v13 run).\n"
            "                CompareGuid(vendor_guid, &gInfinityMemVarGuid) == 0) {\n"
        ),
    )

    # -------------------------------------------------- F1b: IsOurVariable
    apply_edit(
        files, "F1b-isourvar", "RuntimeHook.h",
        old=(
            "            if (guid) {\n"
            "                if (CompareGuid(guid, &kOurGuid) != TRUE) return FALSE;\n"
            "            }\n"
        ),
        new=(
            "            if (guid) {\n"
            "                // v14 F1: same memcmp-like semantics — 0 means\n"
            "                // EQUAL. The base-repo '!= TRUE' rejected every\n"
            "                // MATCHING GUID, so our own variables were never\n"
            "                // classified as ours: reads chained to NVRAM,\n"
            "                // writes chained to NVRAM, no traces, no counts.\n"
            "                // Latent since a8e41b3; it faked 'write bypass'\n"
            "                // across v9..v13.\n"
            "                if (CompareGuid(guid, &kOurGuid) != 0) return FALSE;\n"
            "            }\n"
        ),
    )

    # -------------------------------------------------- F2a: serve-path live build
    apply_edit(
        files, "F2a-serve-build", "RuntimeHook.h",
        old=(
            "                if (StrCmp(var_name, (CHAR16*)L\"INFDIAG\") == 0) {\n"
            "                    SerialTrace::Line(\"HOOK\", \"G INFDIAG live\");\n"
        ),
        new=(
            "                if (StrCmp(var_name, (CHAR16*)L\"INFDIAG\") == 0) {\n"
            "                    SerialTrace::Line(\"HOOK\", \"G INFDIAG live\");\n"
            "                    // v14 F2: desktop-time live build capture. We\n"
            "                    // are inside the kernel's GetVariable dispatch\n"
            "                    // — KUSER_SHARED_DATA is a global page mapped\n"
            "                    // in EVERY address space, so a direct read\n"
            "                    // needs no page walk and cannot fault. The\n"
            "                    // EBS-time capture always read 0 because at\n"
            "                    // ExitBootServices the CPU still runs on the\n"
            "                    // FIRMWARE page tables (EBS CR3 == UEFI CR3\n"
            "                    // in every serial log since v6) which do not\n"
            "                    // map the high-canonical KUSD VA.\n"
            "                    if (!g_diag_win_build) {\n"
            "                        UINT32 live = *(volatile UINT32*)\n"
            "                            (KUSER_SHARED_DATA_VA + KUSD_OFS_NtBuildNumber)\n"
            "                            & 0x7FFFFFFF;\n"
            "                        if (live >= 15000 && live < 99999) {\n"
            "                            g_diag_win_build = live;\n"
            "                            SerialTrace::KV(\"BLD\", \"live windows build \",\n"
            "                                            (UINT64)live);\n"
            "                        } else {\n"
            "                            SerialTrace::KV(\"BLD\",\n"
            "                                \"live KUSD read implausible \",\n"
            "                                            (UINT64)live);\n"
            "                        }\n"
            "                    }\n"
        ),
    )

    # -------------------------------------------------- F2b: write-path live build
    apply_edit(
        files, "F2b-write-build", "RuntimeHook.h",
        old=(
            "        EFI_STATUS HandleOurSetVariable(\n"
            "            CHAR16* var_name, UINT32 attrs,\n"
            "            UINTN data_size, VOID* data) {\n"
            "\n"
            "            if (StrCmp(var_name, (CHAR16*)L\"InfinityReq\") == 0) {\n"
        ),
        new=(
            "        EFI_STATUS HandleOurSetVariable(\n"
            "            CHAR16* var_name, UINT32 attrs,\n"
            "            UINTN data_size, VOID* data) {\n"
            "\n"
            "            // v14 F2: same live build capture on the write path\n"
            "            // (desktop kernel context, KUSD globally mapped) so\n"
            "            // request processing has correct offsets even if no\n"
            "            // INFDIAG read happened first.\n"
            "            if (!g_diag_win_build) {\n"
            "                UINT32 live = *(volatile UINT32*)\n"
            "                    (KUSER_SHARED_DATA_VA + KUSD_OFS_NtBuildNumber)\n"
            "                    & 0x7FFFFFFF;\n"
            "                if (live >= 15000 && live < 99999) {\n"
            "                    g_diag_win_build = live;\n"
            "                    SerialTrace::KV(\"BLD\", \"live windows build \",\n"
            "                                    (UINT64)live);\n"
            "                }\n"
            "            }\n"
            "\n"
            "            if (StrCmp(var_name, (CHAR16*)L\"InfinityReq\") == 0) {\n"
        ),
    )

    # -------------------------------------------------- F3: chain-after-handle + write-gated flag
    apply_edit(
        files, "F3-s-chain", "RuntimeHook.h",
        old=(
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
        ),
        new=(
            "                SerialTrace::Line(\"HOOK\",\n"
            "                    (data && data_size > 0) ?\n"
            "                        \"S OURVAR write\" : \"S OURVAR delete\");\n"
            "                // v14 F3: the 0x20 trigger flag is now WRITE-\n"
            "                // gated — the v13 code also set it for deletes\n"
            "                // ([CLR] would have faked a positive).\n"
            "                if (data && data_size > 0) {\n"
            "                    DiagSetFlag(kDiagFlagTriggerSeen);\n"
            "                    if (g_diag_va_done) {\n"
            "                        g_diag_req_count++;\n"
            "                    }\n"
            "                }\n"
            "                EFI_STATUS s = instance_->HandleOurSetVariable(\n"
            "                    var_name, attrs, data_size, data);\n"
            "                // v14 F3: ALSO chain to the original so the write\n"
            "                // lands in NVRAM (dual write: RAM handling + raw\n"
            "                // landing). This exact path — desktop SetVariable\n"
            "                // -> this hook -> orig SetVariable -> flash — ran\n"
            "                // incidentally and safely three times in the v13\n"
            "                // run (INFPROBE/INFTRIGGER/InfinityReq landed,\n"
            "                // Win32=0, no crash), so it is NOT the v12 BSOD\n"
            "                // class (that was orig-SetVariable called from\n"
            "                // inside the GETVARIABLE dispatch). Windows sees\n"
            "                // the NVRAM result, which is what read-back sees.\n"
            "                // The production pool transport drops this chain.\n"
            "                if (instance_->orig_set_variable_) {\n"
            "                    EFI_STATUS s2 = instance_->orig_set_variable_(\n"
            "                        var_name, vendor_guid, attrs, data_size, data);\n"
            "                    HookChainResult('S', s2);\n"
            "                    return s2;\n"
            "                }\n"
            "                HookChainResult('S', s);\n"
            "                return s;\n"
        ),
    )

    # -------------------------------------------------- banners v13 -> v14
    apply_edit(
        files, "R5-banner", "RuntimeHook.h",
        old=(
            "            SerialTrace::Line(\"RT-EARLY\", \"memory.efi v13 RT (safe observability)\");\n"
        ),
        new=(
            "            SerialTrace::Line(\"RT-EARLY\", \"memory.efi v14 RT (guid fix + live build)\");\n"
        ),
    )
    apply_edit(
        files, "R5b-va-banner", "RuntimeHook.h",
        old=(
            "                SerialTrace::Line(\"RT-VA\", \"hooks already installed at load (v13 early) - keeping slots\");\n"
        ),
        new=(
            "                SerialTrace::Line(\"RT-VA\", \"hooks already installed at load (v14 early) - keeping slots\");\n"
        ),
    )

    # -------------------------------------------------- P1: ProcessFinder lazy offsets refresh
    apply_edit(
        files, "P1-finder-lazy", "ProcessFinder.h",
        old=(
            "        BOOLEAN FindByName(const CHAR8* target_name, ProcessInfo* out) {\n"
            "            if (!phys_ || !out) return FALSE;\n"
            "            if (os_cr3_ == 0) return FALSE;\n"
        ),
        new=(
            "        BOOLEAN FindByName(const CHAR8* target_name, ProcessInfo* out) {\n"
            "            if (!phys_ || !out) return FALSE;\n"
            "            if (os_cr3_ == 0) return FALSE;\n"
            "            // v14 F2: the EBS-time build capture always read 0\n"
            "            // (firmware page tables at ExitBootServices — the\n"
            "            // KUSD VA is not mapped there), which left\n"
            "            // build_supported_ = false forever. RuntimeHook now\n"
            "            // captures the LIVE build from KUSER_SHARED_DATA in\n"
            "            // desktop kernel contexts; re-resolve the offsets\n"
            "            // lazily once it is available.\n"
            "            if (!build_supported_ && g_diag_win_build) {\n"
            "                SetOSCR3(g_diag_os_cr3 ? g_diag_os_cr3 : os_cr3_,\n"
            "                         g_diag_win_build);\n"
            "            }\n"
        ),
    )

    # -------------------------------------------------- sanity: markers present
    rh = files["RuntimeHook.h"].read_text()
    for probe in ("memory.efi v14", "== 0) {", "!= 0) return FALSE;",
                  "live windows build", "S OURVAR write"):
        if probe not in rh:
            print(f"FATAL: post-check — marker '{probe}' missing from RuntimeHook.h")
            sys.exit(1)
    pf = files["ProcessFinder.h"].read_text()
    if "g_diag_win_build" not in pf:
        print("FATAL: post-check — ProcessFinder.h lacks the lazy refresh")
        sys.exit(1)

    print("v14 patch applied cleanly:")
    print("  F1a serve-gate GUID        (== 0)")
    print("  F1b IsOurVariable GUID     (!= 0)")
    print("  F2a serve-path live build  (KUSD direct read)")
    print("  F2b write-path live build  (KUSD direct read)")
    print("  F3  chain-after-handle + write-gated 0x20 flag")
    print("  R5  banners -> memory.efi v14 RT")
    print("  P1  ProcessFinder lazy offsets refresh")


if __name__ == "__main__":
    main()
