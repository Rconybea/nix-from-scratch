#!/bin/bash


echo "diffutils=${diffutils}"
echo "gcc_wrapper=${gcc_wrapper}"
echo "glibc=${glibc}"
echo "gnumake=${gnumake}"
echo "gawk=${gawk}"
echo "grep=${grep}"
echo "sed=${sed}"
echo "tar=${tar}"
echo "coreutils=${coreutils}"
echo "bash=${bash}"
echo "src=${src}"
echo "target_tuple=${target_tuple}"
echo "TMPDIR=${TMPDIR}"


set -e
set -x

# 1. ${gcc_wrapper}/bin/x86_64-pc-linux-gnu-{gcc,g++} builds viable executables.
# 2. ${toolchain}/bin/x86_64-pc-linux-gnu-gcc can build executables,
#    but they won't run unless we pass special linker flags
# 3. ${toolchain}/bin                     has x86_64-pc-linux-gnu-ar
# 4. ${toolchain}/x86_64-pc-linux-gnu/bin has ar  <- autotools looks for this
#
export PATH="${gcc_wrapper}/bin:${binutils}/bin:${gnumake}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${tar}/bin:${coreutils}/bin:${diffutils}/bin:${bash}/bin:${glibc}/bin"

src2=${TMPDIR}/src2
builddir=${TMPDIR}/build

mkdir -p ${src2}
mkdir -p ${builddir}

mkdir ${out}

# this might get us past the build.
# Won't work for invoking `locate`, because location here will
# be readonly downstream
#
mkdir -p ${out}/var/lib/locate

bash_program=${bash}/bin/bash

# 1. copy source tree to temporary directory,
#
(cd ${src} && (tar cf - . | tar xf - -C ${src2}))

# 2. substitute nix-store path-to-bash for /bin/sh.
#
#
chmod -R +w ${src2}
sed -i "1s:#!.*/bin/sh:#!${bash_program}:" ${src2}/build-aux/mkinstalldirs
chmod -R -w ${src2}


# ${src}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"

# 1.
# we shouldn't need special compiler/linker instructions,
# since stage-1 toolchain "knows where it lives"
#
# 2.
# do need to give --host and --build arguments to configure,
# since we're using a cross compiler.

(cd ${builddir} && ${bash_program} ${src2}/configure --prefix=${out} --host=${target_tuple} --build=${target_tuple} --localstatedir=${out}/var/lib/locate CFLAGS= LDFLAGS="-Wl,-enable-new-dtags")

(cd ${builddir} && make SHELL=${CONFIG_SHELL})

(cd ${builddir} && make install SHELL=${CONFIG_SHELL})
