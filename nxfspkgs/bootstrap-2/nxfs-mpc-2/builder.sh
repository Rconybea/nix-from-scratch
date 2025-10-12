#!/bin/bash

set -euo pipefail

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
echo "src=${src}"

echo "TMPDIR=${TMPDIR}"

set -x

export PATH="${gcc_wrapper}/bin:${toolchain}/bin:${m4}/bin:${file}/bin:${gnumake}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${tar}/bin:${coreutils}/bin:${findutils}/bin:${diffutils}/bin:${bash}/bin"

builddir=${TMPDIR}/build

mkdir -p ${builddir}

mkdir ${out}

bash_program=${bash}/bin/bash

# ${src}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"

(cd ${builddir} && ${bash_program} ${src}/configure --prefix=${out} --with-mpfr=${mpfr} --with-gmp=${gmp} CC=nxfs-gcc LDFLAGS="-Wl,-enable-new-dtags")

(cd ${builddir} && make SHELL=${CONFIG_SHELL})

(cd ${builddir} && make install SHELL=${CONFIG_SHELL})
