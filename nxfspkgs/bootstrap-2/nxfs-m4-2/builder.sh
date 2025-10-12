#!/bin/bash

set -euo pipefail

echo "toolchain=${toolchain}"
echo "gnumake=${gnumake}"
echo "gawk=${gawk}"
echo "grep=${grep}"
echo "coreutils=${coreutils}"
echo "bash=${bash}"
echo "tar=${tar}"
echo "sed=${sed}"
echo "findutils=${findutils}"
echo "diffutils=${diffutils}"
echo "gcc_wrapper=${gcc_wrapper}"
echo "src=${src}"
echo "TMPDIR=${TMPDIR}"

set -x

export PATH="${gcc_wrapper}/bin:${toolchain}/bin:${gnumake}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${tar}/bin:${coreutils}/bin:${findutils}/bin:${diffutils}/bin:${bash}/bin"

src2=${TMPDIR}/src2
builddir=${TMPDIR}/build

mkdir -p ${src2}
mkdir -p ${builddir}

mkdir ${out}

bash_program=${bash}/bin/bash

# 1. copy source tree to temporary directory,
#
(cd ${src} && (tar cf - . | tar xf - -C ${src2}))

# 2. patch sources per LFS
#
chmod -R +w ${src2}

(cd ${src2} && ${bash_program} ${m4_patch})

#chmod -R -w ${src2}

# Must skip:
#   .m4 and .in files (assume they trigger re-running autoconf)
#   test/ files
#
#sed -i -e "s:/bin/sh:${bash_program}:g" ${src2}/configure #${src2}/build-aux/*

# ${src}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"

(cd ${builddir} && ${bash_program} ${src2}/configure --prefix=${out} CPP=cpp CPPFLAGS="-I${toolchain}/include" CFLAGS="-I${toolchain}/include" LDFLAGS="-Wl,-enable-new-dtags")

(cd ${builddir} && make SHELL=${CONFIG_SHELL})

(cd ${builddir} && make install SHELL=${CONFIG_SHELL})

# ----------------------------------------------------------------
# verify something runs

${out}/bin/m4 --version
