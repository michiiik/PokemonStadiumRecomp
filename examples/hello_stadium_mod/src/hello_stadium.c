#include "modding.h"

RECOMP_IMPORT("*", int recomp_printf(const char* format, ...));

// Util_InitMainPools runs once during normal boot. An entry hook observes that
// event without replacing the function, changing arguments, or touching game
// state, which makes this a safe loader smoke test.
RECOMP_HOOK("Util_InitMainPools") void hello_stadium_on_main_pools_init(void) {
    recomp_printf("[hello_stadium] Pokemon Stadium mod hook loaded successfully.\n");
}
