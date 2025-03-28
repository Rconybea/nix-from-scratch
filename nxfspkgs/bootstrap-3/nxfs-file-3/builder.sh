#!/bin/bash

echo "coreutils=${coreutils}"
echo "tar=${tar}"
echo "bash=${bash}"
echo "gnumake=${gnumake}"
echo "gawk=${gawk}"
echo "grep=${grep}"
echo "sed=${sed}"
echo "findutils=${findutils}"
echo "diffutils=${diffutils}"

echo "gcc_wrapper=${gcc_wrapper}"
echo "binutils=${binutils}"

echo "src=${src}"
echo "target_tuple=${target_tuple}"
echo "TMPDIR=${TMPDIR}"

set -e
set -x

export PATH="${gcc_wrapper}/bin:${binutils}/bin:${gnumake}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${tar}/bin:${coreutils}/bin:${findutils}/bin:${diffutils}/bin:${bash}/bin"

src2=${src}
#src2=${TMPDIR}/src2
builddir=${TMPDIR}/build

mkdir -p ${src2}
mkdir -p ${builddir}

mkdir ${out}

bash_program=${bash}/bin/bash

# 1. copy source tree to temporary directory,
#
#(cd ${src} && (tar cf - . | tar xf - -C ${src2}))

# 2. substitute nix-store path-to-bash for /bin/sh.
#
#
#chmod -R +w ${src2}
#(cd ${src2} && ${bash_program} ${m4_patch})
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

(cd ${builddir} && bash ${src2}/configure --prefix=${out} --host=${target_tuple} --build=${target_tuple} --enable-install-program=hostname --enable-no-install-program=kill,uptime CFLAGS= LDFLAGS="-Wl,-enable-new-dtags")

(cd ${builddir} && make SHELL=${CONFIG_SHELL})

(cd ${builddir} && make install SHELL=${CONFIG_SHELL})
