#!/bin/bash

set -euo pipefail

echo "toolchain=${toolchain}"
echo "flex=${flex}"
echo "gnumake=${gnumake}"
echo "gawk=${gawk}"
echo "grep=${grep}"
echo "sed=${sed}"
echo "tar=${tar}"
echo "m4=${m4}"
echo "diffutils=${diffutils}"
echo "findutils=${findutils}"
echo "coreutils=${coreutils}"
echo "bash=${bash}"
echo "src=${src}"
echo "gcc_wrapper=${gcc_wrapper}"
echo "TMPDIR=${TMPDIR}"

set -x

export PATH="${gcc_wrapper}/bin:${toolchain}/bin:${flex}/bin:${m4}/bin:${coreutils}/bin:${bash}/bin:${tar}/bin:${gnumake}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${diffutils}/bin:${findutils}/bin"

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
chmod -R +w ${src2}
sed -i "1s:#!.*/bin/sh:#!${bash_program}:" ${src2}/build-aux/move-if-change
chmod -R -w ${src2}

# ${src}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"

(cd ${builddir} && ${bash_program} ${src2}/configure --prefix=${out} CC=nxfs-gcc CC_FOR_BUILD=nxfs-gcc LDFLAGS="-Wl,-enable-new-dtags")

(cd ${builddir} && make SHELL=${CONFIG_SHELL})

(cd ${builddir} && make install SHELL=${CONFIG_SHELL})

# verify an executable runs
${out}/bin/bison --version
