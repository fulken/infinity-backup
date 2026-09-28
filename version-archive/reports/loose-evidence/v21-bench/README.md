# v21 bench evidence (2026-09-27)

MODE A (RT) VERDICT: PASS 13/13 — v21 banner "kernel data path: direct
reads + export resolution", full hook/EBS/VA chain, ConvertPointer st=0,
Linux 6.12.51 EFI stub boot, documented post-chain NX stop.

MODE B (SAFE) VERDICT: PASS 5/5 — stage 1 write, Linux boot, /init ran,
ZERO gRT hook lines, initramfs quirk same as archived v7/v18/v19/v20
SAFE runs.

Note: the op-10 [XS]/[KPCR] traces need a Windows-side requester — the
export-resolution LOGIC is host-proven (scripts/host-test-v21.c, 50/50
checks, zero out-of-map reads); the field run (script v28 M-steps) is
the end-to-end proof.
