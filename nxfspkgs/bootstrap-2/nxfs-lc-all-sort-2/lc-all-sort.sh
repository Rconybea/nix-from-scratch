#! @bash@
#
# Script to invoke sort in environment
# with LC_ALL=C.
#
# Intending to use to help bootstrap glibc.

sort_program=@coreutils@/bin/sort

LC_ALL=C @sort_program@ "${@}"

