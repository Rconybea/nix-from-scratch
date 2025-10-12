#!/bin/bash

set -e

echo
echo "gcc=${gcc}";
echo "gcc_specs=${gcc_specs}";
echo "mkdir=${mkdir}";
echo "bash=${bash}";
echo "toolchain=${toolchain}";
echo "coreutils=${coreutils}";
echo

export PATH=${toolchain}/bin:${coreutils}/bin

mkdir -p ${out}

#echo "hello roly" > ${out}/greetings.txt

${gcc} -v -specs ${gcc_specs}
${gcc} --version

${gcc} -specs ${gcc_specs} -o ${out}/hello -Wl,--enable-new-dtags -Wl,--rpath=${toolchain}/lib -Wl,--dynamic-linker=${toolchain}/lib/ld-linux-x86-64.so.2 -Wl,--verbose ${src}

# can we run it?
${out}/hello > ${out}/greetings.txt
