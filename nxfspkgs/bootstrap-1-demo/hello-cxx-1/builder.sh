#!/bin/bash

set -euo pipefail

echo
echo "gcc_specs=${gcc_specs}"
echo "mkdir=${mkdir}";
echo "bash=${bash}";
echo "toolchain=${toolchain}";
echo "coreutils=${coreutils}";
echo

export PATH=${toolchain}/bin:${coreutils}/bin

set -x

mkdir -p ${out}

g++ -specs ${gcc_specs} -o ${out}/hello -Wl,--enable-new-dtags -Wl,--rpath=${toolchain}/lib -Wl,--dynamic-linker=${toolchain}/bin/ld.so -Wl,--verbose ${src}

# wrapper automatically supplies --specs, RUNPATH, dynamic linker
#
${toolchain_wrapper}/bin/g++ -o ${out}/hello2 ${src}

#nxfs-g++ -v -specs ${gcc_specs}
#nxfs-g++ --version
#nxfs-g++ -o ${out}/hello -Wl,--enable-new-dtags -Wl,--verbose ${src}

# can we run it?
${out}/hello > ${out}/greetings.txt

${out}/hello2 > ${out}/greetings2.txt
