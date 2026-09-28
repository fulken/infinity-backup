/**
 * WindowsOffsets.h  (UEFI side)
 * =================================================================
 * Offsets for Windows kernel structures needed to walk the
 * EPROCESS list and find a target process.
 *
 * These offsets change between Windows versions. We support
 * Windows 10 1809-22H2 and Windows 11 21H2-23H2.
 *
 * For a production build, you'd want to detect the build number
 * at runtime via the KUSER_SHARED_DATA structure (0xFFFFF78000000000).
 * v15/v16 field truth (empirical, live Win10 19045 x64): the build
 * dword lives at +0x260 (the classic x64 NtBuildNumber offset);
 * +0x308 read 0. Both offsets are probed at runtime anyway
 * (KUSD_OFS_BUILD_CANDIDATES) - the constant is only a hint.
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
#include <cstdint>

namespace UEFIBridge {

    // =========================================================
    // KUSER_SHARED_DATA — always at fixed virtual address.
    // Contains build number.
    // v15 fix: the base-repo claim "#111: 0x308 for 1607+" was
    // DISPROVED empirically — the v14 run read an implausible
    // value at +0x308 on a live Windows 10 19045 x64. 0x260 is
    // the classic x64 NtBuildNumber offset. v15 probes BOTH and
    // traces the raw values, so the next report settles it with
    // ground truth instead of a guessed constant.
    // =========================================================
    constexpr UINT64 KUSER_SHARED_DATA_VA = 0xFFFFF78000000000ULL;
    constexpr UINT32 KUSD_OFS_BUILD_CANDIDATES[2] = { 0x260, 0x308 };
    inline bool KusdBuildPlausible(UINT32 b) {
        return b >= 15000 && b < 99999;
    }

    // =========================================================
    // Windows kernel structure offsets.
    // Fields that vary by build are stored in a table.
    // =========================================================
    struct WinKernelOffsets {
        UINT32 EPROCESS_UniqueProcessId;       // offset of UniqueProcessId in EPROCESS
        UINT32 EPROCESS_ActiveProcessLinks;     // offset of ActiveProcessLinks
        UINT32 EPROCESS_ImageFileName;          // offset of ImageFileName (15-byte char array)
        UINT32 EPROCESS_DirectoryTableBase;     // offset of CR3 (DirectoryTableBase)
        UINT32 EPROCESS_Peb;                    // offset of Peb pointer
        UINT32 EPROCESS_VadRoot;                // offset of VadRoot
        UINT32 PsActiveProcessHead_Offset;      // offset of PsActiveProcessHead in ntoskrnl
    };

    // Build 17763 (1809 / Server 2019)
    constexpr WinKernelOffsets WIN10_17763 = {
        /*UniqueProcessId*/      0x2E8,
        /*ActiveProcessLinks*/   0x2F0,
        /*ImageFileName*/        0x5A8,
        /*DirectoryTableBase*/   0x028,
        /*Peb*/                  0x550,
        /*VadRoot*/              0x7D8,
        /*PsActiveProcessHead*/  0,  // must be resolved at runtime
    };

    // Build 19041/19042 (2004/20H2)
    constexpr WinKernelOffsets WIN10_19041 = {
        /*UniqueProcessId*/      0x440,
        /*ActiveProcessLinks*/   0x448,
        /*ImageFileName*/        0x5A8,
        /*DirectoryTableBase*/   0x028,
        /*Peb*/                  0x550,
        /*VadRoot*/              0x7D8,
        /*PsActiveProcessHead*/  0,
    };

    // Build 19045 (22H2)
    constexpr WinKernelOffsets WIN10_19045 = {
        /*UniqueProcessId*/      0x440,
        /*ActiveProcessLinks*/   0x448,
        /*ImageFileName*/        0x5A8,
        /*DirectoryTableBase*/   0x028,
        /*Peb*/                  0x550,
        /*VadRoot*/              0x7C8,
        /*PsActiveProcessHead*/  0,
    };

    // Build 22000 (Win 11 21H2)
    constexpr WinKernelOffsets WIN11_22000 = {
        /*UniqueProcessId*/      0x440,
        /*ActiveProcessLinks*/   0x448,
        /*ImageFileName*/        0x5A8,
        /*DirectoryTableBase*/   0x028,
        /*Peb*/                  0x550,
        /*VadRoot*/              0x7C8,
        /*PsActiveProcessHead*/  0,
    };

    // Build 22621 (Win 11 22H2)
    constexpr WinKernelOffsets WIN11_22621 = {
        /*UniqueProcessId*/      0x440,
        /*ActiveProcessLinks*/   0x448,
        /*ImageFileName*/        0x5A8,
        /*DirectoryTableBase*/   0x028,
        /*Peb*/                  0x550,
        /*VadRoot*/              0x7C8,
        /*PsActiveProcessHead*/  0,
    };

    // Build 26100 (Win 11 24H2)
    constexpr WinKernelOffsets WIN11_26100 = {
        /*UniqueProcessId*/      0x450,
        /*ActiveProcessLinks*/   0x458,
        /*ImageFileName*/        0x5B8,
        /*DirectoryTableBase*/   0x028,
        /*Peb*/                  0x550,
        /*VadRoot*/              0x7D8,
        /*PsActiveProcessHead*/  0,
    };

    // =========================================================
    // Detect Windows build number via KUSER_SHARED_DATA.
    // Returns 0 if not detected.
    // =========================================================
    inline UINT32 DetectWindowsBuildNumber(class PhysicalMemory* pm, UINT64 os_cr3) {
        // v15: probe BOTH candidate offsets; return the first
        // plausible build (0 if none / not readable).
        UINT32 build = 0;
        for (int i = 0; i < 2; i++) {
            if (!pm->ReadVA(KUSER_SHARED_DATA_VA + KUSD_OFS_BUILD_CANDIDATES[i],
                            os_cr3, &build, sizeof(build))) {
                continue;
            }
            build &= 0x7FFFFFFF;  // high bit is the checked-build flag
            if (KusdBuildPlausible(build)) return build;
        }
        return 0;
    }

    // =========================================================
    // Get offsets for a specific build.
    // #110 fix: fail closed for unknown builds.
    // =================================================================
    inline bool GetOffsetsForBuild(UINT32 build, WinKernelOffsets& out) {
        switch (build) {
            case 17763:  out = WIN10_17763; return true;
            case 19041:
            case 19042:
            case 19043:
            case 19044:  out = WIN10_19041; return true;
            case 19045:  out = WIN10_19045; return true;
            case 22000:  out = WIN11_22000; return true;
            case 22621:
            case 22631:  out = WIN11_22621; return true;
            case 26100:
            case 26200:  out = WIN11_26100; return true;
            default:
                // Unknown build: fail closed (return false).
                // Do NOT silently fall back to wrong offsets.
                return false;
        }
    }

} // namespace UEFIBridge
