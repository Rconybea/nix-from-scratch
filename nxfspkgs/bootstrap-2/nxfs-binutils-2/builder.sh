#!/bin/bash

set -e
set -x

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
echo "sysroot=${sysroot}"
echo "src=${src}"
echo "target_tuple=${target_tuple}"
echo "TMPDIR=${TMPDIR}"

# 1. ${coreutils}/bin provides mkdir,cat,ls etc.
#    Shadows external-to-nix versions adopted via crosstool-ng
# 2. ${gcc_wrapper}/bin/x86_64-pc-linux-gnu-{gcc,g++} builds viable executables.
# 3. ${toolchain}/bin/x86_64-pc-linux-gnu-gcc can build executables,
#    but they won't run unless we pass special linker flags
# 4. ${toolchain}/bin                     has x86_64-pc-linux-gnu-ar
# 5. ${toolchain}/x86_64-pc-linux-gnu/bin has ar  <- autotools looks for this
#
export PATH="${perl}/bin:${m4}/bin:${coreutils}/bin:${gcc_wrapper}/bin:${toolchain}/bin:${toolchain}/x86_64-pc-linux-gnu/bin:${gnumake}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${tar}/bin:${coreutils}/bin:${findutils}/bin:${diffutils}/bin:${bash}/bin"

# WARNING!
#   ${toolchain}/x86_64-pc-linux-gnu/sysroot/usr/include/obstack.h [~/nixroot/nix/store/rh8qr...]
#   ${sysroot}/usr/include                                         [~/nixroot/nix/store/4ban...]
# provide obstack.h which shadows the one in ${src}
#
#export CFLAGS="-I${coreutils}/include -I${sysroot}/usr/include -I${toolchain}/include"

#ls -l ${toolchain}/x86_64-pc-linux-gnu/bin

#src2=${src}
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
#chmod -R +w ${src2}
#(cd ${src2} && ${bash_program} ${m4_patch})
#chmod -R -w ${src2}

# ----------------------------------------------------------------
# NOTE: omitting coreutils unicode patch
#       since we don't need it for bootstrap
# ----------------------------------------------------------------

# ${src}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"

# 1.
# we shouldn't need special compiler/linker instructions,
# since stage-1 toolchain "knows where it lives"
#
# 2.
# do need to give --host and --build arguments to configure,
# since we're using a cross compiler.

# --disable-nls:                    no internationalization.  don't need during bootstrap
# --enable-gprofng=no:              don't need gprofng tool during bootstrap
# --disable-werror:                 don't treat compiler warnings as errors
# --enable-default-hash-style=gnu:  only generate faster gnu-style symbol hash table by default.
#
# linuxfromscratch sets --sysroot=$LFS.
# We think we don't need this, since gcc-wrapper points built executables/libraries to libc etc in ${sysroot}
#
(cd ${builddir} && ${bash_program} ${src2}/configure --prefix=${out} --host=${target_tuple} --build=${target_tuple} --disable-nls --enable-gprofng=no --disable-werror --enable-default-hash-style=gnu CFLAGS="${CFLAGS}" LDFLAGS="-Wl,-enable-new-dtags")

# MAKEINFO=true use 'path/to/bin/true' for MAKEINFO, to suppress building docs (would need texinfo <- perl)
(cd ${builddir} && make SHELL=${CONFIG_SHELL} MAKEINFO=true)

(cd ${builddir} && make install SHELL=${CONFIG_SHELL} MAKEINFO=true)
