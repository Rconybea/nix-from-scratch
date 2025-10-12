#!/bin/sh

echo "out=${out}"

export PATH=${coreutils}/bin:${toolchain}/bin

${toolchain}/bin/ld.so --library-path ${toolchain}/lib ${coreutils}/bin/mkdir ${out}

echo "hello" > ${out}/message.txt
