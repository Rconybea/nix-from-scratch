#!/bin/bash

set -e
set -x

echo "mpfr=${mpfr}"
echo "gmp=${gmp}"
echo "m4=${m4}"
echo "file=${file}"
echo "coreutils=${coreutils}"
echo "bash=${bash}"
echo "tar=${tar}"
echo "gnumake=${gnumake}"
echo "gawk=${gawk}"
echo "grep=${grep}"
echo "sed=${sed}"
echo "findutils=${findutils}"
echo "diffutils=${diffutils}"
echo "gcc_wrapper=${gcc_wrapper}"

echo "toolchain=${toolchain}"
echo "sysroot=${sysroot}"
echo "src=${src}"

echo "target_tuple=${target_tuple}"
echo "TMPDIR=${TMPDIR}"

# 1. ${gcc_wrapper}/bin/x86_64-pc-linux-gnu-{gcc,g++} builds viable executables.
# 2. ${toolchain}/bin/x86_64-pc-linux-gnu-gcc can build executables,
#    but they won't run unless we pass special linker flags
# 3. ${toolchain}/bin                     has x86_64-pc-linux-gnu-ar
# 4. ${toolchain}/x86_64-pc-linux-gnu/bin has ar  <- autotools looks for this
#
export PATH="${gcc_wrapper}/bin:${toolchain}/bin:${toolchain}/x86_64-pc-linux-gnu/bin:${m4}/bin:${file}/bin:${gnumake}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${tar}/bin:${coreutils}/bin:${findutils}/bin:${diffutils}/bin:${bash}/bin"

ls -l ${toolchain}/x86_64-pc-linux-gnu/bin

src2=${TMPDIR}/src2
builddir=${TMPDIR}/build

mkdir -p ${src2}
mkdir -p ${builddir}

mkdir ${out}

bash_program=${bash}/bin/bash

# 1. copy source tree to temporary directory,
#
(cd ${src} && (tar cf - . | tar xf - -C ${src2}))

# 2. substitute nix-store path-to-bash for /bin/sh.
#
#
#chmod -R +w ${src2}
#sed -i "1s:#!.*/bin/sh:#!${bash_program}:" ${src2}/mpn/m4-ccas
#chmod -R -w ${src2}

# ${src}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"

# 1.
# we shouldn't need special compiler/linker instructions,
# since stage-1 toolchain "knows where it lives"
#
# 2.
# do need to give --host and --build arguments to configure,
# since we're invoking a cross compiler.
#
# 3.
# nxfs-gcc inserts sysroot runpath and ELF interpreter

(cd ${builddir} && ${bash_program} ${src2}/configure --prefix=${out} --host=${target_tuple} --build=${target_tuple} --with-mpfr=${mpfr} --with-gmp=${gmp} CC=nxfs-gcc CFLAGS="-I${sysroot}/usr/include" LDFLAGS="-Wl,-enable-new-dtags")

(cd ${builddir} && make SHELL=${CONFIG_SHELL})

(cd ${builddir} && make install SHELL=${CONFIG_SHELL})
