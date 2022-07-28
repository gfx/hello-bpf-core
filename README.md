# Hello, BPF CO-RE!

## Trouble Shooting

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

* https://www.sartura.hr/blog/simple-ebpf-core-application/
  * repo: https://github.com/sartura/ebpf-hello-world
* [BPF Documentation - kernel.org](https://www.kernel.org/doc/html/latest/bpf/)
* [BPF CO-RE Reference Guide - nakryiko.com](https://nakryiko.com/posts/bpf-core-reference-guide/)
