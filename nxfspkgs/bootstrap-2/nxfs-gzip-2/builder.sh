#!/bin/bash

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
echo "sysroot=${sysroot}"
echo "bash=${bash}"
echo "src=${src}"
echo "target_tuple=${target_tuple}"
echo "TMPDIR=${TMPDIR}"

set -euo pipefail
set -x

export PATH="${gcc_wrapper}/bin:${toolchain}/bin:${gnumake}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${tar}/bin:${coreutils}/bin:${findutils}/bin:${diffutils}/bin:${bash}/bin"

ls -l ${toolchain}/x86_64-pc-linux-gnu/bin

builddir=${TMPDIR}/build

mkdir -p ${builddir}

mkdir ${out}

bash_program=${bash}/bin/bash

# ${src}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"

(cd ${builddir} && export CC=nxfs-gcc && export LDFLAGS="-Wl,-enable-new-dtags" && bash ${src}/configure --prefix=${out})

(cd ${builddir} && make SHELL=${CONFIG_SHELL})

(cd ${builddir} && make install SHELL=${CONFIG_SHELL})

# verify executable runs
${out}/bin/gzip --version
