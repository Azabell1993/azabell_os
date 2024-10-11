ARCH = armv7-a
MCPU = cortex-a8

CC = arm-none-eabi-gcc
AS = arm-none-eabi-as
LD = arm-none-eabi-ld
OC = arm-none-eabi-objcopy

LINKER_SCRIPT = ./azabellos.ld

ASM_SRCS = $(wildcard boot/*.S)
ARM_OBJS = $(patsubst boot/%.S, boot/%.o, $(ASM_SRCS))

azabellos = build/azabellos.axf
azabellos_bin = build/azabellos.bin

.PHONY: all clean run debug gdb

all: $(azabellos)

clean:
	@rm -fr build

run: $(azabellos)
	qemu-system-arm -M realview-pb-a8 -kernel $(azabellos)

debug: $(azabellos)
	qemu-system-arm -M realview-pb-a8 -kernel $(azabellos) -S -gdb tcp::1234,ipv4

gdb:
	arm-none-eabi-gdb

$(azabellos): $(ARM_OBJS) $(LINKER_SCRIPT)
	mkdir -p $(shell dirname $@)
	$(LD) -n -T $(LINKER_SCRIPT) -o $(azabellos) $(ARM_OBJS)
	$(OC) -O binary $(azabellos) $(azabellos_bin)

build/%.o: boot/%.S
	mkdir -p $(shell dirname $@)
	$(AS) -march=$(ARCH) -mcpu=$(MCPU) -g -o $@ $<