#!/bin/bash

set -euo pipefail
set -x

echo "gcc_wrapper=${gcc_wrapper}"
echo "toolchain=${toolchain}"
echo "gnumake=${gnumake}"
echo "gawk=${gawk}"
echo "grep=${grep}"
echo "sed=${sed}"
echo "tar=${tar}"
echo "gzip=${gzip}"
echo "coreutils=${coreutils}"
echo "findutils=${findutils}"
echo "diffutils=${diffutils}"
echo "bash=${bash}"
echo "src=${src}"
echo "TMPDIR=${TMPDIR}"

export PATH="${gcc_wrapper}/bin:${toolchain}/bin:${gnumake}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${tar}/bin:${gzip}/bin:${coreutils}/bin:${findutils}/bin:${diffutils}/bin:${bash}/bin"

builddir=${TMPDIR}/build

mkdir -p ${builddir}

mkdir ${out}

bash_program=${bash}/bin/bash

# ${src}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"

(cd ${builddir} && ${bash_program} ${src}/configure --prefix=${out} --with-shared --without-normal --without-debug --with-cxx-shared --enable-pc-files CC="nxfs-gcc" CXX="nxfs-gxx" CFLAGS="-I${toolchain}/include" LDFLAGS="-Wl,-enable-new-dtags -Wl,-rpath,${out}/lib")

(cd ${builddir} && make SHELL=${CONFIG_SHELL})

(cd ${builddir} && make TIC_PATH=./progrs/tic install SHELL=${CONFIG_SHELL})
sed -e 's/^#if.*XOPEN.*$/#if 1/' -i  ${out}/include/ncursesw/curses.h

(cd ${out}/lib && ln -sv libncursesw.so libncurses.so)
(cd ${out}/lib && ln -sfv libncurses.so libcurses.so)
(cd ${out}/lib && ln -sv libncurses.so libtinfo.so)
