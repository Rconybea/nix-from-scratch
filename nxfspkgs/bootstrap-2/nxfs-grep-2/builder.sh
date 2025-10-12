#!/bin/bash

set -euo pipefail

echo "gcc_wrapaper=${gcc_wrapper}"
echo "toolchain=${toolchain}"
echo "gnumake=${gnumake}"
echo "gawk=${gawk}"
echo "gnugrep=${gnugrep}"
echo "gnused=${gnused}"
echo "gnutar=${gnutar}"
echo "coreutils=${coreutils}"
echo "findutils=${findutils}"
echo "diffutils=${diffutils}"
echo "bash=${bash}"
echo "src=${src}"
echo "TMPDIR=${TMPDIR}"

export PATH="${gcc_wrapper}/bin:${toolchain}/bin:${gnumake}/bin:${gawk}/bin:${gnugrep}/bin:${gnused}/bin:${gnutar}/bin:${coreutils}/bin:${diffutils}/bin:${findutils}/bin:${bash}/bin"

builddir=${TMPDIR}

mkdir ${out}

bash_program=${bash}/bin/bash

# ${src}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"

# inspect shebang
#head -5 ${src}/configure

(cd ${builddir} && ${bash_program} ${src}/configure --prefix=${out} CC="nxfs-gcc" CPP=cpp CPPFLAGS="-I${toolchain}/include" CFLAGS="-I${toolchain}/include" LDFLAGS="-Wl,-enable-new-dtags")

(cd ${builddir} && make SHELL=${CONFIG_SHELL})
(cd ${builddir} && make install SHELL=${CONFIG_SHELL})

${out}/bin/grep --version
