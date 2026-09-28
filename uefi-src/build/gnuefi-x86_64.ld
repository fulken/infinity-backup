/* =================================================================
 * gnuefi-x86_64.ld — vendored from gnu-efi 3.0.13 elf_x86_64_efi.lds
 * with the R6 fix.
 *
 * R6 (QEMU bring-up): g++ emits C++ COMDAT/named BSS sections such as
 * `.bss._ZN10UEFIBridge11RuntimeHook...`. The upstream script matches
 * only the literal section name `*(.bss)`, so those named sections were
 * orphaned OUTSIDE the PE image (objcopy -j lists never saw them) while
 * their relocations still pointed into image space — the first write to
 * such a variable (RuntimeHook::instance_) landed in foreign memory and
 * #PF'd. The fix: wildcard every BSS-like input section so all named
 * variants are pulled into .data inside the image.
 * Everything else is byte-identical to the upstream script.
 * ================================================================= */
OUTPUT_FORMAT("elf64-x86-64", "elf64-x86-64", "elf64-x86-64")
OUTPUT_ARCH(i386:x86-64)
ENTRY(_start)
SECTIONS
{
  . = 0;
  ImageBase = .;
  /* .hash and/or .gnu.hash MUST come first! */
  .hash : { *(.hash) }
  .gnu.hash : { *(.gnu.hash) }
  . = ALIGN(4096);
  .eh_frame :
  {
    *(.eh_frame)
  }
  . = ALIGN(4096);
  .text :
  {
   _text = .;
   *(.text)
   *(.text.*)
   *(.gnu.linkonce.t.*)
   . = ALIGN(16);
  }
  _etext = .;
  _text_size = . - _text;
  . = ALIGN(4096);
  .reloc :
  {
   *(.reloc)
  }
  . = ALIGN(4096);
  .data :
  {
   _data = .;
   *(.rodata*)
   *(.got.plt)
   *(.got)
   *(.data*)
   *(.sdata)
   /* the EFI loader doesn't seem to like a .bss section, so we stick
      it all into .data: */
   *(.sbss*)
   *(.scommon*)
   *(.dynbss*)
   *(.bss*)          /* R6: wildcard — pulls in C++ named .bss._ZN.. sections */
   *(COMMON)
   *(.rel.local)
  }
  .note.gnu.build-id : { *(.note.gnu.build-id) }

  _edata = .;
  _data_size = . - _etext;
  . = ALIGN(4096);
  .dynamic  : { *(.dynamic) }
  . = ALIGN(4096);
  .rela :
  {
    *(.rela.data*)
    *(.rela.got)
    *(.rela.stab)
  }
  . = ALIGN(4096);
  .dynsym   : { *(.dynsym) }
  . = ALIGN(4096);
  .dynstr   : { *(.dynstr) }
  . = ALIGN(4096);
  .ignored.reloc :
  {
    *(.rela.reloc)
    *(.eh_frame)
    *(.note.GNU-stack)
  }
  .comment 0 : { *(.comment) }
}
