{
  # nxfsenv   :: { mkDerivation :: attrs -> derivation,
  #                gcc-wrapper :: derivation  (also as gcc_wrapper)
  #                binutils    :: derivation
  #                perl        :: derivation
  #                gawk        :: derivation
  #                gnumake     :: derivation
  #                gnugrep     :: derivation
  #                gnutar      :: derivation
  #                gnused      :: derivation
  #                coreutils   :: derivation
  #                bash        :: derivation
  #                glibc       :: derivation
  #                nxfs-defs   :: { target_tuple :: string }
  #              }
  nxfsenv,
  # nxfsenv-3 :: {
  #
  #                bison       :: derivation
  #                flex        :: derivation
  #                patch       :: derivation
  #                gperf       :: derivation
  #                python      :: derivation
  #                patchelf    :: derivation
  #
  #                zlib        :: derivation
  #                m4          :: derivation
  #                perl        :: derivation
  #                pkgconf     :: derivation
  #                coreutils   :: derivation
  #                gnumake     :: derivation
  #                gawk        :: derivation
  #                bash        :: derivation
  #                gnutar      :: derivation
  #                gnugrep     :: derivation
  #                gnused      :: derivation
  #                findutils   :: derivation
  #                diffutils   :: derivation
  #                which       :: derivation
  #              }
  nxfsenv-3,

  # mpc :: derivation
  mpc,
  # mpfr :: derivation
  mpfr,
  # gmp :: derivation
  gmp,
} :

let
  gcc-s1-unwrapped = nxfsenv-3.gcc-s1-unwrapped;
  nxfs-binutils-3  = nxfsenv-3.binutils;
  nxfs-glibc-3     = nxfsenv-3.glibc;
  nxfs-defs        = nxfsenv.nxfs-defs;
in

let
  version          = gcc-s1-unwrapped.version;
in

