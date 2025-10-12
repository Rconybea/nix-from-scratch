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
echo "src=${src}"
echo "TMPDIR=${TMPDIR}"

export PATH="${gcc_wrapper}/bin:${toolchain}/bin:${gnumake}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${tar}/bin:${coreutils}/bin:${findutils}/bin:${diffutils}/bin:${bash}/bin"

src2=${TMPDIR}/src2
builddir=${TMPDIR}/build

mkdir -p ${src2}
mkdir -p ${builddir}

mkdir ${out}

# 1. copy source tree to temporary directory,
#
(cd ${src} && (tar cf - . | tar xf - -C ${src2}))

# 2. substitute nix-store path-to-bash for /bin/sh.
#
#
chmod -R +w ${src2}

bash_program=${bash}/bin/bash

# 1. Replace
#     const char *default_shell = "/bin/sh";
#   with
#     const char *default_shell = "$path/to/nix/store/$somehash/bin/bash";
#
#   Need this so that the gnu extension $(shell ..) works from within nix-build !
#   Building bootstrap-2-demo/gnumake-1 verifies
#
(cd ${src2} && sed -i -e 's:"/bin/sh":"'${bash_program}'":' ./src/job.c)

# ${src}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"


(cd ${builddir} && ${bash_program} ${src2}/configure --prefix=${out} --without-guile CPP=cpp CPPFLAGS="-I${toolchain}/include" CC="nxfs-gcc" CFLAGS="-I${toolchain}/include" LDFLAGS="-Wl,-enable-new-dtags")

(cd ${builddir} && make SHELL=${CONFIG_SHELL})

(cd ${builddir} && make install SHELL=${CONFIG_SHELL})

# verify executable runs

${out}/bin/make --version
