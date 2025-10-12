#!/bin/bash

set -euo pipefail

echo "perl=${perl}"
echo "m4=${m4}"
echo "coreutils=${coreutils}"
echo "bash=${bash}"
echo "gnumake=${gnumake}"
echo "gawk=${gawk}"
echo "grep=${grep}"
echo "sed=${sed}"
echo "tar=${tar}"
echo "coreutils=${coreutils}"
echo "findutils=${findutils}"
echo "diffutils=${diffutils}"
echo "gcc_wrapper=${gcc_wrapper}"
echo "toolchain=${toolchain}"
echo "src=${src}"
echo "TMPDIR=${TMPDIR}"

set -x

export PATH="${perl}/bin:${m4}/bin:${coreutils}/bin:${gcc_wrapper}/bin:${toolchain}/bin:${gnumake}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${tar}/bin:${coreutils}/bin:${findutils}/bin:${diffutils}/bin:${bash}/bin"

# WARNING!
#   ${toolchain}/x86_64-pc-linux-gnu/sysroot/usr/include/obstack.h [~/nixroot/nix/store/rh8qr...]
#   ${sysroot}/usr/include                                         [~/nixroot/nix/store/4ban...]
# provide obstack.h which shadows the one in ${src}
#
#export CFLAGS="-I${coreutils}/include -I${sysroot}/usr/include -I${toolchain}/include"

#ls -l ${toolchain}/x86_64-pc-linux-gnu/bin

builddir=${TMPDIR}/build

mkdir -p ${builddir}

mkdir ${out}

bash_program=${bash}/bin/bash

# ${src}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"

# --disable-nls:                    no internationalization.  don't need during bootstrap
# --enable-gprofng=no:              don't need gprofng tool during bootstrap
# --disable-werror:                 don't treat compiler warnings as errors
# --enable-default-hash-style=gnu:  only generate faster gnu-style symbol hash table by default.
#
# linuxfromscratch sets --sysroot=$LFS.
# We think we don't need this, since gcc-wrapper points built executables/libraries to libc etc in ${sysroot}
#
(cd ${builddir} && ${bash_program} ${src}/configure --prefix=${out} --disable-nls --enable-gprofng=no --disable-werror --enable-default-hash-style=gnu CC=nxfs-gcc LDFLAGS="-Wl,-enable-new-dtags")

# MAKEINFO=true use 'path/to/bin/true' for MAKEINFO, to suppress building docs (would need texinfo <- perl)
(cd ${builddir} && make SHELL=${CONFIG_SHELL} MAKEINFO=true)

(cd ${builddir} && make install SHELL=${CONFIG_SHELL} MAKEINFO=true)

# verify some executable runs
${out}/bin/as --version
