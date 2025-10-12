#!/bin/sh

echo "out=${out}"

export PATH=${coreutils}/bin:${toolchain}/bin

${toolchain}/bin/ld.so --library-path ${toolchain}/lib ${coreutils}/bin/mkdir ${out}

# verify that we can invoke toolchain members

${toolchain}/bin/ld.so --library-path ${toolchain}/lib ${toolchain}/bin/cpp --version > ${out}/cpp-version.txt
${toolchain}/bin/ld.so --library-path ${toolchain}/lib ${toolchain}/bin/gcc --version > ${out}/gcc-version.txt
${toolchain}/bin/ld.so --library-path ${toolchain}/lib ${toolchain}/bin/g++ --version > ${out}/g++-version.txt
