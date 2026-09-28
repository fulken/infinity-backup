/**
 * RequestHandler.h  (UEFI side)
 * =================================================================
 * Polling loop that consumes RequestSlots from the request ring
 * buffer and writes ResponseSlots.
 *
 * =================================================================
 */
#pragma once

#ifdef __cplusplus
extern "C" {
#endif
#include <efi.h>
#include <efilib.h>
#ifdef __cplusplus
}
#endif

#include <atomic>
#include <cstdint>

#include "SharedMemoryPool.h"
#include "SharedMemoryProtocol.h"
#include "ProcessMemory.h"
#include "ProcessFinder.h"
#include "KernelAnchor.h"
#include "KernelExports.h"
#include "ProcessWalk.h"
#include "PageTableWalk.h"
#include "Diag.h"

namespace UEFIBridge {

    // =========================================================
    // v19 (F1): anchor discovery — register reads + serial traces.
    // The discovery LOGIC (walks, validation, reasons) lives in
    // KernelAnchor.h: pure, host-testable, fail-closed.
    // =========================================================
    static inline std::uint64_t An_ReadMSR(std::uint32_t msr) {
        std::uint32_t lo, hi;
        __asm__ __volatile__("rdmsr" : "=a"(lo), "=d"(hi) : "c"(msr));
        return ((std::uint64_t)hi << 32) | lo;
    }

    struct An_IDTR { std::uint16_t limit; std::uint64_t base; }
        __attribute__((packed));

    static inline An_IDTR An_SIDT() {
        An_IDTR d;
        __asm__ __volatile__("sidt %0" : "=m"(d) :: "memory");
        return d;
    }

    // Idempotent + fail-closed: at most one attempt per boot; a failed
    // discovery is cached as failed (never retried; gate stays v18).
    static void DiscoverAnchorsOnce() {
        if (ka::g_result.state != ka::kAnchorNotRun) return;
        ka::Result r{};
        An_IDTR idtr = An_SIDT();
        SerialTrace::KV("AN", "sidt base", idtr.base);
        if (idtr.limit < 0xFFu) {  // need >= 16 entries for vector 0x0E
            r.idt_base = idtr.base;
            r.state  = ka::kAnchorFailClosed;
            r.reason = ka::kAnReason_IdtInvalid;
            SerialTrace::KVD("AN", "FAIL-CLOSED reason", r.reason);
            ka::g_result = r;
            return;
        }
        std::uint64_t pf = ka::IdtHandlerVA(idtr.base, 0x0E);  // #PF
        std::uint64_t bp = ka::IdtHandlerVA(idtr.base, 0x03);  // #BP
        std::uint64_t ls = An_ReadMSR(0xC0000082);             // IA32_LSTAR
        SerialTrace::KV("AN", "idt pf", pf);
        SerialTrace::KV("AN", "idt bp", bp);
        SerialTrace::KV("AN", "lstar", ls);
        ka::DiscoverCore(&r, idtr.base, pf, bp, ls);
        SerialTrace::KV("AN", "walk v1", r.walk_v1);
        SerialTrace::KV("AN", "walk v2", r.walk_v2);
        SerialTrace::KV("AN", "walk v3", r.walk_v3);
        // v20: what each walk SKIPPED (valid PEs that did not contain
        // the anchor) — the fail-closed serial trace names the refusals
        if (r.v1_skips) {
            SerialTrace::KVD("AN", "walk v1 skipped", r.v1_skips);
            SerialTrace::KV("AN", "walk v1 lastskip", r.v1_last_skip);
        }
        if (r.v2_skips) {
            SerialTrace::KVD("AN", "walk v2 skipped", r.v2_skips);
            SerialTrace::KV("AN", "walk v2 lastskip", r.v2_last_skip);
        }
        if (r.v3_skips) {
            SerialTrace::KVD("AN", "walk v3 skipped", r.v3_skips);
            SerialTrace::KV("AN", "walk v3 lastskip", r.v3_last_skip);
        }
        if (r.state == ka::kAnchorConverged) {
            SerialTrace::KV("AN", "CONVERGED base", r.pe_base);
            SerialTrace::KV("AN", "CONVERGED size", r.pe_size);
            DiagSetFlag(0x40);  // 'anchors converged' — in every INFDIAG
        } else {
            SerialTrace::KVD("AN", "FAIL-CLOSED reason", r.reason);
        }
        ka::g_result = r;
    }

