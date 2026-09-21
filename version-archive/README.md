# آرشیو نسخه‌های Infinity QEMU Test

**این پوشه چیه؟**
گاوصندوق بادوام (git-tracked) برای همه پکیج‌ها، باینری‌ها و ریپورت‌های تست پروژه Infinity QEMU.
درس rollback ها: فایل‌هایی که فقط تو `upload/` (که gitignore شده) یا بدون کامیت می‌مونن، با ریست شدن session از بین می‌رن.
هر چی اینجا کامیت بشه، برای همیشه می‌مونه. **هیچ فایل تحویلی یا ریپورتی نباید فقط تو upload/ بمونه.**

## نقشه نسخه‌ها — `packages/`

| نسخه | تاریخ | وضعیت | چی توشه |
|------|-------|--------|----------|
| v1 | 2026-09-16 | دارم | Phase A/B اولیه؛ بیلد پایه memory.efi با ۶ فیکس استارتاپ (extern-C، efi_main، GOT reloc، .bss orphan و...) |
| v2 | 2026-09-17 | دارم | phase-b واقعی نصب ویندوز (دیسک 64G + NVRAM ماندگار) + phase-c + فیکس FS mapping در startup.nsh |
| v3 | 2026-09-17 | دارم | نردبان شتاب‌دهنده (WHPX 2 هسته → 1 هسته → TCG) بعد از BSOD فاز نصب؛ `-cpu host` |
| v4 | 2026-09-18 | دارم (بازگشتی از کاربر 2026-09-20) | فیکس لانچر: حذف `-fw_cfg X-Cpuhp-Bitmap` (باگ 48GB RAM)، حذف `-cpu host,-hypervisor`، فلگ `-R` + `finish-oobe-tcg.bat` (بایپس OOBE از تست ۳ کاربره) |
| v5 | 2026-09-18 | دارم (بازگشتی از کاربر 2026-09-20) | اولین بیلد RT (`usb-rt/memory.efi` 79295 B) + اولین phase-d.bat + INFDIAG v5 (مراحل ۱-۴) |
| v6 | 2026-09-18 | دارم | ابزار دقیق: SerialTrace (0x3F8) + INFDIAG v6 کامل + last_status + trigger-test اولیه |
| v7 | 2026-09-19 | دارم | فیکس معماری: نصب **زودهنگام** hook در gRT (قبل از snapshot وین‌لود) + BOOT-CTX passthrough |
| v8 / v8.1 | 2026-09-19 | باینری بازیابی شد؛ سورس گم | درایور v8 (فلگ trigger_seen 0x20)؛ usb-d فقط‌خواندنی. باینری از v9 کاربر بازیابی شد → `patches/v8-memory-*.efi` |
| v9 | 2026-09-20 | بازگشتی از کاربر | همان درایور v8 + اسکریپت v10 + **انتقال فایل real-time** (refresh-files + transfer/ + پورت کنترل 5555) + VERSION.txt + هش‌منیفست |
| trigger v10 | 2026-09-20 | دارم (داخل v9 + `patches/trigger-test-v10.ps1`) | اسکریپت تریگر؛ دارای باگ cast هگز منفی (`0xDEADBEEF` → Int32 منفی) |
| trigger v11 | 2026-09-20 | دارم | فیکس باگ cast (HexLe4 رشته‌ای) + تشخیص مرحله‌ای مسیرها (A/B/C/D/E/F) — `infinity-trigger-v11.zip` |

نام‌گذاری zip از v9 به بعد با VERSION.txt داخلی هم‌راستاست (v8 و v8.1 اسم zip یکسانی داشتن که باعث اشتباه شد).

## هش‌های حیاتی (SHA256)

```
infinity-qemu-test-v4.zip (بسته کامل)      4560b053b198b2cc25f227f296cc0d6abc72a92db81eedc12d799a12a8b5a2e4
infinity-qemu-test-v5.zip (بسته کامل)      d74cfb58050b439fac50cd5713931b8805e43e047b5823c2034558913fbbe290
infinity-qemu-test-v9.zip (بسته کامل)      8789ae45d8dbba10b2aa91944e68b528fd19a48f8ec8bd6127b0a1fa0ebd37f7
v4 SAFE driver (73614 B)                   4061f3b1d9a0a45ab271d516a480d9523f98ffe91682528cf901eda105e7a369
v5 SAFE driver (73733 B)                   307bea7fa0b3335b9278303e4d48a02a50b6f0ea1a418f068a1f26f4f66828be
v5 RT driver (usb-rt, 79295 B)             7f999199f3a01926c107163215b47564675cf341241f9fac1b52eba7fbd3bffb
v8 RT driver (usb-d/memory.efi, 115426 B)  d8914ad2b5a4896a77c427ffd7ab585cfbb16f8930ee504753a3bddd4f038edb
v8 SAFE driver (usb/memory.efi, 103437 B)  05d47281b15003d3688fda00f85d4db794fb9ff76f44e59480a38ddde2425585
trigger-test.ps1 v10 (14290 B)              95ecb9477fd149d397d42e9903c89d382618a722400a2c7bea44d060629c66ac
```

