#!/bin/bash

echo "gcc_wrapper=${gcc_wrapper}"
echo "toolchain=${toolchain}"
echo "findutils=${findutils}"
echo "coreutils=${coreutils}"
echo "gnumake=${gnumake}"
echo "gawk=${gawk}"
echo "grep=${grep}"
echo "sed=${sed}"
echo "tar=${tar}"
echo "coreutils=${coreutils}"
echo "sysroot=${sysroot}"
#echo "mkdir=${mkdir}"
#echo "head=${head}"
echo "bash=${bash}"
echo "gcc_src=${gcc_src}"
echo "mpfr_src=${mpfr_src}"
echo "mpc_src=${mpc_src}"
echo "gmp_src=${gmp_src}"
echo "target_tuple=${target_tuple}"
echo "TMPDIR=${TMPDIR}"

set -e
set -x

# 1. ${coreutils}/bin provides mkdir,cat,ls etc.
#    Shadows external-to-nix versions adopted via crosstool-ng
# 2. ${gcc_wrapper}/bin/x86_64-pc-linux-gnu-{gcc,g++} builds viable executables.
# 3. ${toolchain}/bin/x86_64-pc-linux-gnu-gcc can build executables,
#    but they won't run unless we pass special linker flags
# 4. ${toolchain}/bin                     has x86_64-pc-linux-gnu-ar
# 5. ${toolchain}/x86_64-pc-linux-gnu/bin has ar  <- autotools looks for this
#
export PATH="${findutils}/bin:${coreutils}/bin:${gcc_wrapper}/bin:${toolchain}/bin:${toolchain}/x86_64-pc-linux-gnu/bin:${gnumake}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${tar}/bin:${coreutils}/bin:${bash}/bin"

# WARNING!
#   ${toolchain}/x86_64-pc-linux-gnu/sysroot/usr/include/obstack.h [~/nixroot/nix/store/rh8qr...]
#   ${sysroot}/usr/include                                         [~/nixroot/nix/store/4ban...]
# provide obstack.h which shadows the one in ${src}
#
#export CFLAGS="-I${coreutils}/include -I${sysroot}/usr/include -I${toolchain}/include"

#ls -l ${toolchain}/x86_64-pc-linux-gnu/bin

src=${gcc_src}
#src2=${src}
src2=${TMPDIR}/src2
builddir=${TMPDIR}/build

mkdir -p ${src2}
mkdir -p ${src2}/mpfr
mkdir -p ${src2}/mpc
mkdir -p ${src2}/gmp
mkdir -p ${builddir}

mkdir ${out}

bash_program=${bash}/bin/bash

# 1. copy source tree to temporary directory,
#
(cd ${gcc_src}  && (tar cf - . | tar xf - -C ${src2}))
(cd ${mpfr_src} && (tar cf - . | tar xf - -C ${src2}/mpfr))
(cd ${mpc_src}  && (tar cf - . | tar xf - -C ${src2}/mpc))
(cd ${gmp_src}  && (tar cf - . | tar xf - -C ${src2}/gmp))

chmod -R +w ${src2}
(cd ${src2} && sed -e '/m64=/s:lib64:lib:' -i.orig ./gcc/config/i386/t-linux64)
# don't want to touch m4 files;
# changing those requires subsequently running automake,
# which in turn needs perl,
# and we run into trouble trying to build this in boostrap environment
#
(cd ${src2} && find . -type f | grep -v '.m4$' | grep -v '*.ac$' | xargs --replace=xx sed -i -e "1s:#! /bin/sh:#! ${bash_program}:" -e "1s:#!/usr/bin/env bash:#! ${bash_program}:" xx)

# ----------------------------------------------------------------
# NOTE: omitting coreutils unicode patch
#       since we don't need it for bootstrap
# ----------------------------------------------------------------

# ${src2}/configure honors CONFIG_SHELL
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
# Variation w.r.t. linuxfromscratch
#   --with-glibc-version=2.40   keep this, since we're about to build glibc
#   --with-newlib               don't compile libc-dependent code (we have some other libc from sysroot)
#   --with-sysroot              should not need this.   Not planning to chroot anywhere
#   --without-headers           will need kernel headers compatible with target.  Don't look for them for now.
#   --disable-shared            necessary so we can invoke gcc without libc
#   --disable-multilib

(cd ${builddir} && ${bash_program} ${src2}/configure --prefix=${out} --host=${target_tuple} --build=${target_tuple} --disable-nls --with-glibc-version=2.40 --with-newlib --without-headers --enable-default-pie --enable-default-ssp --disable-nls --disable-shared --disable-multilib --disable-threads --disable-libatomic --disable-libgomp --disable-libquadmath --disable-libssp --disable-libvtv --disable-libstdcxx --enable-languages=c,c++ CFLAGS="${CFLAGS}" LDFLAGS="-Wl,-enable-new-dtags")

# (MAKEINFO=true use 'path/to/bin/true' for MAKEINFO, to suppress building docs (would need texinfo <- perl))
(cd ${builddir} && make SHELL=${CONFIG_SHELL})

(cd ${builddir} && make install SHELL=${CONFIG_SHELL})
