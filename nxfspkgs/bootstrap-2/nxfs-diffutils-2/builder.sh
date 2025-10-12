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
echo "coreutils=${coreutils}"
echo "diffutils=${diffutils}"
echo "bash=${bash}"
echo "src=${src}"
echo "TMPDIR=${TMPDIR}"

export PATH="${gcc_wrapper}/bin:${toolchain}/bin:${gnumake}/bin:${diffutils}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${tar}/bin:${coreutils}/bin:${bash}/bin"

ls -l ${toolchain}/x86_64-pc-linux-gnu/bin

src2=${TMPDIR}/src2
builddir=${TMPDIR}/build

mkdir -p ${src2}
mkdir -p ${builddir}

mkdir ${out}

# this might get us past the build.
# Won't work for invoking `locate`, because location here will
# be readonly downstream
#
mkdir -p ${out}/var/lib/locate

bash_program=${bash}/bin/bash

# 1. copy source tree to temporary directory,
#
(cd ${src} && (tar cf - . | tar xf - -C ${src2}))

# ${src}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"

(cd ${builddir} && ${bash_program} ${src2}/configure --prefix=${out} CC=nxfs-gcc CPP=${toolchain}/bin/cpp CPPFLAGS="-I${toolchain}/include" CFLAGS="-I${toolchain}/include" LDFLAGS="-Wl,-enable-new-dtags")

(cd ${builddir} && make SHELL=${CONFIG_SHELL})

(cd ${builddir} && make install SHELL=${CONFIG_SHELL})

# magic smoke test: check at least one binary runs
${out}/bin/cmp --version
