# ---- info about os itself ---- #
PROG_NAME=envySystem
PROG_ARCH=`uname -m`
PROG_VERSION=0.0.2-0

# ---- build info ---- #
ASM=nasm

KERNDIR=kernel/
BOOTDIR=boot/
BINDIR=build

FLOPPY_NAME=$(PROG_NAME)-$(PROG_ARCH)-$(PROG_VERSION).img

.PHONY: all clean always makefloppy makeboot makekern

# ---- make floppy ---- #
makefloppy: makeboot makekern
	@echo "[ #1 ] creating floppy image"
	dd if=/dev/zero of=$(BINDIR)/$(FLOPPY_NAME) bs=512 count=2880
	mkfs.fat -F 12 -n "ENVYSYS" $(BINDIR)/$(FLOPPY_NAME)
	dd conv=notrunc if=$(BINDIR)/boot.bin of=$(BINDIR)/$(FLOPPY_NAME)
	mcopy -i $(BINDIR)/$(FLOPPY_NAME) $(BINDIR)/kmain.bin ::/

	# cp $(BINDIR)/kmain.bin $(BINDIR)/$(FLOPPY_NAME)
	# truncate -s 1440k $(BINDIR)/$(FLOPPY_NAME)

# ---- make bootloader ---- #
makeboot: $(BINDIR)/boot.bin

$(BINDIR)/boot.bin: always
	@echo "[ #2 ] compiling bootloader"
	$(ASM) -f bin $(BOOTDIR)/boot.asm -o $(BINDIR)/boot.bin

# ---- make kernel ---- #
makekern: $(BINDIR)/kmain.bin

$(BINDIR)/kmain.bin: always
	@echo "[ #3 ] compiling kernel"
	$(ASM) -f bin $(KERNDIR)/kmain.asm -o $(BINDIR)/kmain.bin


## always
always:
	@mkdir -p $(BINDIR)

## clean
clean:
	@echo "[ #0 ] cleaning"
	@rm -rf $(BINDIR)
	@rm -f $(FLOPPY_NAME)