/* Bare-metal configuration for libscpi (selected via -DSCPI_USER_CONFIG=1).
 *
 * xcc defines neither __unix__ nor _WIN32, so upstream already infers
 * SYSTEM_BARE_METAL; this file makes the choice explicit and pins the parts
 * that would otherwise silently pull in heap or stdio formatting we cannot
 * rely on here. Upstream sources are NOT patched -- this is the library's own
 * documented hook. */
#ifndef __csd_scpi_user_config_h__
#define __csd_scpi_user_config_h__

/* No malloc()/free() on this core, and none wanted: the error queue and its
 * device-dependent strings come from a static buffer we own. */
#define USE_MEMORY_ALLOCATION_FREE              0
#define USE_DEVICE_DEPENDENT_ERROR_INFORMATION  0
/* Off on purpose: the device-dependent path routes SCPI_ErrorPushEx through
 * its side "heap" (scpiheap_*), and the xcore link-time stack analyser refuses
 * to bound that path -- "Meta information
 * (\"SCPI_ErrorPushEx.nstackwords\") ... cannot be determined". Dropping the
 * feature beats fighting the analyser: errors still reach the host with their
 * SCPI code and standard text, which is what a bench console needs. The
 * free-form per-error reason is dropped; the host tells failures apart by
 * error CODE plus the command it sent, which is enough to act on. */
#define USE_FULL_ERROR_LIST               0    /* minimal error table: it is
                                                * the one that costs flash */

/* IEEE 488.2 optional registers (*ESR?/*STB?) stay compiled in: they are what
 * lets a generic SCPI peer poll us instead of guessing. */
#define USE_COMMAND_TAGS                  1

/* NOTE on what is NOT set here, because upstream has no such knob: there is
 * no USE_FLOATS, no CHECK_PATTERN_ERRORS and no MAX_LISTS in this library
 * version (verified against libscpi/inc/scpi/config.h). Floating point is
 * avoided the honest way -- we never ask the parser for a float, every result
 * we emit is built with our own integer formatter and SCPI_ResultCharacters(),
 * so the soft-float routines stay unreferenced and the linker drops them.
 * Command patterns are additionally checked host-side by
 * tools/dsp/test_gates.sh (T8), which stands in for the pattern self-check
 * upstream does not provide. */

#endif
