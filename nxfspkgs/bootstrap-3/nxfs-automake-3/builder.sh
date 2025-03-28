#!/bin/bash

echo "autoconf=${autoconf}"
echo "perl=${perl}"
echo "m4=${m4}"
echo "gcc_wrapper=${gcc_wrapper}"
echo "binutils=${binutils}"
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

set -e
set -x

export PATH="${autoconf}/bin:${perl}/bin:${m4}/bin:${gcc_wrapper}/bin:${binutils}/bin:${gnumake}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${tar}/bin:${coreutils}/bin:${findutils}/bin:${diffutils}/bin:${bash}/bin"

export PKG_CONFIG_PATH=${libxcrypt}/lib/pkgconfig
export LD_LIBRARY_PATH=${libxcrypt}/lib


src2=${TMPDIR}/src2
builddir=${TMPDIR}/build

mkdir -p ${src2}
mkdir -p ${builddir}

mkdir ${out}

# 1. copy source tree to temporary directory,
#
(cd ${src} && (tar cf - . | tar xf - -C ${src2}))

# 2. since we're building in source tree,
#    will need to be able to write there
#
chmod -R +w ${src2}

bash_program=${bash}/bin/bash
# Must skip:
#   .m4 and .in files (assume they trigger re-running autoconf)
#   test/ files
#
#sed -i -e "s:/bin/sh:${bash_program}:g" ${src2}/configure #${src2}/build-aux/*

# ${src}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"

# 1.
# we shouldn't need special compiler/linker instructions,
# since stage-1 toolchain "knows where it lives"
#
# 2.
# do need to give --host and --build arguments to configure,
# since we're using a cross compiler.

cd ${builddir}

CCFLAGS=
LDFLAGS="-Wl,-enable-new-dtags"

# -e: stop questions after config.sh
# -s: silent mode
#
# removing -Dcpp=nxfs-gcc (why did we need this)
#
(cd ${builddir} && ${bash_program} ${src2}/configure --prefix=${out} --host=${target_tuple} --build=${target_tuple} CC=nxfs-gcc CXX=nxfs-g++ LDFLAGS="${LDFLAGS}")

(cd ${builddir} && sed -i -e 's:#! */bin/sh:#! '${bash_program}':' ./pre-inst-env)

(cd ${builddir} && make SHELL=${CONFIG_SHELL})

(cd ${builddir} && make install SHELL=${CONFIG_SHELL})
