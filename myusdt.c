#include <sys/sdt.h>
#include <unistd.h>
#include <stdio.h>
#include "myusdt.skel.h"

static int debug_vprintf(enum libbpf_print_level _level, const char *format, va_list args)
{
	return vfprintf(stderr, format, args);
}

int main(void)
{
    libbpf_set_strict_mode(LIBBPF_STRICT_ALL); /* libbpf 1.0 default */
    libbpf_set_print(debug_vprintf);

    struct myusdt_bpf *myusdt = myusdt_bpf__open();
    if (!myusdt) {
        fprintf(stderr, "Failed to open myusdt_bpf: %s\n", strerror(errno));
        return 1;
    }

    int err = myusdt_bpf__load(myusdt);
    if (err) {
        fprintf(stderr, "Failed to load myusdt_bpf: %s\n", strerror(errno));
        goto Exit;
    }

    err = myusdt_bpf__attach(myusdt);
    if (err) {
        fprintf(stderr, "Failed to attach myusdt_bpf: %s\n", strerror(errno));
        goto Exit;
    }

Exit:
    myusdt_bpf__destroy(myusdt);
    return err != 0;
}
