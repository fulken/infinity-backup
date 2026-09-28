# =================================================================
# Makefile for memory.efi (UEFI side of Infinity bridge)  —  v6
# =================================================================
# Requirements:
#   - Ubuntu (or any Linux with GNU-EFI) — CI uses ubuntu-22.04 with
#     the distro gnu-efi 3.0.13 package.
#
# Usage:
#   make              # SAFE build of memory.efi (no gRT hooks)
#   make RT=1         # RT build (gRT hooks from SetVirtualAddressMap)
#   make clean
#
# Overrides used by our sandbox build (local gnu-efi 3.0.13 tree):
#   make EFI_LIB_DIR=/path/gnuefi-jammy/usr/lib \
#        EFI_INC_DIR=/path/gnuefi-jammy/usr/include/efi
#
# v6 changes vs baseline:
#   - R4: -fvisibility=hidden (kills C++ vague-linkage GLOB_DAT
#     relocations that gnu-efi's _relocate never applies).
#   - R6: vendored linker script gnuefi-x86_64.ld (.bss* wildcards).
#   - RT=1 defines INFINITY_ENABLE_RUNTIME_HOOKS (phase D build).
# =================================================================

# Allow overriding the EFI include directory.
EFI_ARCH     ?= x86_64
EFI_LIB_DIR  ?= /usr/lib
EFI_INC_DIR  ?= /usr/include/efi
EFI_CRT0     ?= $(EFI_LIB_DIR)/crt0-efi-$(EFI_ARCH).o

# RT=1 -> phase D build (runtime hooks enabled). Default SAFE.
RT           ?= 0

CC           ?= gcc
CXX          ?= g++
LD           ?= ld
OBJCOPY      ?= objcopy

# If the default EFI_INC_DIR doesn't have efi.h, try to find it.
ifeq ($(wildcard $(EFI_INC_DIR)/efi.h),)
  ifneq ($(wildcard /usr/include/efi/efi.h),)
    EFI_INC_DIR := /usr/include/efi
  endif
endif

# Build-variant defines.
ifeq ($(RT),1)
  VARIANT_DEFS = -DINFINITY_ENABLE_RUNTIME_HOOKS
  VARIANT_NAME = rt
else
  VARIANT_DEFS =
  VARIANT_NAME = safe
endif

CFLAGS       ?= -I$(EFI_INC_DIR) -I$(EFI_INC_DIR)/$(EFI_ARCH) \
	        -I../include -I../../Memory/include \
	        -fno-stack-protector -fno-stack-check \
	        -fpic -fshort-wchar -mno-red-zone -Wno-unused \
	        -DGNU_EFI_USE_MS_ABI -DEFI_FUNCTION_WRAPPER \
	        -Wall -Wextra -O2 -std=c11 \
	        -fvisibility=hidden

# Use C++ compiler for the .c file because we use C++ features
# (templates, std::atomic, classes, namespaces). gnu-efi works fine
# with g++ as long as we use the right flags.
#
# -fno-exceptions -fno-rtti: no C++ exception/RTTI support in UEFI.
# -fno-threadsafe-statics: don't emit __cxa_guard_acquire for static
#   locals (which requires __dso_handle).
# -fno-use-cxa-atexit / -fno-cxa-atexit: no __cxa_atexit dtor calls.
CXXFLAGS     ?= -I$(EFI_INC_DIR) -I$(EFI_INC_DIR)/$(EFI_ARCH) \
	        -I../include -I../../Memory/include \
	        -fno-stack-protector -fno-stack-check \
	        -fpic -fshort-wchar -mno-red-zone -Wno-unused \
	        -DGNU_EFI_USE_MS_ABI -DEFI_FUNCTION_WRAPPER \
	        -Wall -Wextra -O2 -std=c++17 -fno-exceptions -fno-rtti \
	        -fno-threadsafe-statics -fno-use-cxa-atexit \
	        -fcheck-new \
	        -fvisibility=hidden \
	        $(VARIANT_DEFS)

