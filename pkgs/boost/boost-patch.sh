#!/usr/bin/env bash

# runs in *source* directory

patchfile=boost-1.86.0-upstream_fixes-1.patch

# patch from:
#   https://www.linuxfromscratch.org/patches/blfs/svn/${patchfile}

patch -Np1 -i ../${patchfile}
sed -e "s/defined(__MINGW32__)/& || defined(__i386__)/" -i ./libs/stacktrace/src/exception_headers.h

