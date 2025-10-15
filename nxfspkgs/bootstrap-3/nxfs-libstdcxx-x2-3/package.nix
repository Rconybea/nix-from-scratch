{
  #  nxfsenv :: attrset
  nxfsenv,
  # gcc-x1-wrapper-3 :: derivation
  gcc-wrapper,
  # nixify-gcc-source :: derivation
  nixify-gcc-source,
  # mpc :: derivation
  mpc,
  # mpfr :: derivation
  mpfr,
  # gmp :: derivation
  gmp,
} :

let
  gcc_wrapper = gcc-wrapper;
  gcc         = nxfsenv.gcc;
  glibc       = nxfsenv.glibc;

  binutils    = nxfsenv.binutils;
  bison       = nxfsenv.bison;
  flex        = nxfsenv.flex;
  texinfo     = nxfsenv.texinfo;
  m4          = nxfsenv.m4;
  gawk        = nxfsenv.gawk;
  file        = nxfsenv.file;
  gnumake     = nxfsenv.gnumake;
  gnused      = nxfsenv.gnused;
  gnugrep     = nxfsenv.gnugrep;
  gnutar      = nxfsenv.gnutar;
  bash        = nxfsenv.shell;
  findutils   = nxfsenv.findutils;
  diffutils   = nxfsenv.diffutils;
  coreutils   = nxfsenv.coreutils;
  which       = nxfsenv.which;
in

let
  # nxfs-nixified-gcc-source :: derivation
  nxfs-nixified-gcc-source = nixify-gcc-source {
    inherit bash file findutils coreutils;
    sed       = gnused;
    grep      = gnugrep;
    tar       = gnutar;
  };

in

nxfsenv.mkDerivation {
  name         = "nxfs-libstdcxx-x2-3";
  version      = nxfs-nixified-gcc-source.version;

  system       = builtins.currentSystem;

  glibc        = glibc;

  mpc          = mpc;
  mpfr         = mpfr;
  gmp          = gmp;

  flex         = flex;
  src          = nxfs-nixified-gcc-source;

  outputs      = [ "out" "source" ];

  target_tuple = nxfsenv.nxfs-defs.target_tuple;

  buildPhase = ''
    # See also
    #   https://gcc.gnu.org/install/configure.html

    set -e

    builddir=$TMPDIR/build

    mkdir -p $builddir

    mkdir -p $out
    mkdir -p $source

    bash_program=$(which bash)

    # $src/configure honors CONFIG_SHELL
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
    LDFLAGS="$LDFLAGS -Wl,-rpath,$glibc/lib"
    export LDFLAGS

    # NOTE: nxfs-gcc automatically inserts flags
    #
    #          -Wl,--rpath=$NXFS_SYSROOT_DIR/lib -Wl,--dynamic-linker=$NXFS_SYSROOT_DIR/lib/ld-linux-x86-64.so.2
    #       But still need them explictly here
    #
    #
    # this builds:
    (cd $builddir && $bash_program $src/libstdc++-v3/configure --prefix=$out --with-gxx-include-dir=$out/$target_tuple/include/c++/$version --host=$target_tuple --build=$target_tuple --disable-nls --disable-multilib --enable-libstdcxx-pch CC=nxfs-gcc CXX=nxfs-g++ CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS")

    (cd $builddir && make SHELL=$CONFIG_SHELL)
    (cd $builddir && make install SHELL=$CONFIG_SHELL)

    (cd $src && (tar cf - . | tar xf - -C $source))
    '';

  buildInputs = [ gcc
                  binutils
                  bison
                  flex
                  texinfo
                  m4
                  gnumake
                  gawk
                  gnugrep
                  gnused
                  gnutar
                  findutils
                  diffutils
                  coreutils
                  bash
                  which ];
}
