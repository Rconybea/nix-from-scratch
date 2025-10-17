#! /bin/bash

# See also
#   https://gcc.gnu.org/install/configure.html

set -euo pipefail

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
echo "glibc=${glibc}"
echo "bash=${bash}"
echo "target_tuple=${target_tuple}"
echo "TMPDIR=${TMPDIR}"

set -x

export PATH=${bash}/bin:$PATH
export PATH=${coreutils}/bin:$PATH
export PATH=${tar}/bin:$PATH
export PATH=${sed}/bin:$PATH
export PATH=${grep}/bin:$PATH
export PATH=${gawk}/bin:$PATH
export PATH=${gnumake}/bin:$PATH
export PATH=${gcc_wrapper}/bin:$PATH
export PATH=${binutils}/bin:$PATH
export PATH=${findutils}/bin:$PATH
export PATH=${diffutils}/bin:$PATH
export PATH=${m4}/bin:$PATH
export PATH=${texinfo}/bin:$PATH
export PATH=${flex}/bin:$PATH
export PATH=${bison}/bin:$PATH

#src2=${src}
src2=${TMPDIR}/src2
builddir=${TMPDIR}/build

mkdir -p ${src2}
mkdir -p ${builddir}

mkdir ${out}
mkdir -p ${out}/${target_tuple}/lib
mkdir ${source}

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
#   ${glibc}/include/obstack.h
# provides obstack.h which shadows the one in ${src}
#
export CFLAGS="-idirafter ${glibc}/include"
# TODO: -O2

# toolchain holds unwrapped, imported, gcc + binutils + glibc from host
#
LDFLAGS="-B${glibc}/lib -B${toolchain}/lib"
LDFLAGS="${LDFLAGS} -L${flex}/lib -L${mpc}/lib -L${mpfr}/lib -L${gmp}/lib"
LDFLAGS="${LDFLAGS} -Wl,-rpath,${mpc}/lib -Wl,-rpath,${mpfr}/lib -Wl,-rpath,${gmp}/lib"
LDFLAGS="${LDFLAGS} -Wl,-rpath,${glibc}/lib -Wl,-rpath,${toolchain}/lib"
export LDFLAGS

# The wrapper (nxfs-gcc) injects compiler- and linker- flags to pull in toolchain glibc.
# This works for much of the gcc build,  however the additional flags are lost when the gcc
# built invokes freshly-build xgcc to build support libraries like libgcc_s.so.
# This fails, because ld (from nxfs-binutils-2) can't find {crti.o, crtn.o, -lc}.
#
# Two ways we might try to fix this:
#
# A. Introduce a binutils wrapper for ld that reintroduces the missing flags.
#    So ld{w} ... would invoke
#      ld{u} -rpath=${NXFS_SYSROOT_DIR}/lib -dynamic-linker=${NXFS_SYSROOT_DIR}/lib/ld-linux-x86-64.so.2 ...
#
# B. Notice that the xgcc invocation has -B flags for ${out}/${target_tuple}/lib under our own ${out} dir,
#    so we could try to copy (or, symlink) {crti.o,crtn.o,libc.so,} from there
#    I expect this is problematic for the same reason we can't just copy libc.so: it expects to know where it lives.
#
ln -s ${glibc}/lib/crti.o ${out}/${target_tuple}/lib/crti.o
ln -s ${glibc}/lib/crtn.o ${out}/${target_tuple}/lib/crtn.o
ln -s ${glibc}/lib/libc.so ${out}/${target_tuple}/lib/libc.so
ln -s ${glibc}/lib/libc.so.6 ${out}/${target_tuple}/lib/libc.so.6
# omitting: Mcrt1.o, Scrt1.o, crt1.o gcrt1.o grcrt1.o ld-linux-x86-64.so.2
#           libBrokenLocale.so libBrokenLocale.so.1
#           libanl.so libanl.so.1 etc.

# glibc:
#  - built by us outside nix, (then adopted into nix store)
#  - entirely from within nix, see nxfs-glibc-stage1-2
# here we tell nxfs-gcc to use this glibc instead of crosstools-ng glibc
#
#export NXFS_SYSROOT_DIR=${glibc}

# NOTE: nxfs-gcc automatically inserts flags
#
#          -Wl,--rpath=${NXFS_SYSROOT_DIR}/lib -Wl,--dynamic-linker=${NXFS_SYSROOT_DIR}/lib/ld-linux-x86-64.so.2
#       We still need them explictly here
#
(cd ${builddir} \
     && ${bash_program} ${src2}/configure --prefix=${out} --disable-bootstrap \
                        --with-native-system-header-dir=${glibc}/include \
                        --enable-lto --disable-nls --with-mpc=${mpc} --with-mpfr=${mpfr} \
                        --with-gmp=${gmp} --enable-default-pie --enable-default-ssp \
                        --enable-shared --disable-multilib --disable-threads \
                        --disable-libatomic --disable-libgomp --disable-libquadmath \
                        --disable-libssp --disable-libvtv --disable-libstdcxx \
                        --enable-languages=c,c++ \
                        --with-stage1-ldflags="-B${glibc}/lib -Wl,-rpath,${glibc}/lib -B${toolchain}/lib -Wl,-rpath,${toolchain}/lib" \
                        --with-boot-ldflags="-B${glibc}/lib -Wl,-rpath,${glibc}/lib -B${toolchain}/lib -Wl,-rpath,${toolchain}/lib" \
                        CC=nxfs-gcc CXX=nxfs-g++ CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}")

(cd ${builddir} && make SHELL=${CONFIG_SHELL})
(cd ${builddir} && make install SHELL=${CONFIG_SHELL})

# gcc build doesn't

# can now remove the sysroot debris we temporarily put into ${out}/${target_tuple}
rm ${out}/${target_tuple}/lib/crti.o
rm ${out}/${target_tuple}/lib/crtn.o
rm ${out}/${target_tuple}/lib/libc.so
rm ${out}/${target_tuple}/lib/libc.so.6

(cd ${src2} && (tar cf - . | tar xf - -C ${source}))
