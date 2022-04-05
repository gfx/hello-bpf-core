

all: install-deps build

install-deps:
	sudo apt-get install -y linux-tools-generic libbpf-dev clang

build:
	uname -a
	mkdir -p $@
	bpftool btf dump file /sys/kernel/btf/vmlinux format c > $@/vmlinux.h
	clang -g -O2 -Wall -Wextra -target bpf -D__TARGET_ARCH_x86_64 -I $@ -c hello.bpf.c -o $@/hello.bpf.o
	bpftool gen skeleton $@/hello.bpf.o > $@/hello.skel.h
	clang -g -O2 -Wall -Wextra -I $@ -c main.c -o build/main.o
	clang -g -O2 -Wall -Wextra $@/main.o -lbpf -lelf -lz -o $@/hello

.PHONY: build
