#!/bin/bash

set -e

echo "gcc_wrapaper=${gcc_wrapper}"
echo "binutils=${binutils}"
echo "glibc=${glibc}"
echo "gnumake=${gnumake}"
echo "gawk=${gawk}"
echo "grep=${grep}"
echo "sed=${sed}"
echo "tar=${tar}"
echo "coreutils=${coreutils}"
echo "findutils=${findutils}"
echo "diffutils=${diffutils}"
echo "bash=${bash}"
echo "src=${src}"
echo "target_tuple=${target_tuple}"
echo "TMPDIR=${TMPDIR}"

# 1. ${gcc_wrapper}/bin/x86_64-pc-linux-gnu-{gcc,g++} builds viable executables.
# 2. ${toolchain}/bin/x86_64-pc-linux-gnu-gcc can build executables,
#    but they won't run unless we pass special linker flags
# 3. ${toolchain}/bin                     has x86_64-pc-linux-gnu-ar
# 4. ${toolchain}/x86_64-pc-linux-gnu/bin has ar  <- autotools looks for this
#
export PATH="${gcc_wrapper}/bin:${binutils}/bin:${glibc}/bin:${gnumake}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${tar}/bin:${coreutils}/bin:${diffutils}/bin:${findutils}/bin:${bash}/bin"

builddir=${TMPDIR}

mkdir ${out}

# 1. copy source tree to temporary directory,
#
#(cd ${src} && (tar cf - . | tar xf - -C ${tmpsrcdir}))

# 2. substitute nix-store path-to-bash for /bin/sh throughout
#

bash_program=${bash}/bin/bash

# ${src}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"
:
# 1.
# we shouldn't need special compiler/linker instructions,
# since stage-1 toolchain "knows where it lives"
#
# 2.
# do need to give --host and --build arguments to configure,
# since we're using a cross compiler.

# inspect shebang
head -5 ${src}/configure

(cd ${builddir} && ${bash_program} ${src}/configure --prefix=${out} --host=${target_tuple} --build=${target_tuple} CFLAGS= LDFLAGS="-Wl,-enable-new-dtags")

(cd ${builddir} && make SHELL=${CONFIG_SHELL})
(cd ${builddir} && make install SHELL=${CONFIG_SHELL})
