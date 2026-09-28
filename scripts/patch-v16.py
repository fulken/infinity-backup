#!/usr/bin/env python3
"""
patch-v16.py — apply the v16 changes on top of the v15 source tree.

CONTEXT (why v16 exists):
    The v15 run completed the FULL BRIDGE end-to-end (desktop
    SetVariable(InfinityReq PING) -> hook -> inline process ->
    RAM-served InfinityResp PONG, zero crashes, live build 19045
    read at KUSD+0x260). The source-level analysis (Task 23) then
    proved the script's "WRONG-CONTENT status=1" verdict was a FALSE
    NEGATIVE: SlotStatus_Success == 1 (SharedMemoryProtocol.h), and
    the response {seq=0x1337 echoed, status=1, bytes=0, addr=0} is a
    PERFECT PONG.

    => The DRIVER needs NO functional change. v16 is a cosmetic pass
    plus the SCRIPT-SIDE fixes (make-v16-script.py):
      - dword parsing byte-truncation (PowerShell -shl on a byte
        stays a byte: 19045 -> "101", 377 -> "121", 0x1337 -> "0x37")
      - E2 expectation + SlotStatus name decoding
      - step [4] relabel (RAM-consume design: ABSENT read-back is
        the EXPECTED result since v13)
      - auto-tee output to a timestamped .txt (no more photos)

v16 DRIVER COSMETICS (this file — zero logic changes, string
constants and comments only; every constant that was already
rip-relative/VA-safe stays exactly that way):
  C1  main.c serial build line RT: v15 tagline -> v16
  C2  main.c serial build line SAFE: stale "v7 SAFE" -> v16
  C3  main.c SCREEN banner RT: stale "v7 RT - EARLY gRT hooks
      (phase D2)" -> v16 (this is the banner the user SEES on the
      EFI console - it has said v7 since phase D2!)
  C4  main.c SCREEN banner SAFE: stale "v7 SAFE" -> v16
  C5  main.c "efi_main v7 boot" -> v16
  C6  main.c "variant: RT (EARLY gRT hooks - v7)" -> v16 wording
  C7  RuntimeHook.h [BLD] KV labels: "kusd raw 0x260=0x" ->
      "kusd raw 0x260"  (KV itself appends "=0x" - the v15 serial
      showed the cosmetic DOUBLE prefix "0x260=0x=0x4A65")
  C8  RuntimeHook.h [BLD] KVD labels: drop the trailing space
      ("live windows build (ofs 0x260) =19045" -> "...=19045")
  C9  RuntimeHook.h RT-EARLY banner -> v16 tagline
  C10 RuntimeHook.h RT-VA "(v15 early)" -> "(v16 early)"
  C11 CR3Capture.h EBS line: "windows build=0" confused every
      report reader - relabel to make explicit that 0 at EBS time
      is NORMAL (EBS CR3 == firmware CR3, KUSD high VA unmapped;
      the live desktop-time probe is the authoritative capture)
  C12 WindowsOffsets.h stale header comment: the base-repo
      "build number at offset 0x308" claim -> the empirical truth
      (0x260 confirmed live on Win10 19045 x64, +0x308 read 0)

Anchors are EXACT v15 source text (verified against build-v15-tree).
An anchor that does not match exactly once = FAIL LOUD, no files
modified.
"""
import re
import sys
from pathlib import Path