    class RequestHandler {
    public:
        RequestHandler() = default;
        ~RequestHandler() { Stop(); }

        EFI_STATUS Start(SharedMemoryPool* pool, ProcessMemory* mem,
                          ProcessFinder* finder) {
            pool_   = pool;
            mem_    = mem;
            finder_ = finder;
            running_ = true;

            EFI_STATUS s = gBS->CreateEvent(
                EVT_TIMER | EVT_NOTIFY_SIGNAL,
                TPL_CALLBACK,
                &RequestHandler::TimerCallback,
                this,
                &timer_event_);
            if (EFI_ERROR(s)) return s;

            s = gBS->SetTimer(timer_event_, TimerPeriodic, 10000);
            if (EFI_ERROR(s)) {
                gBS->CloseEvent(timer_event_);
                return s;
            }

            return EFI_SUCCESS;
        }

        void Stop() {
            if (timer_event_) {
                gBS->SetTimer(timer_event_, TimerCancel, 0);
                gBS->CloseEvent(timer_event_);
                timer_event_ = nullptr;
            }
            running_ = false;
        }

        // v6: convert runtime-assigned pointers to virtual addresses
        // (called from the SetVirtualAddressMap event handler).
        void ConvertSelf(EFI_CONVERT_POINTER cvt) {
            CvtOne(cvt, (VOID**)&pool_,   "RH.pool_");
            CvtOne(cvt, (VOID**)&mem_,    "RH.mem_");
            CvtOne(cvt, (VOID**)&finder_, "RH.finder_");
            // timer_event_ is a boot-services handle — invalid after
            // ExitBootServices, deliberately not converted.
        }

        // Public getter for timer event (needed by main.c for WaitForEvent).
        EFI_EVENT GetTimerEvent() const { return timer_event_; }

        void ProcessPendingRequests() {
            if (!pool_ || !mem_) return;

            ::SharedMemoryHeader* h = pool_->Header();
            MEMORY_FENCE_ACQUIRE();
            std::uint32_t w = h->request_write_idx;
            std::uint32_t r = h->request_read_idx;

            ::RequestSlot*  reqs  = pool_->Requests();
            ::ResponseSlot* resps = pool_->Responses();

            while (r != w) {
                ::RequestSlot& req = reqs[r];
                ProcessOneRequest(req, resps);

                h->request_read_idx = (r + 1) & (RING_BUFFER_SLOTS - 1);
                MEMORY_FENCE_RELEASE();

                h->total_requests = h->total_requests + 1;

                MEMORY_FENCE_ACQUIRE();
                w = h->request_write_idx;
                r = (r + 1) & (RING_BUFFER_SLOTS - 1);
            }

            h->uefi_heartbeat = h->uefi_heartbeat + 1;
            MEMORY_FENCE_RELEASE();
        }

