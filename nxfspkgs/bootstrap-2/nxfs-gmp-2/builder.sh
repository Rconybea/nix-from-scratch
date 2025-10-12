#!/bin/bash

set -euo pipefail

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

export PATH="${gcc_wrapper}/bin:${toolchain}/bin:${m4}/bin:${file}/bin:${coreutils}/bin:${bash}/bin:${tar}/bin:${gnumake}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${findutils}/bin:${diffutils}/bin"

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
sed -i "1s:#!.*/bin/sh:#!${bash_program}:" ${src2}/mpn/m4-ccas
chmod -R -w ${src2}

# ${src}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"

(cd ${builddir} && ${bash_program} ${src2}/configure --prefix=${out} CC=nxfs-gcc LDFLAGS="-Wl,-enable-new-dtags")

(cd ${builddir} && make SHELL=${CONFIG_SHELL})

(cd ${builddir} && make install SHELL=${CONFIG_SHELL})