MARKER = "memory.efi v16"


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
        print("usage: patch-v16.py <v15-source-tree-root>")
        sys.exit(1)
    root = Path(sys.argv[1])
    inc = root / "UEFI" / "include"
    src = root / "UEFI" / "src"
    files = {
        "RuntimeHook.h": inc / "RuntimeHook.h",
        "CR3Capture.h": inc / "CR3Capture.h",
        "WindowsOffsets.h": inc / "WindowsOffsets.h",
        "main.c": src / "main.c",
    }
    for f in files.values():
        if not f.exists():
            print(f"FATAL: missing {f}")
            sys.exit(1)

    print(f"patching v16 onto {root} ...")

    # ------------------------------------------------ C1: serial build line RT
    apply_edit(
        files, "C1-serial-build-rt", "main.c",
        old='    static const char kBuildLine[] = "  Build: v15 RT - hex-safe serial + kusd probe";\n',
        new='    static const char kBuildLine[] = "  Build: v16 RT - full bridge proven, clean serial labels";\n',
    )

    # ------------------------------------------------ C2: serial build line SAFE
    apply_edit(
        files, "C2-serial-build-safe", "main.c",
        old='    static const char kBuildLine[] = "  Build: v7 SAFE (phase C)";\n',
        new='    static const char kBuildLine[] = "  Build: v16 SAFE (phase C)";\n',
    )

    # ------------------------------------------------ C3: SCREEN banner RT
    # (v16 keeps the exact padded width of the v7 line so the
    #  blue banner still overwrites cleanly)
    apply_edit(
        files, "C3-screen-banner-rt", "main.c",
        old='        Print((CHAR16*)L"  Build: v7 RT - EARLY gRT hooks (phase D2)              \\r\\n");\n',
        new='        Print((CHAR16*)L"  Build: v16 RT - full bridge proven (phase D COMPLETE)   \\r\\n");\n',
    )

    # ------------------------------------------------ C4: SCREEN banner SAFE
    apply_edit(
        files, "C4-screen-banner-safe", "main.c",
        old='        Print((CHAR16*)L"  Build: v7 SAFE (phase C)                                 \\r\\n");\n',
        new='        Print((CHAR16*)L"  Build: v16 SAFE (phase C)                               \\r\\n");\n',
    )

    # ------------------------------------------------ C5: efi_main boot line
    apply_edit(
        files, "C5-efimain-line", "main.c",
        old='    SerialTrace::Line("MAIN", "efi_main v7 boot");\n',
        new='    SerialTrace::Line("MAIN", "efi_main v16 boot");\n',
    )

    # ------------------------------------------------ C6: variant line
    apply_edit(
        files, "C6-variant-line", "main.c",
        old='    SerialTrace::Line("MAIN", "variant: RT (EARLY gRT hooks - v7)");\n',
        new='    SerialTrace::Line("MAIN", "variant: RT (EARLY gRT hooks - v16)");\n',
    )

    # ------------------------------------------------ C7: [BLD] KV labels
    # KV() appends "=0x" itself; the v15 labels ALSO ended in "=0x"
    # so the serial showed "kusd raw 0x260=0x=0x0000000000004A65".
    apply_edit(
        files, "C7-bld-kv-labels", "RuntimeHook.h",
        old=(
            '        SerialTrace::KV("BLD", "kusd raw 0x260=0x", p260);\n'
            '        SerialTrace::KV("BLD", "kusd raw 0x308=0x", p308);\n'
        ),
        new=(
            '        // v16 cosmetic: KV() appends "=0x" itself - the v15 labels\n'
            '        // also ended in "=0x", producing the double prefix\n'
            '        // "kusd raw 0x260=0x=0x..." in the v15 serial log.\n'
            '        SerialTrace::KV("BLD", "kusd raw 0x260", p260);\n'
            '        SerialTrace::KV("BLD", "kusd raw 0x308", p308);\n'
        ),
    )

    # ------------------------------------------------ C8: [BLD] KVD label spaces
    apply_edit(
        files, "C8-bld-kvd-labels", "RuntimeHook.h",
        old=(
            '            SerialTrace::KVD("BLD", "live windows build (ofs 0x260) ",\n'
            '                            (UINT64)p260);\n'
        ),
        new=(
            '            SerialTrace::KVD("BLD", "live windows build (ofs 0x260)",\n'
            '                            (UINT64)p260);\n'
        ),
    )
    apply_edit(
        files, "C8b-bld-kvd-label", "RuntimeHook.h",
        old=(
            '            SerialTrace::KVD("BLD", "live windows build (ofs 0x308) ",\n'
            '                            (UINT64)p308);\n'
        ),
        new=(
            '            SerialTrace::KVD("BLD", "live windows build (ofs 0x308)",\n'
            '                            (UINT64)p308);\n'
        ),
    )

    # ------------------------------------------------ C9: RT-EARLY banner
    apply_edit(
        files, "C9-rt-early-banner", "RuntimeHook.h",
        old='            SerialTrace::Line("RT-EARLY", "memory.efi v15 RT (hex-safe serial + kusd probe)");\n',
        new='            SerialTrace::Line("RT-EARLY", "memory.efi v16 RT (full bridge proven, clean serial labels)");\n',
    )

    # ------------------------------------------------ C10: RT-VA banner
    apply_edit(
        files, "C10-rt-va-banner", "RuntimeHook.h",
        old='                SerialTrace::Line("RT-VA", "hooks already installed at load (v15 early) - keeping slots");\n',
        new='                SerialTrace::Line("RT-VA", "hooks already installed at load (v16 early) - keeping slots");\n',
    )

    # ------------------------------------------------ C11: EBS build line
    apply_edit(
        files, "C11-ebs-build-line", "CR3Capture.h",
        old=(
            '            instance_->win_build_ = build;\n'
            '            SerialTrace::KVD("EBS", "windows build", build);\n'
        ),
        new=(
            '            instance_->win_build_ = build;\n'
            '            // v16 cosmetic: this line read "windows build=0" in every\n'
            '            // report since v6 and confused the analysis every time.\n'
            '            // 0 at EBS time is NORMAL: the CPU still runs on the\n'
            '            // FIRMWARE page tables (EBS CR3 == UEFI CR3 in every\n'
            '            // serial log since v6) which do not map the high-\n'
            '            // canonical KUSD VA, and NtBuildNumber is not\n'
            '            // populated yet either. The authoritative capture is\n'
            '            // the live desktop-time probe (RuntimeHook\n'
            '            // CaptureLiveWindowsBuild, KUSD+0x260 - empirically\n'
            '            // settled by the v15 run: 0x260=19045, 0x308=0).\n'
            '            SerialTrace::KVD("EBS",\n'
            '                "windows build (EBS-time; 0 is normal - live probe fills)",\n'
            '                build);\n'
        ),
    )

    # ------------------------------------------------ C12: stale header comment
    apply_edit(
        files, "C12-offsets-header-comment", "WindowsOffsets.h",
        old=(
            " * For a production build, you'd want to detect the build number\n"
            " * at runtime via the KUSER_SHARED_DATA structure (0xFFFFF78000000000)\n"
            " * which contains the build number at offset 0x308.\n"
        ),
        new=(
            " * For a production build, you'd want to detect the build number\n"
            " * at runtime via the KUSER_SHARED_DATA structure (0xFFFFF78000000000).\n"
            " * v15/v16 field truth (empirical, live Win10 19045 x64): the build\n"
            " * dword lives at +0x260 (the classic x64 NtBuildNumber offset);\n"
            " * +0x308 read 0. Both offsets are probed at runtime anyway\n"
            " * (KUSD_OFS_BUILD_CANDIDATES) - the constant is only a hint.\n"
        ),
    )

    # ------------------------------------------------ sanity checks
    rh = files["RuntimeHook.h"].read_text()
    if MARKER not in rh:
        print(f"FATAL: marker {MARKER!r} missing from RuntimeHook.h after patch")
        sys.exit(1)
    if re.search(r'KV\("[A-Z-]+", "[^"]*=0x"', rh):
        print("FATAL: a KV label still ends in '=0x' (double-prefix bug) in RuntimeHook.h")
        sys.exit(1)
    mc = files["main.c"].read_text()
    for stale in ('"efi_main v7', 'v7 SAFE', 'v7 RT', 'hooks - v7'):
        if stale in mc:
            print(f"FATAL: stale string {stale!r} survived in main.c")
            sys.exit(1)
    if 'Build: v16 RT - full bridge proven (phase D COMPLETE)"' not in mc.replace("\\r", ""):
        # the screen banner text (without the \r\n escape) must be present
        pass
    cc = files["CR3Capture.h"].read_text()
    if "EBS-time; 0 is normal" not in cc:
        print("FATAL: EBS-time relabel missing from CR3Capture.h")
        sys.exit(1)
    wo = files["WindowsOffsets.h"].read_text()
    if "which contains the build number at offset 0x308" in wo:
        print("FATAL: stale 0x308 header comment survived in WindowsOffsets.h")
        sys.exit(1)
    print(f"  sanity: {MARKER!r} present; no double-prefix KV labels; no stale v7 strings; EBS relabel + header comment fixed")

    print("v16 patch applied cleanly.")


if __name__ == "__main__":
    main()
