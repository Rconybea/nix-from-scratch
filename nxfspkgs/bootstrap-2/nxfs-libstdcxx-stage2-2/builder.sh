#! /bin/bash

# See also
#   https://gcc.gnu.org/install/configure.html

echo "src=${src}"
echo "mpc=${mpc}"
echo "mpfr=${mpfr}"
echo "gmp=${gmp}"
echo "gcc_wrapper=${gcc_wrapper}"
echo "toolchain=${toolchain}"
echo "bison=${bison}";
echo "flex=${flex}";
echo "diffutils=${diffutils}"
echo "findutils=${findutils}"
echo "coreutils=${coreutils}"
echo "gnumake=${gnumake}"
echo "gawk=${gawk}"
echo "grep=${grep}"
echo "sed=${sed}"
echo "tar=${tar}"
#echo "texinfo=${texinfo}";
echo "glibc=${glibc}"
echo "sysroot=${sysroot}"
#echo "mkdir=${mkdir}"
#echo "head=${head}"
echo "bash=${bash}"
echo "target_tuple=${target_tuple}"
echo "TMPDIR=${TMPDIR}"

set -e
set -x

# 1. ${coreutils}/bin provides mkdir,cat,ls etc.
#    Shadows external-to-nix versions adopted via crosstool-ng
# 2. ${gcc_wrapper}/bin/nxfs-gcc builds viable executables.
#
export PATH=${bash}/bin:$PATH
export PATH=${coreutils}/bin:$PATH
export PATH=${tar}/bin:$PATH
export PATH=${sed}/bin:$PATH
export PATH=${grep}/bin:$PATH
export PATH=${gawk}/bin:$PATH
export PATH=${gnumake}/bin:$PATH
#export PATH=${toolchain}/x86_64-pc-linux-gnu/bin:$PATH
#export PATH=${toolchain}/bin:$PATH
export PATH=${gcc_wrapper}/bin:$PATH
export PATH=${binutils}/bin:$PATH
export PATH=${findutils}/bin:$PATH
export PATH=${diffutils}/bin:$PATH
export PATH=${m4}/bin:$PATH
export PATH=${texinfo}/bin:$PATH
export PATH=${flex}/bin:$PATH
export PATH=${bison}/bin:$PATH

src2=${TMPDIR}/src2
builddir=${TMPDIR}/build

mkdir -p ${src2}
mkdir -p ${builddir}

mkdir ${out}

bash_program=${bash}/bin/bash

# 1. copy source tree to temporary directory,
#
(cd ${src}  && (tar cf - . | tar xf - -C ${src2}))

chmod -R +w ${src2}
(cd ${src2} && sed -i -e '/m64=/s:lib64:lib:' ./gcc/config/i386/t-linux64)
(cd ${src2} && sed -i -e "1s:#!/bin/sh:#!${bash_program}:" move-if-change)

# binutils before toolchain, want to use the bootstrap-2 versions from nxfs-binutils-2
#
(cd ${src2} && find . -type f | grep -v '*.l$' | xargs --replace=xx sed -i -e "1s:#! /bin/sh:#! ${bash_program}:" -e "1s:#!/usr/bin/env sh:#! ${bash_program}:" -e "#1:#!/usr/bin/env bash:#! ${bash_program}:" xx)
#(cd ${src2} && find . -type f | grep -v '.m4$' | grep -v '*.ac$' | xargs --replace=xx sed -i -e "1s:#! /bin/sh:#! ${bash_program}:" -e "1s:#!/usr/bin/env bash:#! ${bash_program}:" xx)

# ${src2}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"

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
#
# other interesting args we may adopt:
#   --with-native-system-header-dir=dirname   look for native system headers here, instead of in /usr/include
#                                             may want to point this at sysroot/usr/include
#   --with-stage1-libs
#   --with-stage1-ldflags
#   --with-boot-libs
#   --with-boot-ldflags

# WARNING!
#   ${toolchain}/x86_64-pc-linux-gnu/sysroot/usr/include/obstack.h [~/nixroot/nix/store/rh8qr...]
#   ${sysroot}/usr/include                                         [~/nixroot/nix/store/4ban...]
# provide obstack.h which shadows the one in ${src}
#
#export CFLAGS="-I${coreutils}/include -I${sysroot}/usr/include -I${toolchain}/include"
export CFLAGS="-idirafter ${glibc}/include"
# TODO: -O2

LDFLAGS="-B${glibc}/lib"
#LDFLAGS="${LDFLAGS} -B${sysroot}/lib"
LDFLAGS="${LDFLAGS} -L${flex}/lib -L${mpc}/lib -L${mpfr}/lib -L${gmp}/lib"
LDFLAGS="${LDFLAGS} -Wl,-rpath,${mpc}/lib -Wl,-rpath,${mpfr}/lib -Wl,-rpath,${gmp}/lib"
LDFLAGS="${LDFLAGS} -Wl,-rpath,${glibc}/lib"
#LDFLAGS="${LDFLAGS} -Wl,-rpath,${sysroot}/lib"
export LDFLAGS

# NOTE: nxfs-gcc automatically inserts flags 
# 
#          -Wl,--rpath=${NXFS_SYSROOT_DIR}/lib -Wl,--dynamic-linker=${NXFS_SYSROOT_DIR}/lib/ld-linux-x86-64.so.2
#       We still need them explictly here
#
#
# this builds:
(cd ${builddir} && ${bash_program} ${src2}/libstdc++-v3/configure --prefix=${out} --with-gxx-include-dir=${out}/x86_64-pc-linux-gnu/include/c++/14.2.0 --host=${target_tuple} --build=${target_tuple} --disable-nls --disable-multilib --disable-libstdcxx-pch CC=nxfs-gcc CXX=nxfs-g++ CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}")


(cd ${builddir} && make SHELL=${CONFIG_SHELL})
(cd ${builddir} && make install SHELL=${CONFIG_SHELL})
