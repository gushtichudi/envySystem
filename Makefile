all: buildos

# ---- info about os itself ---- #
PROG_NAME=envySystem
PROG_ARCH=`uname -m`
PROG_VERSION=0.0.1-0

# ---- build info ---- #
ASM=nasm

SRCDIR=src
BINDIR=build

FLOPPY_NAME=$(PROG_NAME)-$(PROG_ARCH)-$(PROG_VERSION).img

makefloppy:
	cp $(BINDIR)/main.bin $(BINDIR)/$(FLOPPY_NAME)
	truncate -s 1440k $(BINDIR)/$(FLOPPY_NAME)

buildos:
	@echo "Building: $(PROG_NAME) version $(PROG_VERSION) compiled on an $(PROG_ARCH)..."
	@echo "============================================================================="
	@echo

	@echo "[ #0 ] building $(PROG_NAME) binary"
	$(ASM) $(SRCDIR)/kernel.asm -f bin -o $(BINDIR)/main.bin

	@echo "[done] now, run make makefloppy to generate an iso to work with."