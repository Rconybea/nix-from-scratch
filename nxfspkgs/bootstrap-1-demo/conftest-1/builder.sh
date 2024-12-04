#!/bin/bash

set -e

echo
echo "toolchain=${toolchain}"
echo "coreutils=${coreutils}"
echo "bash=${bash}"
echo "TMPDIR=${TMPDIR}";

export PATH="${toolchain}/bin:${coreutils}/bin:${bash}/bin"

builddir=${TMPDIR}

mkdir -p ${out}/bin

gcc=x86_64-pc-linux-gnu-gcc

${gcc} -o ${out}/bin/${program} ${src}
