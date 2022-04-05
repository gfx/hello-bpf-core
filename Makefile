

all: install-deps libbpf build
.PHONY: all

install-deps:
	sudo apt-get update && sudo apt-get install -y \
		libelf-dev \
		linux-tools-generic \
		clang
.PHONY: install-deps

# If there's libbpf-dev in the apt repository, use it. Otherwise, you can build your own.
libbpf:
	if [ ! -e build/libbpf ] ; then git clone https://github.com/libbpf/libbpf ./build/libbpf ; fi
	cd build/libbpf/src/ && \
		$(MAKE) BUILD_STATIC_ONLY=1 OBJDIR=../../libbpf DESTDIR=../.. INCLUDEDIR= LIBDIR= UAPIDIR= install

.PHONY: libbpf

build:
	uname -a
	mkdir -p $@
	bpftool btf dump file /sys/kernel/btf/vmlinux format c > $@/vmlinux.h
	clang -g -O2 -Wall -Wextra -target bpf -D__TARGET_ARCH_x86_64 -I $@ -c hello.bpf.c -o $@/hello.bpf.o
	bpftool gen skeleton $@/hello.bpf.o > $@/hello.skel.h
	clang -g -O2 -Wall -Wextra -I $@ -c main.c -o build/main.o
	clang -g -O2 -Wall -Wextra $@/main.o -L$@ -lbpf -lelf -lz -o $@/hello

.PHONY: build

clean:
	rm -rf build

.PHONY: clean
