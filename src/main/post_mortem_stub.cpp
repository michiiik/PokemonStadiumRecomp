/* Host-port stub for the Windows-only post-mortem stack walker. */

#include <cstdint>

extern "C" void psr_post_mortem_dump(const char*, void*) {}

extern "C" int psr_dump_current_dl(const char*, uint32_t* out_addr,
                                    uint32_t* out_size) {
    if (out_addr != nullptr) *out_addr = 0;
    if (out_size != nullptr) *out_size = 0;
    return -2;
}
