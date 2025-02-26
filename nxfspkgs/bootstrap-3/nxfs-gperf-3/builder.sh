#!/bin/bash

set -e
set -x

echo "gcc_wrapper=${gcc_wrapper}"
echo "toolchain=${toolchain}"
echo "gnumake=${gnumake}"
echo "gawk=${gawk}"
echo "grep=${grep}"
echo "sed=${sed}"
echo "tar=${tar}"
echo "texinfo=${texinfo}"
echo "m4=${m4}"
echo "diffutils=${diffutils}"
echo "findutils=${findutils}"
echo "coreutils=${coreutils}"
echo "sysroot=${sysroot}"
#echo "mkdir=${mkdir}"
#echo "head=${head}"
echo "bash=${bash}"
echo "src=${src}"
echo "target_tuple=${target_tuple}"
echo "TMPDIR=${TMPDIR}"

export PATH="${gcc_wrapper}/bin:${texinfo}/bin:${m4}/bin:${diffutils}/bin:${findutils}/bin:${gnumake}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${tar}/bin:${coreutils}/bin:${bash}/bin"

src2=${TMPDIR}/src2
builddir=${TMPDIR}/build

mkdir -p ${src2}
mkdir -p ${builddir}

mkdir ${out}

# this might get us past the build.
# Won't work for invoking `locate`, because location here will
# be readonly downstream
#
#mkdir -p ${out}/var/lib/locate

bash_program=${bash}/bin/bash

# 1. copy source tree to temporary directory,
#
(cd ${src} && (tar cf - . | tar xf - -C ${src2}))

# 2. substitute nix-store path-to-bash for /bin/sh.
#
#
#chmod -R +w ${src2}
#sed -i "1s:#!.*/bin/sh:#!${bash_program}:" ${src2}/build-aux/mkinstalldirs
#chmod -R -w ${src2}

# ----------------------------------------------------------------
# NOTE: omitting coreutils unicode patch
#       since we don't need it for bootstrap
# ----------------------------------------------------------------

# ${src}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"

# 1.
# we shouldn't need special compiler/linker instructions,
# since stage-1 toolchain "knows where it lives"
#
# 2.
# do need to give --host and --build arguments to configure,
# since we're using a cross compiler.

(cd ${builddir} && ${bash_program} ${src2}/configure --prefix=${out} --host=${target_tuple} --build=${target_tuple} CC=nxfs-gcc CC_FOR_BUILD=nxfs-gcc CFLAGS= LDFLAGS="-Wl,-enable-new-dtags")

(cd ${builddir} && make SHELL=${CONFIG_SHELL})

(cd ${builddir} && make install SHELL=${CONFIG_SHELL})
