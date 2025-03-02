#!/bin/bash

set -e

echo
echo "gcc=${gcc}";
echo "mkdir=${mkdir}";
echo "bash=${bash}";
echo "toolchain=${toolchain}";
echo "coreutils=${coreutils}";
echo "sysroot=${sysroot}";
echo

export PATH=${toolchain}/bin:${coreutils}/bin

mkdir -p ${out}

#echo "hello roly" > ${out}/greetings.txt

${gcc} --version
${gcc} -o ${out}/hello -Wl,--enable-new-dtags -Wl,--rpath=${sysroot}/lib -Wl,--dynamic-linker=${sysroot}/lib/ld-linux-x86-64.so.2 ${src}

# can we run it?
${out}/hello > ${out}/greetings.txt
