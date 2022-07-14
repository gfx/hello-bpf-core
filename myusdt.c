#define _SDT_HAS_SEMAPHORES 1

#include <sys/sdt.h>
#include <unistd.h>
#include <stdio.h>
#include "myusdt.skel.h"


int main(int argc, char **argv) {
	libbpf_set_strict_mode(LIBBPF_STRICT_ALL);

	while (a) {
		if (usdt_probe_main0_semaphore) {
			printf("PROBE0 ENABLED\n");
			STAP_PROBE(usdt, probe_main0);
		}
		if (usdt_probe_main1_semaphore) {
			printf("PROBE1 ENABLED %x\n", a);
			STAP_PROBE1(usdt, probe_main1, a);
		}
		if (usdt_probe_main2_semaphore) {
			printf("PROBE2 ENABLED %x %x\n", 0x47, argc);
			STAP_PROBE2(usdt, probe_main2, 0x47, argc);
		}
		if (usdt_probe_main3_semaphore) {
			printf("PROBE3 ENABLED %x %x %p\n", bla, argc, argv);
			STAP_PROBE3(usdt, probe_main3, bla, argc, argv);
		}
		if (usdt_probe_main4_semaphore) {
			printf("PROBE4 ENABLED %x %x %p %p %p\n", (short)a, a, &a, &bla, &ext);
			STAP_PROBE5(usdt, probe_main4, (short)a, a, &a, &bla, &ext);
		}
		if (usdt_probe_main5_semaphore) {
			printf("PROBE5 ENABLED\n");
			STAP_PROBE12(usdt, probe_main5,
				     nums[2], &nums[3], nums[idx], &nums[idx],
				     t1.y, &t1.y,
				     ts[1].y, ts[2].x, &ts[1].y, &ts[2].y,
				     t2.y, &t2.x);
		}
		printf("%d %x %d %x\n", (int)(short)a, (int)(short)a, a, a);
		do_something(cnt++);
		sleep(1);
	}
	return 0;
}