nxfsenv.mkDerivation {
  name             = "nxfs-libstdcxx-s2-3";
  version          = version;

  system           = builtins.currentSystem;

  gcc_wrapper      = nxfsenv-3.gcc-s1-wrapper-3;
  gcc_unwrapped    = gcc-s1-unwrapped;
  glibc            = nxfsenv-3.glibc;

  binutils_wrapper = nxfsenv-3.binutils-s1-wrapper-3;
  binutils         = nxfsenv-3.binutils;
  mpc              = mpc;
  mpfr             = mpfr;
  gmp              = gmp;
  texinfo          = nxfsenv-3.texinfo;
  bison            = nxfsenv-3.bison;
  flex             = nxfsenv-3.flex;
  m4               = nxfsenv-3.m4;
  coreutils        = nxfsenv-3.coreutils;
  bash             = nxfsenv-3.bash;
  tar              = nxfsenv-3.gnutar;
  gnumake          = nxfsenv-3.gnumake;
  gawk             = nxfsenv-3.gawk;
  grep             = nxfsenv-3.gnugrep;
  sed              = nxfsenv-3.gnused;
  findutils        = nxfsenv-3.findutils;
  diffutils        = nxfsenv-3.diffutils;
  which            = nxfsenv-3.which;

  src          = builtins.fetchTarball { name = "gcc-${version}-source";
                                         url = "https://ftp.gnu.org/gnu/gcc/gcc-${version}/gcc-${version}.tar.xz";
                                         sha256 = "1bdp6l9732316ylpzxnamwpn08kpk91h7cmr3h1rgm3wnkfgxzh9";
                                       };

  outputs      = [ "out" "source" ];

  target_tuple = nxfs-defs.target_tuple;

  buildPhase = ''
    # See also
    #   https://gcc.gnu.org/install/configure.html

    echo "src=$src"
    echo "mpc=$mpc"
    echo "mpfr=$mpfr"
    echo "gmp=$gmp"
    echo "gcc_wrapper=$gcc_wrapper"
    echo "bison=$bison";
    echo "flex=$flex";
    echo "diffutils=$diffutils"
    echo "findutils=$findutils"
    echo "coreutils=$coreutils"
    echo "gnumake=$gnumake"
    echo "gawk=$gawk"
    echo "grep=$grep"
    echo "sed=$sed"
    echo "tar=$tar"
    echo "glibc=$glibc"
    echo "bash=$bash"
    echo "target_tuple=$target_tuple"
    echo "TMPDIR=$TMPDIR"

    set -e

    # 1. $coreutils/bin provides mkdir,cat,ls etc.
    #    Shadows external-to-nix versions adopted via crosstool-ng
    # 2. $gcc_wrapper/bin/nxfs-gcc builds viable executables.
    #
    export PATH=$which/bin:$PATH
    export PATH=$bash/bin:$PATH
    export PATH=$coreutils/bin:$PATH
    export PATH=$tar/bin:$PATH
    export PATH=$sed/bin:$PATH
    export PATH=$grep/bin:$PATH
    export PATH=$gawk/bin:$PATH
    export PATH=$gnumake/bin:$PATH
    export PATH=$gcc_wrapper/bin:$PATH
    export PATH=$binutils/bin:$PATH
    export PATH=$binutils_wrapper/bin:$PATH
    export PATH=$findutils/bin:$PATH
    export PATH=$diffutils/bin:$PATH
    export PATH=$m4/bin:$PATH
    export PATH=$texinfo/bin:$PATH
    export PATH=$flex/bin:$PATH
    export PATH=$bison/bin:$PATH

    echo "PATH=$PATH"

    src2=$TMPDIR/src2
    builddir=$TMPDIR/build

    mkdir -p $src2
    mkdir -p $builddir
    mkdir -p $source

    bash_program=$bash/bin/bash

    # 1. copy source tree to temporary directory,
    #
    (cd $src  && (tar cf - . | tar xf - -C $src2))

    chmod -R +w $src2
    (cd $src2 && sed -i -e '/m64=/s:lib64:lib:' ./gcc/config/i386/t-linux64)
    (cd $src2 && sed -i -e "1s:#!/bin/sh:#!$bash_program:" move-if-change)

    # binutils before toolchain, want to use the bootstrap-2 versions from nxfs-binutils-2
    #
    (cd $src2 && find . -type f | grep -v '*.l$' | xargs --replace=xx sed -i -e "1s:#! /bin/sh:#! $bash_program:" -e "1s:#!/usr/bin/env sh:#! $bash_program:" -e "#1:#!/usr/bin/env bash:#! $bash_program:" xx)
    #(cd $src2 && find . -type f | grep -v '.m4$' | grep -v '*.ac$' | xargs --replace=xx sed -i -e "1s:#! /bin/sh:#! $bash_program:" -e "1s:#!/usr/bin/env bash:#! $bash_program:" xx)

    # $src2/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$bash_program"

    # --disable-nls:                    no internationalization.  don't need during bootstrap
    # --enable-gprofng=no:              don't need gprofng tool during bootstrap
    # --disable-werror:                 don't treat compiler warnings as errors
    # --enable-default-hash-style=gnu:  only generate faster gnu-style symbol hash table by default.
    #
    # linuxfromscratch sets --sysroot=$LFS.
    # We think we don't need this, since gcc-wrapper points built executables/libraries to libc etc in $sysroot
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

    export CFLAGS="-idirafter $glibc/include"
    # TODO: -O2

    LDFLAGS="-B$glibc/lib"
    LDFLAGS="$LDFLAGS -L$flex/lib -L$mpc/lib -L$mpfr/lib -L$gmp/lib"
    LDFLAGS="$LDFLAGS -Wl,-rpath,$mpc/lib -Wl,-rpath,$mpfr/lib -Wl,-rpath,$gmp/lib"
    LDFLAGS="$LDFLAGS -Wl,-rpath,$glibc/lib"
    export LDFLAGS

    # NOTE: nxfs-gcc automatically inserts flags
    #
    #          -Wl,--rpath=$NXFS_SYSROOT_DIR/lib -Wl,--dynamic-linker=$NXFS_SYSROOT_DIR/lib/ld-linux-x86-64.so.2
    #       But still need them explictly here
    #
    #
    # this builds:
    (cd $builddir && $bash_program $src2/libstdc++-v3/configure --prefix=$out --with-gxx-include-dir=$out/$target_tuple/include/c++/$version --host=$target_tuple --build=$target_tuple --disable-nls --disable-multilib --enable-libstdcxx-pch CC=nxfs-gcc CXX=nxfs-g++ CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS")

    echo '\$builddir/src:'
    ls -l $builddir/src

    ln -s $glibc/lib/crt1.o $builddir/src/crt1.o
    ln -s $glibc/lib/crti.o $builddir/src/crti.o
    ln -s $glibc/lib/crtn.o $builddir/src/crtn.o
    ln -s $glibc/lib/Scrt1.o $builddir/src/Scrt1.o
#    ln -s $glibc/lib/libc.so $builddir/src/libc.so
#    ln -s $glibc/lib/libc.so.6 $builddir/src/libc.so.6

    (cd $builddir && make SHELL=$CONFIG_SHELL)

#    (cd $builddir && make install SHELL=$CONFIG_SHELL)
#    (cd $src2 && (tar cf - . | tar xf - -C $source))
  '';

  buildInputs = [ ];
}
