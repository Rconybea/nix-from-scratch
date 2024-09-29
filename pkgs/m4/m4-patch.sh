#!/usr/bin/env bash

sed -i '/^#include <signal.h>/a #undef SIGSTKSZ' lib/c-stack.c
# bugfix from:
#   https://lists.nongnu.org/archive/html/bug-m4/2021-06/msg00009.html
#
# In my attempt to avoid test failures on Haiku, I caused test failures
# on platforms where sh is noisy when reporting a killed sub-process.
#
# * doc/m4.texi (Sysval): Avoid stderr noise during test.
# Fixes: 17011ea76a (tests: Skip signal detection on Haiku)
# Fixes: https://lists.gnu.org/archive/html/bug-m4/2021-05/msg00029.html
#
sed -i -e '/^syscmd(/ s:\[\(/bin/sh -c .kill -9 \$\$.\):\[@{ \1; @} 2>/dev/null:' doc/m4.texi
