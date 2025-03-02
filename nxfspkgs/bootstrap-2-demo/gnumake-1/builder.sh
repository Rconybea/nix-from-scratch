#! /bin/bash

echo "mymakefile=${mymakefile}"

set -e
set -x

export PATH="${gcc_wrapper}/bin:${toolchain}/bin:${toolchain}/x86_64-pc-linux-gnu/bin:${sysroot}/usr/bin:${sysroot}/sbin:${gnumake}/bin:${coreutils}/bin:${bash}/bin"

builddir=${TMPDIR}

mkdir -p ${out}

cd ${builddir}

make -f ${mymakefile} > ${out}/make.out

echo "done" > ${out}/done
