#include <sys/types.h>
#include <sys/stat.h>
#include <sys/resource.h>
#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>

#include <bpf/libbpf.h>
#include <bpf/bpf.h>

#include "hello.skel.h"

void read_trace_pipe(void)
{
	int trace_fd = open("/sys/kernel/debug/tracing/trace_pipe", O_RDONLY, 0);
	if (trace_fd < 0)
		return;

	while (1) {
		static char buf[4096];
		ssize_t sz;

		sz = read(trace_fd, buf, sizeof(buf) - 1);
		if (sz > 0) {
			printf("%.*s", (int)sz, buf);
		}
	}
}

int main(void)
{
	int err;

	struct rlimit rlim = {
		.rlim_cur = 512UL << 20,
		.rlim_max = 512UL << 20,
	};
	err = setrlimit(RLIMIT_MEMLOCK, &rlim);
	if (err) {
		fprintf(stderr, "failed to change rlimit\n");
		return 1;
	}

	struct hello_bpf *obj = hello_bpf__open();
	if (!obj) {
		fprintf(stderr, "failed to open and/or load BPF object\n");
		return 1;
	}
	fprintf(stderr, "BPF object opened\n");

	err = hello_bpf__load(obj);
	if (err) {
		fprintf(stderr, "failed to load BPF object %d\n", err);
		goto cleanup;
	}
	fprintf(stderr, "BPF object loaded\n");

	err = hello_bpf__attach(obj);
	if (err) {
		fprintf(stderr, "failed to attach BPF programs\n");
		goto cleanup;
	}
	fprintf(stderr, "BPF programs attached\n");

	read_trace_pipe();

cleanup:
	hello_bpf__destroy(obj);
	return err != 0;
}
