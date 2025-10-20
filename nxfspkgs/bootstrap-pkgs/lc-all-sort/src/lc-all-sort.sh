#! @shell@
#
# Script to invoke sort in environment
# with LC_ALL=C.
#
# Intending to use to help bootstrap glibc.

sort_program=@sort_program@

LC_ALL=C $sort_program "${@}"
