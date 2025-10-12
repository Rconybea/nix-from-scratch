#!/bin/bash

set -euo pipefail

echo "toolchain=${toolchain}"
echo "m4=${m4}"
echo "coreutils=${coreutils}"
echo "bash=${bash}"
echo "tar=${tar}"
echo "gnumake=${gnumake}"
echo "gawk=${gawk}"
echo "grep=${grep}"
echo "sed=${sed}"
echo "diffutils=${diffutils}"
echo "findutils=${findutils}"
echo "gcc_wrapper=${gcc_wrapper}"
echo "src=${src}"
echo "TMPDIR=${TMPDIR}"

set -x

export PATH="${gcc_wrapper}/bin:${toolchain}/bin:${file}/bin:${m4}/bin:${diffutils}/bin:${findutils}/bin:${gnumake}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${tar}/bin:${coreutils}/bin:${findutils}/bin:${diffutils}/bin:${bash}/bin"

src2=${TMPDIR}/src2
builddir=${TMPDIR}/build

mkdir -p ${src2}
mkdir -p ${builddir}

mkdir ${out}

bash_program=${bash}/bin/bash

# 1. copy source tree to temporary directory,
#
(cd ${src} && (tar cf - . | tar xf - -C ${src2}))

# ${src}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"

(cd ${builddir} && ${bash_program} ${src}/configure --prefix=${out} CC=nxfs-gcc CC_FOR_BUILD=nxfs-gcc LDFLAGS="-Wl,-enable-new-dtags")

(cd ${builddir} && make SHELL=${CONFIG_SHELL})

(cd ${builddir} && make install SHELL=${CONFIG_SHELL})

# verify executable runs
${out}/bin/flex --version
