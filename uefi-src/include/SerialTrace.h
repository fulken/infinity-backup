/**
 * SerialTrace.h  (UEFI side)  —  v6 diagnostic infrastructure
 * =================================================================
 * Raw serial-port (COM1 / 0x3F8) output that works in EVERY CPU and
 * firmware mode: Boot Services, inside the SetVirtualAddressMap
 * event, after ExitBootServices, and from gRT hooks called by the
 * Windows kernel. It is pure port I/O — no firmware services, no
 * pointers to convert, no locks, no TPL/IRQL requirements.
 *
 * Why this exists (v5 lesson): INFDIAG told us the VA event ran
 * (stage 3) but nothing after it. NVRAM writes can silently fail
 * after the firmware switches to virtual addressing, so a variable
 * alone can not distinguish "hook never ran" from "hook ran but its
 * write failed". The serial port cannot silently fail — every trace
 * line that appears in serial-phase-d.log is ground truth.
 *
 * QEMU maps the 16550 UART to the -serial file, so these lines land
 * in the same serial-phase-d.log the user already sends back.
 * =================================================================
 */
#pragma once

#include <cstdint>

namespace UEFIBridge {

class SerialTrace {
public:
    static constexpr uint16_t kCom1Base = 0x3F8;

    static inline void OutB(uint16_t port, uint8_t val) {
        __asm__ __volatile__("outb %0, %1" : : "a"(val), "Nd"(port));
    }

    static void Putc(char c) { OutB(kCom1Base, (uint8_t)c); }

    static void Puts(const char* s) {
        if (!s) return;
        while (*s) Putc(*s++);
    }

    // Every trace line starts with \r\n[INF] so it is easy to grep and
    // clearly separated from the firmware console output.
    static void Begin(const char* tag) {
        Putc('\r'); Putc('\n');
        Puts("[INF]");
        if (tag) { Putc('['); Puts(tag); Putc(']'); }
        Putc(' ');
    }

    static void Line(const char* tag, const char* msg) {
        Begin(tag); Puts(msg);
    }

    // v15: this used to be 'static const char* k = "..."' — the
    // compiler materialized it as a POINTER SLOT in .data.rel.ro
    // holding the load-time (physical) address, which nobody
    // converted at SetVirtualAddressMap. The first hex print from
    // the Windows kernel context dereferenced that stale address
    // and page-faulted — THAT was the v12 and the v14 BSOD (both
    // logs truncate mid "=0x"). An ARRAY is addressed rip-relative
    // and needs no conversion in any address space.
    static void Hex64(uint64_t v) {
        static const char k[] = "0123456789ABCDEF";
        for (int nib = 60; nib >= 0; nib -= 4) Putc(k[(v >> nib) & 0xF]);
    }

    static void Hex32(uint32_t v) {
        static const char k[] = "0123456789ABCDEF";
        for (int nib = 28; nib >= 0; nib -= 4) Putc(k[(v >> nib) & 0xF]);
    }

    static void Dec(uint64_t v) {
        char buf[21];
        int i = 20;
        buf[20] = 0;
        if (v == 0) { Putc('0'); return; }
        while (v && i > 0) { buf[--i] = (char)('0' + (v % 10)); v /= 10; }
        Puts(&buf[i]);
    }

    // Convenience: "[INF][tag] label=0x........  (64-bit hex)"
    static void KV(const char* tag, const char* label, uint64_t v) {
        Begin(tag); Puts(label); Puts("=0x"); Hex64(v);
    }

    // Convenience: "[INF][tag] label=<decimal>"
    static void KVD(const char* tag, const char* label, uint64_t v) {
        Begin(tag); Puts(label); Putc('='); Dec(v);
    }

    // Convenience: "[INF][tag] msg st=0x........" for EFI_STATUS values.
    static void Status(const char* tag, const char* msg, uint64_t st) {
        Begin(tag); Puts(msg); Puts(" st=0x"); Hex32((uint32_t)st);
    }
};

} // namespace UEFIBridge
