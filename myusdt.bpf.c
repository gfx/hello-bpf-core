#include "vmlinux.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>
#include <bpf/usdt.bpf.h>

SEC("usdt/libc.so.6:libc:setjmp")
int handle_libc_setjmp(struct pt_regs *ctx)
{
	pid_t pid = bpf_get_current_pid_tgid() >> 32;
	bpf_printk("USDT libc:setjmp is fired in pid=%d\n", (int)pid);
	return 0;
}

char LICENSE[] SEC("license") = "Dual MIT/GPL";
