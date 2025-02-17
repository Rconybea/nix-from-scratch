#!/bin/bash

set -e

echo
#echo "gcc=${gcc}";
echo "toolchain=${toolchain}";
echo "coreutils=${coreutils}";
echo "input=${input}";
#echo "sysroot=${sysroot}";
echo

export PATH=${toolchain}/bin:${coreutils}/bin:

mkdir -p ${out}

sort -u -t. -k 1,1 -k 2n,2n -k 3 ${input} > ${out}/output.txt

cp ${input} ${out}/input.txt
