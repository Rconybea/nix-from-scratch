#!/bin/bash

set -euo pipefail
set -x

echo "gcc_wrapper=${gcc_wrapper}"
echo "toolchain=${toolchain}"
echo "gnumake=${gnumake}"
echo "gawk=${gawk}"
echo "grep=${grep}"
echo "sed=${sed}"
echo "tar=${tar}"
echo "diffutils=${diffutils}"
echo "findutils=${findutils}"
echo "coreutils=${coreutils}"
echo "bash=${bash}"
echo "src=${src}"
echo "TMPDIR=${TMPDIR}"

export PATH="${gcc_wrapper}/bin:${toolchain}/bin:${gnumake}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${tar}/bin:${coreutils}/bin:${findutils}/bin:${diffutils}/bin:${bash}/bin"

ls -l ${toolchain}/x86_64-pc-linux-gnu/bin

src2=${TMPDIR}/src2
builddir=${TMPDIR}/build

mkdir -p ${builddir}

mkdir ${out}

bash_program=${bash}/bin/bash

# ${src}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"

(cd ${builddir} && export CC=nxfs-gcc && export CFLAGS="-idirafter ${toolchain}/include" && export LDFLAGS="-Wl,-enable-new-dtags" && bash ${src}/configure --prefix=${out})

(cd ${builddir} && make SHELL=${CONFIG_SHELL})

(cd ${builddir} && make install SHELL=${CONFIG_SHELL})