# R6: vendored linker script (see gnuefi-x86_64.ld header comment).
LDFLAGS      ?= -nostdlib -znocombreloc -T gnuefi-x86_64.ld \
	        -shared -Bsymbolic -L$(EFI_LIB_DIR) \
	        --defsym __dso_handle=0

LIBS         ?= -lgnuefi -lefi

OUT_DIR      ?= build
TARGET       ?= $(OUT_DIR)/memory.efi

SRCS         = ../src/main.c
OBJS         = $(OUT_DIR)/main.o

# Optional: extra object file providing __dso_handle as a fallback.
DSO_HANDLE_O = $(OUT_DIR)/dso_handle.o

.PHONY: all clean dump debug variant

all: $(TARGET)

variant:
	@echo "variant: $(VARIANT_NAME) (RT=$(RT))"

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

# Build dso_handle.o — provides the __dso_handle symbol if the
# --defsym trick alone doesn't satisfy the linker.
$(DSO_HANDLE_O): | $(OUT_DIR)
	@echo 'extern "C" { void* __dso_handle = 0; }' | $(CXX) $(CXXFLAGS) -x c++ -c - -o $@

$(TARGET): $(OBJS) $(DSO_HANDLE_O) gnuefi-x86_64.ld | $(OUT_DIR)
	$(LD) $(LDFLAGS) $(EFI_CRT0) $(OBJS) $(DSO_HANDLE_O) -o $(OUT_DIR)/memory.so $(LIBS)
	$(OBJCOPY) --target=efi-rtdrv-x86_64 -j .text -j .sdata -j .data -j .dynamic -j .dynsym \
	-j .rel -j .rela -j .reloc -j .eh_frame \
	$(OUT_DIR)/memory.so $(TARGET)
	@echo "=== built memory.efi (variant: $(VARIANT_NAME)) ==="
	@echo "=== R4 GLOB_DAT check (must be 0) ==="
	@readelf -r $(OUT_DIR)/memory.so 2>/dev/null | grep GLOB_DAT || echo "(none - clean)"
	@echo "=== R6 orphan .bss check (must be empty) ==="
	@objdump -h $(OUT_DIR)/memory.so 2>/dev/null | grep -E "^ [0-9]+ \.bss " || echo "(no orphan .bss - clean)"

$(OUT_DIR)/main.o: $(SRCS) | $(OUT_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(DSO_HANDLE_O) $(OUT_DIR)/memory.efi $(OUT_DIR)/memory.so
	rmdir $(OUT_DIR) 2>/dev/null || true

dump: $(TARGET)
	@echo "=== File info ==="
	file $(TARGET)
	@echo ""
	@echo "=== Build markers ==="
	strings -n 8 $(TARGET) | grep -E "v6 SAFE|v6 RT|INFINITY|fulken" || true
	@echo ""
	@echo "=== GLOB_DAT relocation check (R4: must be 0) ==="
	readelf -r $(OUT_DIR)/memory.so 2>/dev/null | grep GLOB_DAT || echo "(none - clean)"
	@echo ""
	@echo "=== Orphan .bss check (R6: must be empty) ==="
	objdump -h $(OUT_DIR)/memory.so 2>/dev/null | grep -E "^\s+[0-9]+ \.bss" || echo "(no orphan .bss - clean)"

# Diagnostic target — shows where gnu-efi was found.
debug:
	@echo "EFI_ARCH:    $(EFI_ARCH)"
	@echo "EFI_LIB_DIR: $(EFI_LIB_DIR)"
	@echo "EFI_INC_DIR: $(EFI_INC_DIR)"
	@echo "EFI_CRT0:    $(EFI_CRT0)"
	@echo "Variant:     $(VARIANT_NAME) (RT=$(RT))"
	@echo ""
	@echo "Checking efi.h:"
	@ls -la $(EFI_INC_DIR)/efi.h 2>/dev/null || echo "  Not found at $(EFI_INC_DIR)/efi.h"
	@echo ""
	@echo "Checking crt0:"
	@ls -la $(EFI_CRT0) 2>/dev/null || echo "  Not found at $(EFI_CRT0)"