        void ProcessSingleVariableRequest(const void* req_buf,
                                          void* resp_buf,
                                          void* data_buf,
                                          UINTN* data_size) {
            if (!req_buf || !resp_buf || !data_size) return;

            struct EfiVarReq {
                UINT32 sequence;
                UINT32 op;
                UINT32 pid;
                UINT32 data_size;
                UINT64 address;
                UINT64 alloc_size;
                UINT32 protect;
                UINT32 timeout_ms;
                UINT32 status;
                UINT32 crc32;
            };
            struct EfiVarResp {
                UINT32 sequence;
                UINT32 status;
                UINT64 bytes_transferred;
                UINT64 out_address;
                UINT32 old_protect;
                UINT32 crc32;
            };

            const EfiVarReq* req = (const EfiVarReq*)req_buf;
            EfiVarResp* resp = (EfiVarResp*)resp_buf;
            resp->sequence = req->sequence;
            resp->status   = SlotStatus_ErrGeneric;
            resp->bytes_transferred = 0;
            resp->out_address = 0;

            // CRITICAL FIX #3: Validate data_size against last_data_ buffer (4096 bytes).
            // Prevents buffer overflow if a malformed request specifies a large data_size.
            if (req->data_size > 4096) {
                resp->status = SlotStatus_ErrInvalid;
                *data_size = 0;
                return;
            }

            switch ((ReqOp)req->op) {
            case 9 /* ReqOp_Anchors — v19 F1 (op 9 was free in the
                    Windows-side enum; the variable transport carries
                    raw op values) */: {
                DiscoverAnchorsOnce();
                const ka::Result& an = ka::g_result;
                // 32-byte payload (the InfinityData view):
                //   +0 u32 state, +4 u32 reason, +8 u64 pe_base,
                //  +16 u64 pe_size, +24 u64 idt_base
                UINT8* p = (UINT8*)data_buf;
                for (UINTN i = 0; i < 32; i++) p[i] = 0;
                auto put32 = [&p](UINTN off, UINT32 v) {
                    for (UINTN i = 0; i < 4; i++)
                        p[off + i] = (UINT8)(v >> (8 * i));
                };
                auto put64 = [&p](UINTN off, UINT64 v) {
                    for (UINTN i = 0; i < 8; i++)
                        p[off + i] = (UINT8)(v >> (8 * i));
                };
                put32(0,  an.state);
                put32(4,  an.reason);
                put64(8,  an.pe_base);
                put64(16, an.pe_size);
                put64(24, an.idt_base);
                resp->status = (an.state == ka::kAnchorConverged)
                    ? SlotStatus_Success : SlotStatus_ErrAccess;
                resp->bytes_transferred = 32;
                *data_size = 32;
                break;
            }
            case 10 /* ReqOp_ResolveSymbol — v21 F2 re-derived:
                    name via InfinityData, length = data_size.
                    WIRE CONTRACT (field-proven v28/v29, M1..M4):
                    payload 64B = rc@0, nameIndex@4, resolvedVa@8,
                    peBase@16, peSize@24, kpcrBase@32 (live MSR),
                    idtBase@40, nameLen@48 (success only),
                    failRc@52 (0=ok/1=notfound/2=invalid/3=fwd/4=gated),
                    idtMatch@56, pad@60. Status: 1 resolved / 7 notfound
                    / 3 forwarded / 4 refused / 2 invalid name. */: {
                DiscoverAnchorsOnce();
                const UINT8* name = (const UINT8*)data_buf;
                UINT32 name_len = req->data_size;

                // ---- name validation (the M4 discipline) ----
                bool name_ok = (name != nullptr) &&
                               (name_len >= 1) && (name_len <= 64);
                if (name_ok) {
                    for (UINT32 i = 0; i < name_len; i++) {
                        if (name[i] < 0x21 || name[i] > 0x7E) {
                            name_ok = false; break;
                        }
                    }
                }

                UINT32 rc = 0, name_index = 0, fail_rc = 2;
                UINT64 resolved_va = 0;
                if (!name_ok) {
                    fail_rc = 2;                      // invalid name
                } else if (ka::g_result.state !=
                           ka::kAnchorConverged) {
                    rc = 0; fail_rc = 1;              // no gate, refuse
                } else {
                    kx::Ctx c{ka::g_result.pe_base,
                              ka::g_result.pe_size, 0, 0};
                    kx::ResolveResult rr =
                        kx::Resolve(&c, (const char*)name, name_len);
                    rc = rr.rc; name_index = rr.name_index;
                    resolved_va = rr.resolved_va;
                    fail_rc = (rc == 1) ? 0 : rc;     // 0=ok / 1 / 3 / 4
                }

                // ---- KPCR capture (live, per request — the v21
                //      contract; CPU-dependent by design) ----
                UINT64 kpcr = An_ReadMSR(0xC0000101); // IA32_GS_BASE
                UINT32 idt_match = 0;
                if (kpcr >= 0xFFFF800000000000ULL &&
                    (kpcr & 0xFFF) == 0) {
                    UINT64 kidt = *(volatile UINT64*)(UINTN)(kpcr + 0x38);
                    if (ka::g_result.state == ka::kAnchorConverged &&
                        kidt == ka::g_result.idt_base)
                        idt_match = 1;
                }
                SerialTrace::KV("KPCR", "gs base", kpcr);
                SerialTrace::KVD("KPCR", "idt match", idt_match);

                SerialTrace::KVD("XS", "resolve rc", fail_rc);
                SerialTrace::KV("XS", "resolved va", resolved_va);
                SerialTrace::KVD("XS", "name index", name_index);

                // ---- 64-byte payload ----
                UINT8* p = (UINT8*)data_buf;
                for (UINTN i = 0; i < 64; i++) p[i] = 0;
                auto put32 = [&p](UINTN off, UINT32 v) {
                    for (UINTN i = 0; i < 4; i++)
                        p[off + i] = (UINT8)(v >> (8 * i));
                };
                auto put64 = [&p](UINTN off, UINT64 v) {
                    for (UINTN i = 0; i < 8; i++)
                        p[off + i] = (UINT8)(v >> (8 * i));
                };
                put32(0, rc);
                put32(4, name_index);
                put64(8, resolved_va);
                put64(16, ka::g_result.pe_base);
                put64(24, ka::g_result.pe_size);
                put64(32, kpcr);
                put64(40, ka::g_result.idt_base);
                put32(48, (rc == 1) ? name_len : 0);
                put32(52, fail_rc);
                put32(56, idt_match);
                put32(60, 0);
                resp->bytes_transferred = 64;
                *data_size = 64;
                if (rc == 1)      resp->status = SlotStatus_Success;
                else if (!name_ok) resp->status = SlotStatus_ErrGeneric;
                else if (rc == 0)  resp->status = SlotStatus_ErrNotFound;
                else               resp->status = (SlotStatus)rc;
                break;
            }
            case 11 /* ReqOp_ProcessWalk — v24 F3: the EPROCESS walk.
                    data_size = requested entries outN (1..32); pid is
                    IGNORED (kernel-list data only — no per-process
                    address space access, so no pid gate applies).
                    Payload 1064B = entries[32] x 32B
                    {pid, flags(bit0=name echoed), eproc, name[8], pad},
                    then status@1024, count@1028 (total walked),
                    sysEntry@1032 (the DEREF'D System EPROCESS VA —
                    v24: pool, OUTSIDE the image), nameOfs@1040,
                    closed@1044,
                    pages@1048, stored@1052, dtb@1056 (u64, v25: the
                    System DirectoryTableBase, EPROCESS+0x28, PCID-
                    masked — the F4 two-way-proof source; 0 when the
                    walk refused). Status: 1 ok / 7 no-entry
                    / 4 walk refusal / 5 bad args. */: {
                DiscoverAnchorsOnce();
                UINT32 out_n = req->data_size;
                pw::Result wr{};
                pw::Entry entries[32] = {};
                if (out_n >= 1 && out_n <= 32) {
                    // ---- S1+S2 (v24): resolve PsInitialSystemProcess
                    //      via F2, then DEREF the in-image pointer
                    //      slot — the symbol is a POINTER VARIABLE;
                    //      *(u64*)slot is the System EPROCESS (a
                    //      pool object OUTSIDE the image). v23
                    //      walked from the slot VA itself: pid@slot
                    //      +0x440 read .data garbage -> kPwNotSys
                    //      (the v31 field run). The deref goes
                    //      through the same gated in-image Rd32 as
                    //      every export read — no new trust root,
                    //      and WalkCore validates the target. ----
                    const char* s1name = "PsInitialSystemProcess";
                    UINT32 s1len = 22;
                    kx::Ctx c{ka::g_result.pe_base,
                              ka::g_result.pe_size, 0, 0};
                    UINT64 sym_va = 0, sys_eproc = 0;
                    bool have = (ka::g_result.state ==
                                 ka::kAnchorConverged)
                        ? pw::SysEprocessFromSymbol(&c, s1name, s1len,
                                                    &sym_va, &sys_eproc)
                        : false;
                    if (!have) {
                        wr.status = pw::kPwNoEntry;
                    } else {
                        SerialTrace::KV("PW", "sys", sym_va);
                        SerialTrace::KV("PW", "eproc", sys_eproc);
                        pw::Budget bud{0, pw::kPwMaxPages};
                        wr = pw::WalkCore(sys_eproc, entries, out_n,
                                          &bud);
                    }
                } else {
                    wr.status = pw::kPwBadArgs;
                }
                SerialTrace::KVD("PW", "walk", wr.count);
                SerialTrace::KVD("PW", "closed", wr.closed);
                SerialTrace::KVD("PW", "name slot", wr.name_ofs);

                // ---- v25: the System DTB echo (the F4 source) —
                //      EPROCESS+0x28 via the pt gates (canonical +
                //      pid==4 + frame sanity), only after a good walk.
                //      The op-12 engine re-derives it independently;
                //      this echo lets the script cross-check both. ----
                pt::u32 pt_reads = 0;
                pt::u64 eproc_dtb = 0;
                if (wr.status == pw::kPwOk)
                    pt::EprocDtb(wr.sys_entry, &pt_reads, &eproc_dtb);

                // ---- 1064-byte payload ----
                UINT8* p = (UINT8*)data_buf;
                for (UINTN i = 0; i < 1064; i++) p[i] = 0;
                auto put32 = [&p](UINTN off, UINT32 v) {
                    for (UINTN i = 0; i < 4; i++)
                        p[off + i] = (UINT8)(v >> (8 * i));
                };
                auto put64 = [&p](UINTN off, UINT64 v) {
                    for (UINTN i = 0; i < 8; i++)
                        p[off + i] = (UINT8)(v >> (8 * i));
                };
                UINT32 store_n = (wr.stored < 32) ? wr.stored : 32;
                for (UINT32 e = 0; e < store_n; e++) {
                    UINTN o = (UINTN)e * 32;
                    put32(o + 0,  entries[e].pid);
                    put32(o + 4,  entries[e].flags);
                    put64(o + 8,  entries[e].eproc);
                    for (UINTN k = 0; k < 8; k++)
                        p[o + 16 + k] = entries[e].name[k];
                    put32(o + 24, 0);
                }
                put32(1024, wr.status);
                put32(1028, wr.count);
                put64(1032, wr.sys_entry);
                put32(1040, wr.name_ofs);
                put32(1044, wr.closed);
                put32(1048, wr.pages);
                put32(1052, wr.stored);
                put64(1056, eproc_dtb & pt::kPtPfnMask);
                resp->bytes_transferred = 1064;
                *data_size = 1064;
                if (wr.status == pw::kPwOk)
                    resp->status = SlotStatus_Success;
                else if (wr.status == pw::kPwNoEntry)
                    resp->status = SlotStatus_ErrNotFound;
                else if (wr.status == pw::kPwBadArgs)
                    resp->status = SlotStatus_ErrInvalid;
                else
                    resp->status = SlotStatus_ErrAccess;
                break;
            }
            case 12 /* ReqOp_TranslateVa — v27 F4: VA -> page-table
                    walk through the self-map (v26: the level-base
                    formula fix; v27: chain B DELETED — the v38 field
                    analysis proved all 5 MmPfnDatabase RVAs wrong
                    (3 dead + 2 poison, the BSOD fingerprint class);
                    NO CR3 switching — the v17/v19 lesson; NO
                    physical reads; NO kernel calls; [PT] serial
                    traces fire BEFORE every PTE-space read — the
                    last line names any killer). req->address = the
                    target kernel VA (canonical upper half only;
                    user-range and non-canonical -> kPtBadArgs).
                    data_size ignored. PTE_BASE discovery: chain A =
                    nt!MmPteBase (.data, RVA candidates from 19 real
                    19041/19045 PDBs; slot 0xCFB358 FIELD-PINNED by
                    the v38 ALMOSTRO dump) with the 512-value
                    structural check — A gates ALL PTE-space reads.
                    Payload 96B: rc@0 (1 ok / 2 no-base / 4
                    not-present / 5 bad args / 6 refused), selfIdx@4
                    (the self-map PML4 index s), pteBase@8, cr3@16
                    (System DTB, EPROCESS+0x28, PCID-masked; 0 = the
                    eproc chain refused — reported, not fatal),
                    pml4e@24, pdpte@32, pde@40, pte@48 (raw entries;
                    0 = the walk stopped above that level), frame@56
                    (phys page base of the translation), presentMask@
                    64 (bit0..3 = level present, bit4 = large page),
                    source@68 (bit0-1 = MmPteBase candidate; v27:
                    bits 4/5 dead — chain B deleted, always 0),
                    selfOk@72 (bit0 = the PTE space is LIVE: the
                    self-ref slot read succeeded, the entry is
                    present, its frame is sane; bit1 = THE IDENTITY:
                    self-ref frame == the LIVE CR3 frame captured in
                    THIS caller context — 1 is the EXPECTED value in
                    ANY context, the read + the register prove the
                    formulas together), reads@76, liveCr3@80 (v27
                    additive: the CR3 register at op-12 time, raw),
                    selfEntry@88 (v27 additive: the raw PML4E[s]
                    qword). Status:
                    1 ok / 1 with rc=4 (not present — a clean
                    answer) / 7 no-base / 5 bad args / 4 refused. */: {
                DiscoverAnchorsOnce();
                UINT64 target = req->address;
                pt::Result tr{};
                if (ka::g_result.state == ka::kAnchorConverged) {
                    kx::Ctx c{ka::g_result.pe_base,
                              ka::g_result.pe_size, 0, 0};
                    tr = pt::Translate(&c, target);
                } else {
                    tr.status = pt::kPtBadArgs;
                }
                SerialTrace::KV("PT", "va", target);
                SerialTrace::KV("PT", "ptebase", tr.pte_base);
                SerialTrace::KVD("PT", "self", tr.self_idx);
                SerialTrace::KVD("PT", "mask", tr.present_mask);
                SerialTrace::KV("PT", "frame", tr.frame);
                SerialTrace::KVD("PT", "selfok", tr.self_ok);
                SerialTrace::KV("PT", "cr3live", tr.live_cr3);
                SerialTrace::KV("PT", "selfent", tr.self_entry);

                // ---- 96-byte payload (v27: +liveCr3@80,
                //      +selfEntry@88 — additive tail, fields 0..79
                //      byte-identical to the v26 contract) ----
                UINT8* p = (UINT8*)data_buf;
                for (UINTN i = 0; i < 96; i++) p[i] = 0;
                auto put32 = [&p](UINTN off, UINT32 v) {
                    for (UINTN i = 0; i < 4; i++)
                        p[off + i] = (UINT8)(v >> (8 * i));
                };
                auto put64 = [&p](UINTN off, UINT64 v) {
                    for (UINTN i = 0; i < 8; i++)
                        p[off + i] = (UINT8)(v >> (8 * i));
                };
                put32(0,  tr.status);
                put32(4,  tr.self_idx);
                put64(8,  tr.pte_base);
                put64(16, tr.cr3);
                put64(24, tr.pml4e);
                put64(32, tr.pdpte);
                put64(40, tr.pde);
                put64(48, tr.pte);
                put64(56, tr.frame);
                put32(64, tr.present_mask);
                put32(68, tr.source);
                put32(72, tr.self_ok);
                put32(76, tr.reads);
                put64(80, tr.live_cr3);
                put64(88, tr.self_entry);
                resp->bytes_transferred = 96;
                *data_size = 96;
                if (tr.status == pt::kPtOk ||
                    tr.status == pt::kPtNotPresent)
                    resp->status = SlotStatus_Success;
                else if (tr.status == pt::kPtBadArgs)
                    resp->status = SlotStatus_ErrInvalid;
                else if (tr.status == pt::kPtNoBase)
                    resp->status = SlotStatus_ErrNotFound;
                else
                    resp->status = SlotStatus_ErrAccess;
                break;
            }
            case ReqOp_Read: {
                // v18: pid == KERNEL_TARGET_PID selects the KERNEL
                // target - the read is a DIRECT volatile read in the
                // hook's own context (the caller's mapping), gated
                // to the two KUSER_SHARED_DATA windows. This is the
                // data-path proof route (KUSD reads); a VA outside
                // the windows fails the gate cleanly (ErrAccess)
                // BEFORE any access - no page walk, no CR3 switch
                // (the v17 walk was the v19/v20 VM killer). Any
                // other pid without an attached process keeps the
                // same clean ErrAccess failure as before - the real
                // client is unaffected.
                BOOLEAN ok;
                if (req->pid == KERNEL_TARGET_PID) {
                    SerialTrace::KV("RD", "mapped va", req->address);
                    ok = mem_->ReadKernelVA(req->address, data_buf,
                                            req->data_size);
                    SerialTrace::KVD("RD", "mapped read ok", ok ? 1u : 0u);
                } else {
                    ok = mem_->ReadVA(req->address, data_buf,
                                      req->data_size);
                }
                resp->status = ok ? SlotStatus_Success : SlotStatus_ErrAccess;
                resp->bytes_transferred = ok ? req->data_size : 0;
                *data_size = ok ? req->data_size : 0;
                break;
            }
            case ReqOp_Write: {
                BOOLEAN ok = mem_->WriteVA(req->address, data_buf, req->data_size);
                resp->status = ok ? SlotStatus_Success : SlotStatus_ErrAccess;
                resp->bytes_transferred = ok ? req->data_size : 0;
                break;
            }
            case ReqOp_Attach: {
                // CRITICAL FIX #4: Use PID from the request to verify
                // that the process we found matches the requested PID.
                UEFIBridge::ProcessInfo info{};
                BOOLEAN found = finder_->FindByName(
                    (const CHAR8*)"aow_exe.exe", &info);
                if (!found) {
                    found = finder_->FindByName(
                        (const CHAR8*)"AndroidProcess.exe", &info);
                }
                if (!found) {
                    found = finder_->FindByName(
                        (const CHAR8*)"LdVBoxHeadless.exe", &info);
                }
                if (!found) {
                    found = finder_->FindByName(
                        (const CHAR8*)"HD-Player.exe", &info);
                }
                if (found) {
                    // Validate PID matches if a specific PID was requested.
                    // PID 0 means "any" (don't care about specific PID).
                    if (req->pid != 0 && info.pid != req->pid) {
                        resp->status = SlotStatus_ErrNotFound;
                        mem_->ClearTargetCR3();
                    } else {
                        mem_->SetTargetCR3(info.cr3);
                        resp->status = SlotStatus_Success;
                        resp->out_address = info.cr3;
                    }
                } else {
                    resp->status = SlotStatus_ErrNotFound;
                    mem_->ClearTargetCR3();
                }
                break;
            }
            case ReqOp_Ping: {
                resp->status = SlotStatus_Success;
                break;
            }
            default:
                resp->status = SlotStatus_ErrUnsupported;
                break;
            }
        }

