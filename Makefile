MAKEFILE_DIR=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
CLANG=clang

all: deps build
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
	if [ ! -e deps/bpftool ] ; then git clone --branch v6.7.0 --recursive --depth 1 https://github.com/libbpf/bpftool ./deps/bpftool ; fi
	$(MAKE) -j -C deps/bpftool/src/
.PHONY: bpftool

build:
	uname -a
	mkdir -p $@
	deps/bpftool/src/bpftool btf dump file /sys/kernel/btf/vmlinux format c > $@/vmlinux.h
	$(CLANG) -g -O2 -Wall -Wextra -target bpf -D__TARGET_ARCH_x86_64 -I $@ -c tracepoint.bpf.c -o $@/tracepoint.bpf.o
	deps/bpftool/src/bpftool gen skeleton $@/tracepoint.bpf.o > $@/tracepoint.skel.h
	$(CLANG) -g -O2 -Wall -Wextra -I $@ -c tracepoint.c -o build/tracepoint.o
	$(CLANG) -g -O2 -Wall -Wextra $@/tracepoint.o -L$@ -lbpf -lelf -lz -o $@/tracepoint
.PHONY: build

test:
	sudo ./build/tracepoint -t

clean:
	rm -rf build deps

.PHONY: clean
