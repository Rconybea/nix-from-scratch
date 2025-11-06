{
  stdenv,

  # nixified-gcc-source :: derivation
  nixified-gcc-source,

  # binutils-wrapper :: derivation
  binutils-wrapper,

  # mpc :: derivation
  mpc,
  # mpfr :: derivation
  mpfr,
  # gmp :: derivation
  gmp,
  # isl :: derivation
  isl,

  # bison :: derivation
  bison,

  # flex :: derivation
  flex,

  # texinfo :: derivation
  texinfo,

  # m4 :: derivation
  m4,

  # glibc :: derivation   --  glibc + linux headers
  glibc,

  # nxfs-defs :: derivation
  nxfs-defs,

  # stageid :: string  -- "2" for stage2 etc.
  stageid,
} :

let
  version = nixified-gcc-source.version;
in

stdenv.mkDerivation {
  name         = "nxfs-gcc-x1-${stageid}";
  version      = version;

  system       = builtins.currentSystem;

  inherit mpc mpfr gmp isl flex glibc;

  libc = glibc;

  src          = nixified-gcc-source;

  outputs      = [ "out" ];

  target_tuple = nxfs-defs.target_tuple;

  buildPhase = ''
    # See also
    #   https://gcc.gnu.org/install/configure.html

    set -euo pipefail

    prev_unwrapped_gcc=${stdenv.cc.cc}

    echo "prev_unwrapped_gcc=$prev_unwrapped_gcc"
    echo "glibc=$libc"

    builddir=$TMPDIR/build

    mkdir -p $builddir

    mkdir -p $out
    mkdir -p $out/$target_tuple/lib

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$shell"

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

    export CFLAGS="-idirafter $libc/include"
    # TODO: -O2

    LDFLAGS="-B$libc/lib"
    LDFLAGS="$LDFLAGS -L$flex/lib -L$mpc/lib -L$mpfr/lib -L$gmp/lib -L$isl/lib"
    LDFLAGS="$LDFLAGS -Wl,-rpath,$mpc/lib -Wl,-rpath,$mpfr/lib -Wl,-rpath,$gmp/lib"
    LDFLAGS="$LDFLAGS -Wl,-rpath,$isl/lib -Wl,-rpath,$libc/lib"
    export LDFLAGS

    # The wrapper (nxfs-gcc) injects compiler- and linker- flags to pull in glibc.
    # This works for much of the gcc build,  however the additional flags are lost when the gcc
    # built invokes freshly-build xgcc to build support libraries like libgcc_s.so.
    # This fails, because ld (from nxfs-binutils-2) can't find {crti.o, crtn.o, -lc}.
    #
    # Two ways we might try to fix this:
    #
    # A. Introduce a binutils wrapper for ld that reintroduces the missing flags.
    #    So ld{w} ... would invoke
    #      ld{u} -rpath=$NXFS_SYSROOT_DIR/lib -dynamic-linker=$NXFS_SYSROOT_DIR/lib/ld-linux-x86-64.so.2 ...
    #
    # B. Notice that the xgcc invocation has -B flags for $out/$target_tuple/lib under our own $out dir,
    #    so we could try to copy (or, symlink) {crti.o,crtn.o,libc.so,} from there
    #    I expect this is problematic for the same reason we can't just copy libc.so: it expects to know where it lives.
    #
    ln -s $libc/lib/crti.o $out/$target_tuple/lib/crti.o
    ln -s $libc/lib/crtn.o $out/$target_tuple/lib/crtn.o
    ln -s $libc/lib/libc.so $out/$target_tuple/lib/libc.so
    ln -s $libc/lib/libc.so.6 $out/$target_tuple/lib/libc.so.6
    # omitting: Mcrt1.o, Scrt1.o, crt1.o gcrt1.o grcrt1.o ld-linux-x86-64.so.2
    #           libBrokenLocale.so libBrokenLocale.so.1
    #           libanl.so libanl.so.1 etc.

    # here we tell nxfs-gcc to use native prepared-within-nix glibc (i.e. $libc from this stage)
    # instead of glibc baked into nxfs-gcc (from prev stage)
    #
    export NXFS_SYSROOT_DIR=$libc

    # NOTE: nxfs-gcc automatically inserts flags
    #
    #          -Wl,--rpath=$NXFS_SYSROOT_DIR/lib -Wl,--dynamic-linker=$NXFS_SYSROOT_DIR/lib/ld-linux-x86-64.so.2
    #       We still need them explictly here
    #
    (cd $builddir \
      && $shell $src/configure --prefix=$out \
                       --disable-fixincludes \
                       --disable-bootstrap \
                       --disable-multilib \
                       --disable-nls \
                       --with-native-system-header-dir=$libc/include \
                       --enable-lto --with-mpc=$mpc --with-mpfr=$mpfr \
                       --with-gmp=$gmp --with-isl=$isl \
                       --enable-default-pie --enable-default-ssp \
                       --enable-shared \
                       --disable-threads \
                       --disable-libatomic --disable-libgomp --disable-libquadmath \
                       --disable-libssp --disable-libvtv \
                       --disable-libstdcxx \
                       --enable-languages=c,c++ \
                       --with-stage1-ldflags="-B$libc/lib -Wl,-rpath,$libc/lib" \
                       --with-boot-ldflags="-B$libc/lib -Wl,-rpath,$libc/lib" \
                       CC=nxfs-gcc CXX=nxfs-g++ CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS")

    (cd $builddir && make SHELL=$CONFIG_SHELL)
    (cd $builddir && make install SHELL=$CONFIG_SHELL)

    # build will produce binaries that put the lib directory from the unwrapped compiler that
    # that nxfs-gcc invokes. Would like to prune these, but they're needed since new gcc doesn't come with libstdc++.
    # Instead, put them at the end of RUNPATH, so they don't intercept the glibc we just provided
    #
    # prioritize libs from new compiler over version from $prev_unwrapped_gcc/lib
    # in this phase we need bootstrap compiler's lib directory in RUNPATH;
    # however it must come at the end; also patch dynamic linker to refer to the correct libc

    patchelf --set-rpath $out/lib:$glibc/lib:$prev_unwrapped_gcc/lib $out/bin/cpp
    patchelf --set-interpreter $glibc/lib/ld-linux-x86-64.so.2 $out/bin/cpp

    patchelf --set-rpath $out/lib:$glibc/lib:$prev_unwrapped_gcc/lib $out/bin/gcc
    patchelf --set-interpreter $glibc/lib/ld-linux-x86-64.so.2 $out/bin/gcc

    patchelf --set-rpath $out/lib:$glibc/lib:$prev_unwrapped_gcc/lib $out/bin/g++
    patchelf --set-interpreter $glibc/lib/ld-linux-x86-64.so.2 $out/bin/g++

    patchelf --set-rpath $out/lib:$glibc/lib:$prev_unwrapped_gcc/lib $out/bin/gcc-ar
    patchelf --set-interpreter $glibc/lib/ld-linux-x86-64.so.2 $out/bin/gcc-ar

    patchelf --set-rpath $out/lib:$glibc/lib:$prev_unwrapped_gcc/lib $out/bin/gcc-nm
    patchelf --set-interpreter $glibc/lib/ld-linux-x86-64.so.2 $out/bin/gcc-nm

    patchelf --set-rpath $out/lib:$glibc/lib:$prev_unwrapped_gcc/lib $out/bin/gcc-ranlib
    patchelf --set-interpreter $glibc/lib/ld-linux-x86-64.so.2 $out/bin/gcc-ranlib

    patchelf --set-rpath $out/lib:$glibc/lib:$prev_unwrapped_gcc/lib $out/bin/gcov
    patchelf --set-interpreter $glibc/lib/ld-linux-x86-64.so.2 $out/bin/gcov

    patchelf --set-rpath $out/lib:$glibc/lib:$prev_unwrapped_gcc/lib $out/bin/gcov-dump
    patchelf --set-interpreter $glibc/lib/ld-linux-x86-64.so.2 $out/bin/gcov-dump

    patchelf --set-rpath $out/lib:$glibc/lib:$prev_unwrapped_gcc/lib $out/bin/gcov-tool
    patchelf --set-interpreter $glibc/lib/ld-linux-x86-64.so.2 $out/bin/gcov-tool

    # note: $isl/lib is load-bearing; indirect dependency
    patchelf --set-rpath $out/lib:$mpc/lib:$mpfr/lib:$isl/lib:$gmp/lib:$libc/lib:$prev_unwrapped_gcc/lib $out/bin/lto-dump
    patchelf --set-interpreter $glibc/lib/ld-linux-x86-64.so.2 $out/bin/lto-dump


    # can now remove the sysroot debris we temporarily put into $out/$target_tuple
    rm $out/$target_tuple/lib/crti.o
    rm $out/$target_tuple/lib/crtn.o
    rm $out/$target_tuple/lib/libc.so
    rm $out/$target_tuple/lib/libc.so.6

    #(cd $src && (tar cf - . | tar xf - -C $source))
  '';

  buildInputs = [
                  binutils-wrapper
                  bison
                  flex
                  texinfo
                  m4
  ];
}