    private:
        static VOID EFIAPI TimerCallback(EFI_EVENT /*event*/, VOID* ctx) {
            auto* self = static_cast<RequestHandler*>(ctx);
            self->ProcessPendingRequests();
        }

        void ProcessOneRequest(const ::RequestSlot& req, ::ResponseSlot* resps) {
            MEMORY_FENCE_ACQUIRE();
            std::uint32_t w_idx = pool_->Header()->response_write_idx;
            std::uint32_t next = (w_idx + 1) & (RING_BUFFER_SLOTS - 1);
            if (next == pool_->Header()->response_read_idx) {
                // Response ring is full. Drop this request (backpressure).
                // #90 fix: We still advance the read index to avoid permanent
                // head-of-line blocking, but the request is lost.
                pool_->Header()->total_errors = pool_->Header()->total_errors + 1;
                return;
            }

            ::ResponseSlot& resp = resps[w_idx];
            resp.sequence = req.sequence;
            resp.status   = SlotStatus_ErrGeneric;
            resp.bytes_transferred = 0;
            resp.out_address = 0;
            resp.old_protect = 0;
            resp.crc32       = 0;
            resp.data_offset = 0;

            // VALIDATE request bounds before any data pool access.
            // #91, #67: prevent buffer overflows in UEFI-side data pool.
            // #FINDING-08: overflow-safe checks — check each value
            // individually against DATA_POOL_SIZE before adding.
            if (req.data_size > DATA_POOL_SIZE) {
                resp.status = SlotStatus_ErrInvalid;
                pool_->Header()->response_write_idx = next;
                MEMORY_FENCE_RELEASE();
                return;
            }
            if (req.data_offset > DATA_POOL_SIZE) {
                resp.status = SlotStatus_ErrInvalid;
                pool_->Header()->response_write_idx = next;
                MEMORY_FENCE_RELEASE();
                return;
            }
            // Overflow-safe: check offset <= limit AND size <= limit - offset
            if (req.data_offset > DATA_POOL_SIZE - req.data_size) {
                resp.status = SlotStatus_ErrInvalid;
                pool_->Header()->response_write_idx = next;
                MEMORY_FENCE_RELEASE();
                return;
            }

            switch (req.op) {
            case ReqOp_Read: {
                UINT8* out = pool_->DataPool() + 0;  // always read into offset 0
                BOOLEAN ok = mem_->ReadVA(req.address, out, req.data_size);
                resp.status = ok ? SlotStatus_Success : SlotStatus_ErrAccess;
                resp.bytes_transferred = ok ? req.data_size : 0;
                resp.data_offset = 0;
                break;
            }
            case ReqOp_Write: {
                UINT8* src = pool_->DataPool() + req.data_offset;
                BOOLEAN ok = mem_->WriteVA(req.address, src, req.data_size);
                resp.status = ok ? SlotStatus_Success : SlotStatus_ErrAccess;
                resp.bytes_transferred = ok ? req.data_size : 0;
                break;
            }
            case ReqOp_Attach: {
                // Use the PID from the request to find and verify the process.
                UEFIBridge::ProcessInfo info{};
                BOOLEAN found = FALSE;
                // Try emulator process names in order.
                found = finder_->FindByName(
                    (const CHAR8*)"aow_exe.exe", &info);
                if (!found) found = finder_->FindByName(
                    (const CHAR8*)"AndroidProcess.exe", &info);
                if (!found) found = finder_->FindByName(
                    (const CHAR8*)"LdVBoxHeadless.exe", &info);
                if (!found) found = finder_->FindByName(
                    (const CHAR8*)"HD-Player.exe", &info);
                if (found) {
                    // PID validation: if a specific PID was requested (nonzero),
                    // verify it matches the found process.
                    // PID 0 means "any" (don't care about specific PID).
                    if (req.pid != 0 && info.pid != req.pid) {
                        resp.status = SlotStatus_ErrNotFound;
                        mem_->ClearTargetCR3();
                    } else {
                        mem_->SetTargetCR3(info.cr3);
                        resp.status = SlotStatus_Success;
                        resp.out_address = info.cr3;
                    }
                } else {
                    resp.status = SlotStatus_ErrNotFound;
                    mem_->ClearTargetCR3();
                }
                break;
            }
            case ReqOp_Ping: {
                resp.status = SlotStatus_Success;
                break;
            }
            default:
                resp.status = SlotStatus_ErrUnsupported;
                break;
            }

            pool_->Header()->response_write_idx = next;
            MEMORY_FENCE_RELEASE();
            pool_->Header()->total_responses = pool_->Header()->total_responses + 1;
        }

        SharedMemoryPool* pool_       = nullptr;
        ProcessMemory*    mem_        = nullptr;
        ProcessFinder*    finder_     = nullptr;
        EFI_EVENT         timer_event_ = nullptr;
        bool              running_    = false;
    };

} // namespace UEFIBridge
