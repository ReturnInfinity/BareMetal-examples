include make/patterns.mk

NASM := nasm
NASMFLAGS := -f elf64 -g -F dwarf

CC := $(CROSS_COMPILE)gcc

CFLAGS := $(CFLAGS) -Wall -Wextra -Werror -Wfatal-errors -std=gnu99 -g
CFLAGS := $(CFLAGS) -fno-stack-protector -fomit-frame-pointer -mno-red-zone
CFLAGS := $(CFLAGS) -I ../../output/include

LD := $(CROSS_COMPILE)ld
LDFLAGS := -T coreutil.ld -L ../../output/lib
LDLIBS := -lc -lbmfs

apps += cat.app
apps += ethtoolc.app
apps += hello-c.app
apps += lspci.app
apps += sysinfo.app
apps += xxd.app

# Apps are built on request.
.PHONY: all
all:

cat.app: cat.o coreutil.ld

ethtoolc.app: ethtoolc.o coreutil.ld

hello.app: hello.o coreutil.ld

hello.o: hello.asm libBareMetal.asm

hello-c.app: hello-c.o coreutil.ld

lspci.app: lspci.o coreutil.ld

sysinfo.app: sysinfo.o coreutil.ld

sysinfo.o: sysinfo.asm libBareMetal.asm

xxd.app: xxd.o coreutil.ld

.PHONY: clean
clean:
	$(RM) $(apps) $(apps:.app=.o)

.PHONY: test
test:

.PHONY: install
install:

$(V).SILENT:
