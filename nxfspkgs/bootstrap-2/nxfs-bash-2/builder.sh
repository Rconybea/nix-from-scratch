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
echo "findutils=${findutils}"
echo "diffutils=${diffutils}"
echo "bash=${bash}"
echo "ncurses=${ncurses}"
echo "src=${src}"
echo "TMPDIR=${TMPDIR}"

export PATH="${gcc_wrapper}/bin:${toolchain}/bin:${ncurses}/bin:${gnumake}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${tar}/bin:${coreutils}/bin:${findutils}/bin:${diffutils}/bin:${bash}/bin"

ls -l ${toolchain}/x86_64-pc-linux-gnu/bin

builddir=${TMPDIR}/build

mkdir -p ${builddir}

mkdir ${out}

bash_program=${bash}/bin/bash
# Must skip:
#   .m4 and .in files (assume they trigger re-running autoconf)
#   test/ files
#

# ${src}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"

CFLAGS="-I${ncurses}/include -I${toolchain}/include"
LDFLAGS="-L${ncurses}/lib -Wl,-rpath,${ncurses}/lib -Wl,-enable-new-dtags"

(cd ${builddir} && ${bash_program} ${src}/configure --prefix=${out} --with-curses --without-bash-malloc bash_cv_strtold_broken=no CPP=cpp CPPFLAGS="-I${toolchain}/include" CC="nxfs-gcc" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS")

(cd ${builddir} && make SHELL=${CONFIG_SHELL})

(cd ${builddir} && make install SHELL=${CONFIG_SHELL})

# post-install
(cd ${out}/bin && ln -sfv bash sh)

${out}/bin/bash --version
