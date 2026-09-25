v18 QEMU sandbox bench validation (2026-09-26) — bench REBUILD after rollbacks
Context: Phase C item 2. The old test dirs were lost to sandbox rollbacks;
scripts/test-v18-linux.sh rebuilt the bench from surviving parts
(qemu-root 10.0.11, qemu-bios, upload/extracted-v9-full firmware+EFI shell,
alpine.iso, scripts/iso_extract.py).

Mode A (v18 RT — byte-identical to the Phase-E-proven field binary, sha256
9F44178895E4A9E06D64A4ECD7BBCD4105486186A058B78F896FEDF363ABCDEA):
  VERDICT: PASS (13/13) — RT-EARLY v18 banner with the "kernel data path:
  direct KUSD reads" parenthetical, gRT hooks installed at load, BOOT-CTX
  hook traces (call#64 sampled), stage 2 EBS write + EBS-time build note,
  SetVirtualAddressMap event, stage 3 write, virtual mode armed, ALL
  ConvertPointer st=0, Linux 6.12.51 booted via EFI stub, then the
  documented post-chain NX panic (Linux limitation since v6; Windows is
  the target). [RD] mapped-va lines cannot fire without a Windows-side
  request — binary presence verified at build + in the field (J2=19045).
Mode B (v18 SAFE — never field-run):
  VERDICT: PASS (5/5 incl. notes) — stage 1 write (flags 0x1 loaded),
  Linux booted, init ran, NO gRT hook lines (SAFE contract), initramfs
  boot-media mount quirk same as the archived v7 SAFE run (vvfat+TCG,
  not driver-related).

Files: serial-lA.log, serial-lB.log, infdiag-lA.txt, infdiag-lB.txt
Driver inputs: patches/v18-memory-RT.efi (121253 B), v18-memory-SAFE.efi (105032 B)
