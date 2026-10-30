# XMOS module wrapper for the upstream SCPI parser library.
#
# Upstream: https://github.com/j123b567/scpi-parser  (BSD 2-Clause, Jan Breuer)
# This is the same library XMOS integrates in their own USBTMC application note
# (AN00135, Appendix D), so the integration shape is vendor-sanctioned.
#
# Upstream ships no XMOS build file. Rather than fork a copy of the sources
# into this repo's build (which would silently diverge from the pinned clone),
# the wrapper names the upstream files explicitly and lets the toolchain
# compile them from the checked-out repository. Upstream is taken unmodified;
# portability is handled by scpi_user_config.h, selected through the library's
# own SCPI_USER_CONFIG hook -- not by patching upstream sources.
set(LIB_NAME libscpi)
set(LIB_VERSION 1.3)

set(LIB_INCLUDES inc
                 inc/scpi)

# All nine upstream translation units compile clean under xcc 15.3.0 with no
# edits (verified). ieee488.c is included: it is small, and *STB/*ESR status
# registers are what makes a SCPI peer able to poll us.
set(LIB_C_SRCS src/lexer.c
               src/parser.c
               src/expression.c
               src/fifo.c
               src/error.c
               src/minimal.c
               src/units.c
               src/utils.c
               src/ieee488.c)

# lib_dfu/src/modules/fifo.c defines the same generic names (fifo_init,
# fifo_add, ...). Upstream marks these LOCAL, but cc.h leaves LOCAL undefined
# for xcc, so they link externally and the image fails with "Multiple
# definition of fifo_*". Rather than patch upstream sources, rename them at
# compile time for this module only -- both fifo.c and its one caller
# (error.c) are compiled with the same flags, so they agree with each other
# and stay private to libscpi.
set(CSD_SCPI_FIFO_RENAME
    -Dfifo_init=csd_scpi_fifo_init
    -Dfifo_clear=csd_scpi_fifo_clear
    -Dfifo_is_empty=csd_scpi_fifo_is_empty
    -Dfifo_is_full=csd_scpi_fifo_is_full
    -Dfifo_add=csd_scpi_fifo_add
    -Dfifo_remove=csd_scpi_fifo_remove
    -Dfifo_remove_last=csd_scpi_fifo_remove_last
    -Dfifo_count=csd_scpi_fifo_count)

set(LIB_COMPILER_FLAGS -O3
                       -Wall
                       -DSCPI_USER_CONFIG=1
                       ${CSD_SCPI_FIFO_RENAME})

set(LIB_DEPENDENT_MODULES "")

# Mandatory: hands the module to the XMOS cmake glue. Without this the
# dependency is only recorded in the manifest -- no include dirs, no sources
# (verified the hard way: the app compiled without scpi/scpi.h on the include
# path). Every XMOS module's lib_build_info.cmake ends this way.
XMOS_REGISTER_MODULE()
