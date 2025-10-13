#!/bin/bash

set -euo pipefail

#echo "automake=${automake}"
echo "autoconf=${autoconf}"
echo "m4=${m4}"
echo "perl=${perl}"
echo "file=${file}"
echo "coreutils=${coreutils}"
echo "bash=${bash}"
echo "gnumake=${gnumake}"
echo "gawk=${gawk}"
echo "grep=${grep}"
echo "sed=${sed}"
echo "tar=${tar}"
echo "gcc_wrapper=${gcc_wrapper}"
echo "src=${src}"
echo "toolchain=${toolchain}"
echo "TMPDIR=${TMPDIR}"

set -x
export PATH="${gcc_wrapper}/bin:${toolchain}/bin:${autoconf}/bin:${m4}/bin:${perl}/bin:${file}/bin:${gnumake}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${tar}/bin:${coreutils}/bin:${findutils}/bin:${diffutils}/bin:${bash}/bin"

src2=${TMPDIR}/src2
builddir=${TMPDIR}/build

mkdir -p ${builddir}

mkdir ${out}

bash_program=${bash}/bin/bash

# ${src}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"

(cd ${builddir} && bash ${src}/configure --prefix=${out} CC=nxfs-gcc LDFLAGS="-Wl,-enable-new-dtags")

(cd ${builddir} && make SHELL=${CONFIG_SHELL})

(cd ${builddir} && make install SHELL=${CONFIG_SHELL})

# verify an executable runs
${out}/bin/makeinfo --version
