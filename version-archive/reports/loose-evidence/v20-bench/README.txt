v20 bench (2026-09-26)
- MODE A (RT 128010B sha256 8513da5f...): VERDICT PASS 13/13 - v20 banner "direct reads + containing anchors", full hook/EBS/VA chain, Linux 6.12.51 EFI stub, documented post-chain NX stop
- MODE B (SAFE 105032B sha256 c244ace2...): VERDICT PASS 5/5 - stage 1 write, Linux boot, /init ran, ZERO gRT hook lines, initramfs quirk same as archived v7/v18/v19 SAFE runs
- [AN]/[RD] traces need a Windows requester (field job of the v26 script); binary presence proven by strings + disasm at build