(مطابقت هش trigger v10 با منیفست VERSION.txt داخل v9 تأیید شد — بسته سالم و اصل است.)

## ریپورت‌های تست کاربر — `reports/`

| فایل | مربوط به | محتوا / نتیجه کلیدی |
|------|----------|----------------------|
| `infinity-qemu-test-Report.zip` | گزارش BSOD فاز نصب v2 → تحلیل v3 | ۳ اسکرین‌شات + serial phase-a/b؛ BSOD غیرقطعی → مقصر virtualization نه ISO/درایور |
| `infinity-qemu-test-Windows-Reports.zip` | تست ۳ کاربره v3/v4 | نصب با TCG + بایپس OOBE + phase-c سبز؛ منشأ فیکس‌های v4 |
| `infinity-qemu-test-ReportV5.zip` | v5 phase-d | اولین بوت RT تا دسکتاپ بدون BSOD؛ INFDIAG stage 3 |
| `infinity-qemu-test-v6-Report.zip` | v6 phase-d | زنجیره ۱-۲-۳ کامل سبز؛ اسکریپت‌های v7/v8 کاربر؛ کشف ERROR 87 (ترتیب آرگومان SetFirmwareEnvironmentVariable)؛ نتیجه معماری: ویندوز از snapshot جدول gRT استفاده می‌کند → منشأ v7 |
| `infinity-qemu-test-V7-Report.zip` | اجرای v7/v8.1 | بوت سبز + BSOD + شواهد خرابی فایل روی فلش FAT (truncate اسکریپت) → منشأ v8 فقط‌خواندنی |
| `infinity-qemu-test-v9-Report.zip` | v9 phase-d | **hook_calls=20 + کال VIRT = ویندوز از hook های ما صدا می‌زند**؛ خطای cast اسکریپت v10 (با v11 فیکس شد) |
| `loose-evidence/` | اولین اجراها و عیب‌یابی هش | serial/عکس phase-a/b اولیه (v1 era) + اسکرین‌شات‌های عیب‌یابی hash-mismatch و خطای PowerShell (2026-09-20) |

## باینری‌ها و سورس (خارج از این پوشه، همه git-tracked)

- `patches/v4-memory-SAFE.efi` ، `patches/v5-memory-{SAFE,RT}.efi` (بازگشتی از کاربر) ، `patches/v6-memory-{SAFE,RT}.efi` ، `patches/v7-memory-{SAFE,RT}.efi` ، `patches/v8-memory-{SAFE,RT}.efi` — لاین‌بوج کامل باینری از v4 تا v8
- `patches/trigger-test-v10.ps1`
- `patches/v6-on-a8e41b3.diff` ، `patches/v7-on-a8e41b3.diff` (دلتای کامل سورس روی شاخه uefi-full-migration @ a8e41b3)
- سورس v8: هنوز بازسازی نشده — نیاز به clone ریپو + پچ v7 + دلتای مشتق از باینری/لاگ‌ها

## چی هنوز کمه؟ (درخواست از کاربر)

1. ~~v4 و v5~~ — **دریافت شدند** (2026-09-20، بازگشتی از کاربر) — آرشیو اکنون کامل است: v1 تا v9 + trigger v11
2. (اختیاری، لازم نیست) zip های v8 و v8.1 — چون v9 همان باینری‌های معتبر v8.1 را دارد
3. **GITHUB_TOKEN** — فقط هر وقت لازم بشه سورس ریپو دوباره fetch بشه یا آرشیو به گیت‌هاب کاربر push بشه. توکن هیچ‌وقت روی دیسک ذخیره نمی‌شود، پس بعد از هر rollback باید دوباره از کاربر گرفته شود

## راهنمای بازیابی

- پکیج‌ها: از `packages/` کپی/unzip کن
- باینری درایور: `patches/v{6,7,8}-memory-{SAFE,RT}.efi`
- سورس کامل: `GITHUB_TOKEN='...' scripts/fetch-infinity-repo.sh` بعد از اجرای پچ‌های `patches/*-on-a8e41b3.diff`
- تاریخچه تحلیل‌ها: `worklog.md` (Task به Task)
