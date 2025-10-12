#!/bin/bash

set -euo pipefail

echo "gcc_wrapaper=${gcc_wrapper}"
echo "toolchain=${toolchain}"
echo "gnumake=${gnumake}"
echo "gawk=${gawk}"
echo "grep=${grep}"
echo "gnused=${gnused}"
echo "gnutar=${gnutar}"
echo "coreutils=${coreutils}"
echo "findutils=${findutils}"
echo "diffutils=${diffutils}"
echo "bash=${bash}"
echo "src=${src}"
echo "TMPDIR=${TMPDIR}"

export PATH="${gcc_wrapper}/bin:${toolchain}/bin:${gnumake}/bin:${gawk}/bin:${grep}/bin:${gnused}/bin:${gnutar}/bin:${coreutils}/bin:${bash}/bin:${findutils}/bin:${diffutils}/bin"

builddir=${TMPDIR}

mkdir ${out}

bash_program=${bash}/bin/bash

# ${src}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"

(cd ${builddir} && ${bash_program} ${src}/configure --prefix=${out} CC="nxfs-gcc" CPP="cpp" CPPFLAGS="-I${toolchain}/include" CFLAGS="-I${toolchain}/include" LDFLAGS="-Wl,-enable-new-dtags")

(cd ${builddir} && make SHELL=${CONFIG_SHELL})
(cd ${builddir} && make install SHELL=${CONFIG_SHELL})

${out}/bin/sed --version
