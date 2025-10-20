{
  # stdenv :: deirvation+attrset
  stdenv,
  # gcc-x1-wrapper-3 :: derivation
  gcc-wrapper,
  # nixified-gcc-source :: derivation
  nixified-gcc-source,
  # binutils-wrapper :: derivation
  binutils-wrapper,
  # glibc :: derivation
  glibc,
  # nxfs-defs :: derivation
  nxfs-defs
} :

stdenv.mkDerivation {
  name         = "nxfs-libstdcxx-x2-3";
  version      = nixified-gcc-source.version;

  system       = builtins.currentSystem;

  gcc_wrapper  = gcc-wrapper;
  glibc        = glibc;

  src          = nixified-gcc-source;

  outputs      = [ "out" "source" ];

  target_tuple = nxfs-defs.target_tuple;

  buildPhase = ''
    # See also
    #   https://gcc.gnu.org/install/configure.html

    set -e

    #echo "cpp=$(which cpp)"
    echo "PATH=$PATH"

    builddir=$TMPDIR/build

    mkdir -p $builddir

    mkdir -p $out
    mkdir -p $source

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

    export CPPFLAGS="-idirafter $glibc/include"
    # TODO: -O2

    LDFLAGS="-B$glibc/lib"
    LDFLAGS="$LDFLAGS -Wl,-rpath,$glibc/lib"
    export LDFLAGS

    gcc=$gcc_wrapper/bin/gcc;
    gxx=$gcc_wrapper/bin/g++;

    # NOTE: nxfs-gcc automatically inserts flags
    #
    #          -Wl,--rpath=$NXFS_SYSROOT_DIR/lib -Wl,--dynamic-linker=$NXFS_SYSROOT_DIR/lib/ld-linux-x86-64.so.2
    #       But still need them explictly here
    #
    #
    # this builds:
    (cd $builddir && $shell $src/libstdc++-v3/configure \
                            --prefix=$out \
                            --with-gxx-include-dir=$out/$target_tuple/include/c++/$version \
                            --disable-nls --disable-multilib --enable-libstdcxx-pch \
                            CC=$gcc CXX=$gxx CPPFLAGS="$CPPFLAGS" LDFLAGS="$LDFLAGS")

    (cd $builddir && make SHELL=$CONFIG_SHELL)
    (cd $builddir && make install SHELL=$CONFIG_SHELL)

    (cd $src && (tar cf - . | tar xf - -C $source))
    '';

  buildInputs = [ gcc-wrapper
                  gcc-wrapper.cc
                  binutils-wrapper
#                  flex
#                  texinfo
#                  m4
                ];
}
