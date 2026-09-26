v19 bench evidence (2026-09-26, scripts/test-v19-linux.sh, rebuilt QEMU bench)
- MODE A (v19-RT, 125450 B, sha256 2561e543...): VERDICT PASS 13/13 — v19 banner
  with "kernel data path: direct reads + anchors", gRT hooks at load, BOOT-CTX
  traces, stage 2 EBS + stage 3 VA writes, all ConvertPointer st=0, virtual mode
  armed, Linux 6.12.51 booted via EFI stub, documented post-chain NX stop.
  [AN] anchor traces cannot fire on the bench (no requester) — that is the v24
  field script's job (op 9 + L-reads inside the validated range).
- MODE B (v19-SAFE, 105032 B, sha256 115fc134...): VERDICT PASS 5/5 — stage 1
  write (flags 0x1), Linux boot, /init ran, ZERO gRT hook lines (SAFE contract),
  same initramfs boot-media quirk as archived v7/v18 SAFE runs.
- Host logic tests (scripts/host-test-v19.c, 29/29 ALL PASS) cover the anchor
  discovery logic itself: valid converge, walk bounds, mismatch, corrupt PE
  rejection, containment (incl. the nested-PE trap), IDT/anchor guards.
- Driver lineage: v19-RT = v18-RT + KernelAnchor.h + op-9 + third gate range;
  v18 KUSD windows byte-preserved (disasm: 0x7ffeffff/0xfffff7800000ffff present).
