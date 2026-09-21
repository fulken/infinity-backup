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
| v12 | 2026-09-20 | دارم | observability کامل (ماتریس ۴ سیگنالی README-V12-FA)؛ freshen INFDIAG از داخل hook خواندن دسکتاپ → **اثبات می‌رسه مسیر خواندن به hook** اما فراخوانی orig SetVariable داخل dispatch ویندوز → BSOD KMODE (درس: هرگز orig SetVariable از داخل hook روی مسیر dispatch) |
| v13 | 2026-09-20 | دارم | observability امن: INFDIAG/INFCNT از RAM زنده جواب داده می‌شوند (صفر فراخوانی orig، صفر نوشتن NVRAM) + پچ بسته‌بندی v12.2 (پرانتز داخل بلاک bat)؛ اجرای v13 بدون BSOD |
| v14 | 2026-09-20 | دارم | **فیکس باگ مقایسه GUID** (gnu-efi CompareGuid بازگشتی 0=مساوی، دو call-site با سماتیک EDK2-BOOLEAN استفاده شده بود → سرویس RAM و IsOurVariable هر دو dead-code!) + کپچر live بیلد ویندوز از KUSD (NtBuildNumber@+0x308، صفحه global، خواندن مستقیم volatile) + chain-after-handle دوگانه در S-hook → تست v14 = حکم واقعی full-bridge |
| v15 | 2026-09-20 | دارم | **فیکس ریشهٔ BSOD های v12+v14** (disassembly): جدول هگز SerialTrace به‌صورت `static const char*` کامپایل می‌شد به اسلات اشاره‌گر با آدرس فیزیکی زمان لود — تبدیل‌نشده در VA event → اولین چاپ هگز در بافت ویندوز = #PF؛ v15 آن را به آرایه (rip-relative) تبدیل کرد + پروب دو-آفستهٔ بیلد (0x260+0x308 با تریس مقدار خام) چون +0x308 روی 19045 واقعی نهی بود |
| v16 | 2026-09-21 | دارم | **حقیقت اسکریپت + کازمتیک درایور**: اجرای v15 پل کامل را اثبات کرد (تحلیل سورس: status=1 = SlotStatus_Success است؛ حکم «WRONG-CONTENT» اسکریپت فالس-نگاتیو بود). v16 فقط اسکریپت را درست می‌کند (پارس کامل dword — نمایش بایت‌بریدهٔ v15 مثل 19045→«101»، دیکد نام SlotStatus، ریلبیل [4] برای طراحی RAM-consume، auto-tee خروجی به فایل بدون نیاز به عکس) + کازمتیک صفر-ریسک درایور (بنر صفحهٔ v7→v16، دابل‌پریفیکس `0x=0x` سریال، نوت EBS، کامنت 0x308) — منطق درایور دست‌نخورده |
| v17 | 2026-09-21 | دارم | **اثبات مسیر داده**: پل کامل v16 در فیلد تأیید شد (PONG PERFECT، win 19045=19045، INFCNT=2، stage=4، پرچم 0x20)؛ تنها باگ = ترنسکریپت روی درایو بوت فقط‌خواندنی. v17 یک افزودن جراحیکی به درایور دارد: خواندن هسته‌ای با pid=0xFFFFFFFF (KERNEL_TARGET_PID) → ReadKernelVA صفحه‌بندی CR3 جاریِ ویندوز را walk می‌کند، همهٔ خواندن‌ها فیزیکی از identity map — آدرس خراب ErrAccess تمیز برمی‌گرداند، هیچ مسیر کرشی وجود ندارد؛ اسکریپت قدم‌های H..N (رفت‌وبرگشت بافر InfinityData، دیکد Attach، خواندن بیلد 19045 از KUSD+0x260 از طریق پل، چانک ۸ بایتی، تست منفی، حسابداری INFCNT=8) + فیکس ترنسکریپت (پروب نوشتنی → Desktop → TEMP + تأیید فایل آخر کار) |

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
infinity-qemu-test-v12.zip (بسته کامل)     d4de1a88e9bf3b60 (کامل با sha256sum محلی چک شود)
infinity-qemu-test-v13.zip (بسته کامل)     392da3970eb34cbd (کامل با sha256sum محلی چک شود)
infinity-qemu-test-v14.zip (بسته کامل)     b5ea510a5b4d35d6 (کامل با sha256sum محلی چک شود)
v12 SAFE driver (104457 B)                  1e858c03ef19c2aa... (پیشوند ۱۶ کاراکتری؛ کامل: sha256sum patches/v12-memory-SAFE.efi)
v12 RT driver (117490 B)                   8ac7df0c585c7314... (پیشوند؛ کامل: sha256sum patches/v12-memory-RT.efi)
v13 SAFE driver = v12 SAFE (بدون تغییر)    1e858c03ef19c2aa (فقط RT عوض شد)
v13 RT driver (118002 B)                   dcd9b6e4adee372c... (پیشوند؛ کامل: sha256sum patches/v13-memory-RT.efi)
v14 SAFE driver (104969 B)                 6f6e1d1006da9017... (پیشوند؛ کامل: sha256sum patches/v14-memory-SAFE.efi)
v14 RT driver (119026 B)                   51e8132b2d2496f8... (پیشوند؛ کامل: sha256sum patches/v14-memory-RT.efi)
v15 SAFE driver (105032 B)                 3f2734369e988bc5... (پیشوند؛ کامل: sha256sum patches/v15-memory-SAFE.efi)
v15 RT driver (120229 B)                   af1acda401999a97... (پیشوند؛ کامل: sha256sum patches/v15-memory-RT.efi)
infinity-qemu-test-v15.zip (بسته کامل)     3270130 B — sha256 با sha256sum packages/infinity-qemu-test-v15.zip
infinity-qemu-test-v16.zip (بسته کامل)     3273344 B — sha256 با sha256sum packages/infinity-qemu-test-v16.zip
v16 SAFE driver (105032 B)                 020d69c76e30f156... (پیشوند؛ کامل: sha256sum patches/v16-memory-SAFE.efi)
v16 RT driver (120229 B)                   b9ca2c6b5ce113c0... (پیشوند؛ کامل: sha256sum patches/v16-memory-RT.efi)
trigger-test-v16.ps1 (19894 B)             sha256 کامل در VERSION.txt داخل بستهٔ v16
v17 SAFE driver (105032 B)                 sha256 کامل: sha256sum patches/v17-memory-SAFE.efi
v17 RT driver (120678 B)                   sha256 کامل: sha256sum patches/v17-memory-RT.efi
infinity-qemu-test-v17.zip (بسته کامل)     3283127 B — sha256 با sha256sum packages/infinity-qemu-test-v17.zip
trigger-test-v17.ps1 (30240 B)             sha256 کامل در VERSION.txt داخل بستهٔ v17
```

(پیشوندهای ۱۶ کاراکتری برای خوانایی؛ مقدار کامل هر هش با `sha256sum` روی فایل‌های `patches/` و `packages/` قابل بازتولید است.)

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
| `infinity-qemu-test-V9+trigger-v11-TestReport.zip` | v9 + trigger v11 | اثبات ۴-گانه: بنر + ENV + PRIV + PARTIAL؛ حکم final: full install سبز؛ سورس فیکس‌های v12 |
| `infinity-qemu-test-v12-TestReport.zip` | v12 phase-d | بوت زنجیره ۱۰۰٪ سبز تا G#320؛ PS step A → **BSOD KMODE_EXCEPTION_NOT_HANDLED در ۲۱٪** وسط freshen INFDIAG = خواندن دسکتاپ به hook رسید؛ [CLR] بدون S OURVAR = نوشتن بایپس؛ تحلیل کامل → طراحی v13 |
| `infinity-qemu-test-v13-Report.zip` | v13 phase-d | اجرای بدون‌کرش؛ hook_calls=251 ثابت + INFCNT=203 + InfinityResp=203 → اولاً به‌ظاهر «هر دو مسیر بایپس»؛ شواهد عکس PS + serial-check؛ **بعداً ریشه‌یابی: باگ CompareGuid (v14) — حکم آرتیفکت بود** |
| `infinity-qemu-test-v14-Report.zip` | v14 phase-d | بوت سبز تا دسکتاپ + فیکس GUID کار کرد (۳ تریس S OURVAR delete + اولین G INFDIAG live) → **BSOD KMODE روی step A وسط چاپ هگز**؛ ریشه‌یابی دیس‌اسمبلی: اسلات اشاره‌گر جدول هگز (v12 هم همین بود) + KUSD+0x308 نهی؛ منشأ v15 |
| `infinity-qemu-test-v15-Report.zip` | v15 phase-d | **بهترین نتیجهٔ پروژه**: هر دو مسیر هوک از دسکتاپ اثبات شد (hook_calls زنده 121→134، stage=4، INFCNT=2، پرچم 0x20)، خواندن KUSD زنده کار کرد (`kusd raw 0x260=0x4A65` = بیلد 19045)، **بدون BSOD** و فاز-b-check سالم؛ InfinityResp با seq=0x1337 اکو + status=1 برگشت — آن‌وقت «شکست» تلقی شد اما تحلیل سورس (ANALYSIS-V15.md + تصحیح) نشان داد status=1 = Success است → **پل کامل اثبات شد؛ باگ فقط در نمایش اسکریپت بود** |
| `vars-forensics-v12-v13/` | vars های v12+v13 کاربر | OVMF_VARS_4M.fd هر دو + خروجی dmpstore (Checked)؛ ۱۸ بوت تاریخ INFDIAG decode شد؛ **اثبات باینری فرود freshen v12 (stage=4 flags=0xF calls=341 در NVRAM)** + فرود همه‌ی نوشتن‌های دسکتاپ v13 (INFPROBE/INFTRIGGER/InfinityReq state 0x3F) → نوشتن‌ها به NVRAM می‌رسیدند اما hook تشخیص نمی‌داد (باگ GUID) |
| `loose-evidence/` | اولین اجراها و عیب‌یابی هش | serial/عکس phase-a/b اولیه (v1 era) + اسکرین‌شات‌های عیب‌یابی hash-mismatch و خطای PowerShell (2026-09-20) |

## باینری‌ها و سورس (خارج از این پوشه، همه git-tracked)

- `patches/v4-memory-SAFE.efi` ، `patches/v5-memory-{SAFE,RT}.efi` (بازگشتی از کاربر) ، `patches/v6-memory-{SAFE,RT}.efi` ، `patches/v7-memory-{SAFE,RT}.efi` ، `patches/v8-memory-{SAFE,RT}.efi` — لاین‌بوج کامل باینری از v4 تا v8
- `patches/v12-memory-{SAFE,RT}.efi` ، `patches/v13-memory-{SAFE,RT}.efi` ، `patches/v14-memory-{SAFE,RT}.efi` — باینری‌های v12 تا v14
- `patches/trigger-test-v10.ps1` ، `patches/phase-d-v13.bat` (تمپلیت pristine فاز-d)
- `patches/v6-on-a8e41b3.diff` ، `patches/v7-on-a8e41b3.diff` (دلتای کامل سورس روی شاخه uefi-full-migration @ a8e41b3)
- سورس v12: `scripts/patch-v12.py` روی درخت v7؛ v13: `scripts/patch-v13.py`؛ v14: `scripts/patch-v14.py` (فیکس GUID + KUSD live build) — همه anchored روی a8e41b3
- سورس v8: هنوز بازسازی نشده — نیاز به clone ریپو + پچ v7 + دلتای مشتق از باینری/لاگ‌ها

## چی هنوز کمه؟ (درخواست از کاربر)

1. ~~v4 و v5~~ — **دریافت شدند** (2026-09-20، بازگشتی از کاربر) — آرشیو اکنون کامل است: v1 تا v14 + trigger v11 + گزارش‌های v12/v13 + vars فارنزیک
2. (اختیاری، لازم نیست) zip های v8 و v8.1 — چون v9 همان باینری‌های معتبر v8.1 را دارد
3. **GITHUB_TOKEN** — فقط هر وقت لازم بشه سورس ریپو دوباره fetch بشه یا آرشیو به گیت‌هاب کاربر push بشه. توکن هیچ‌وقت روی دیسک ذخیره نمی‌شود، پس بعد از هر rollback باید دوباره از کاربر گرفته شود

## راهنمای بازیابی

- پکیج‌ها: از `packages/` کپی/unzip کن
- باینری درایور: `patches/v{6,7,8}-memory-{SAFE,RT}.efi`
- سورس کامل: `GITHUB_TOKEN='...' scripts/fetch-infinity-repo.sh` بعد از اجرای پچ‌های `patches/*-on-a8e41b3.diff`
- تاریخچه تحلیل‌ها: `worklog.md` (Task به Task)
| `infinity-qemu-test-v16-Report.zip` | v16 phase-d | **حکم کامل سبز — «FULL BRIDGE PROVEN - PHASE D COMPLETE»**: PONG PERFECT (seq=0x1337 اکو، status=1(Success) دیکد شد)، win_build درایور=19045=اسکریپت، INFCNT=2، پرچم TRIGGER-SEEN ست، stage=4 (اولین مشاهدهٔ فیلدی)، hook_calls 381→394 مونوتون؛ فیکس‌های dword/دیکد status همه تأیید شدند؛ NVRAM منجمد stage-3 سازگار؛ تنها نقص = auto-tee روی درایو فقط‌خواندنی (عکس ۲ پارتی جایگزین شد) → منشأ فیکس v17. تحلیل کامل: `reports/ANALYSIS-V16.md` |