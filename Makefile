CC = nasm
QEMU = qemu-system-x86_64

all: ringanos.img

boot.bin: boot.asm
	$(CC) -f bin boot.asm -o boot.bin

kernel.bin: kernel.asm gui.asm apps.asm
	$(CC) -f bin kernel.asm -o kernel.bin

ringanos.img: boot.bin kernel.bin
	cat boot.bin kernel.bin > ringanos.img
	@echo "==============================================="
	@echo " RinganOS berhasil dikompilasi!"
	@ls -lh ringanos.img
	@echo " Ukuran total image: $$(stat -c %s ringanos.img) bytes"
	@echo "==============================================="

run: ringanos.img
	$(QEMU) -drive format=raw,file=ringanos.img

clean:
	rm -f boot.bin kernel.bin ringanos.img screenshot.ppm screenshot.png
