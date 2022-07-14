MAKEFILE_DIR=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
CLANG=clang
CFLAGS=-g3 -O2 -Wall -Wextra
ARCH := $(shell uname -m | sed 's/x86_64/x86/' | sed 's/aarch64/arm64/' | sed 's/ppc64le/powerpc/' | sed 's/mips.*/mips/')
CLANG_BPF_SYS_INCLUDES = $(shell $(CLANG) -v -E - </dev/null 2>&1 \
	| sed -n '/<...> search starts here:/,/End of search list./{ s| \(/.*\)|-idirafter \1|p }')

all: build
.PHONY: all

deps: apt-packages libbpf bpftool
.PHONY: deps

apt-packages:
	sudo apt-get -q update && sudo apt-get install --no-install-recommends -q -y \
		libelf-dev \
		llvm \
		clang
.PHONY: install-deps

# If there's libbpf-dev in the apt repository, use it. Otherwise, you can build your own.
libbpf:
	if [ ! -e deps/libbpf ] ; then git clone --recursive --depth 1 https://github.com/libbpf/libbpf ./deps/libbpf ; fi
	$(MAKE) -j -C deps/libbpf/src/ BUILD_STATIC_ONLY=1 DESTDIR="$(MAKEFILE_DIR)/build" INCLUDEDIR= LIBDIR= UAPIDIR= install
.PHONY: libbpf

bpftool:
	if [ ! -e deps/bpftool ] ; then git clone --branch v6.8.0 --recursive --depth 1 https://github.com/libbpf/bpftool ./deps/bpftool ; fi
	$(MAKE) -j -C deps/bpftool/src/
.PHONY: bpftool

build/vmlinux.h:
	mkdir -p build/
	deps/bpftool/src/bpftool btf dump file /sys/kernel/btf/vmlinux format c > $@

build: build/tracepoint build/usdt
.PHONY: build

build/tracepoint: build/vmlinux.h tracepoint.c tracepoint.bpf.c
	uname -a
	$(CLANG) $(CFLAGS) -target bpf -D__TARGET_ARCH_$(ARCH) $(CLANG_BPF_SYS_INCLUDES) -I build -c tracepoint.bpf.c -o build/tracepoint.bpf.o
	deps/bpftool/src/bpftool gen skeleton --debug build/tracepoint.bpf.o > build/tracepoint.skel.h
	$(CLANG) $(CFLAGS) -I build -c tracepoint.c -o build/tracepoint.o
	$(CLANG) $(CFLAGS) build/tracepoint.o -L build -lbpf -lelf -lz -o build/tracepoint

build/myusdt: build/vmlinux.h myusdt.c myusdt.bpf.c
	uname -a
	$(CLANG) $(CFLAGS) -target bpf -D__TARGET_ARCH_$(ARCH) $(CLANG_BPF_SYS_INCLUDES) -I build -c myusdt.bpf.c -o build/myusdt.bpf.o
	deps/bpftool/src/bpftool gen skeleton --debug build/myusdt.bpf.o > build/myusdt.skel.h
	$(CLANG) $(CFLAGS) -Wextra -I build -c myusdt.c -o build/myusdt.o
	$(CLANG) $(CFLAGS) build/myusdt.o -L build -lbpf -lelf -lz -o build/myusdt


test:
	sudo ./build/tracepoint -t

clean:
	rm -rf build deps

.PHONY: clean
