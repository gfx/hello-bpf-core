# Hello, BPF CO-RE!

## Trouble Shooting

### `bpftool gen skelton` fails without meaningful messages

When `bpftool gen skelton` fails with the followiing error:

```
libbpf: Error finalizing .BTF: -2.
rror: failed to open BPF object file: No such file or directory
```

It is probably an error that a particular data section is missing in the BPF object file, rather than missing the file itself. See `btf_fixup_datasec()` in [libbpf.c](https://github.com/libbpf/libbpf/blob/master/src/libbpf.c) for more information. Or, `bpftool gen skelton --debug` could reveal what is happing.
### `clang` cannot compile BPF source files

If you cannot build a BPF source file with the following messages:

```
build/vmlinux.h:4629:20: error: expected member name or ';' after declaration specifiers
        struct cgroup_bpf bpf;
                          ^
<built-in>:284:13: note: expanded from here
#define bpf 1
```

Then, your `clang` could be too old. I've confirmed clang-8 cannot build BPF source files but clang-10 can do.

## References

* [Add USDT example libbpf/libbpf-bootstrap#80](https://github.com/libbpf/libbpf-bootstrap/pull/80)
  * https://github.com/libbpf/libbpf-bootstrap/blob/master/examples/c/usdt.c
  * https://github.com/libbpf/libbpf-bootstrap/blob/master/examples/c/usdt.bpf.c
* Simple eBPF CO-RE application https://www.sartura.hr/blog/simple-ebpf-core-application/
  * repo: https://github.com/sartura/ebpf-hello-world
* [BPF Documentation - kernel.org](https://www.kernel.org/doc/html/latest/bpf/)
* [BPF CO-RE Reference Guide - nakryiko.com](https://nakryiko.com/posts/bpf-core-reference-guide/)
