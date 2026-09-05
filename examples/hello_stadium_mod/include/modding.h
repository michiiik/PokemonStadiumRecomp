#ifndef POKESTADIUM_RECOMP_MODDING_H
#define POKESTADIUM_RECOMP_MODDING_H

#ifdef __cplusplus
#define RECOMP_EXTERN_C extern "C"
#else
#define RECOMP_EXTERN_C
#endif

#define RECOMP_IMPORT(mod, func) \
    _Pragma("GCC diagnostic push") \
    _Pragma("GCC diagnostic ignored \"-Wunused-parameter\"") \
    _Pragma("GCC diagnostic ignored \"-Wreturn-type\"") \
    RECOMP_EXTERN_C __attribute__((noinline, weak, used, section(".recomp_import." mod))) func {} \
    _Pragma("GCC diagnostic pop")

#define RECOMP_PATCH \
    RECOMP_EXTERN_C __attribute__((retain, section(".recomp_patch")))
#define RECOMP_HOOK(function_name) \
    __attribute__((retain, section(".recomp_hook." function_name)))
#define RECOMP_HOOK_RETURN(function_name) \
    __attribute__((retain, section(".recomp_hook_return." function_name)))

#endif
