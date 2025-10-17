{
  # everything in nxfsenv is from bootstrap-2/
  #  nxfsenv :: derivation
  nxfsenv,

  # binutils-wrapper :: derivation
  binutils-wrapper,

  # nixify-gcc-source :: attrset -> derivation
  nixify-gcc-source,

  # mpc :: derivation
  mpc,
  # mpfr :: derivation
  mpfr,
  # gmp :: derivation
  gmp,
  # isl :: derivation
  isl,

  # glibc :: derivation   --  glibc + linux headers
  glibc,
} :

let
  nxfs-defs = nxfsenv.nxfs-defs;

  # nxfs-nixified-gcc-source :: derivation
  nxfs-nixified-gcc-source = nixify-gcc-source {
    bash      = nxfsenv.bash;
    file      = nxfsenv.file;
    findutils = nxfsenv.findutils;
    sed       = nxfsenv.gnused;
    grep      = nxfsenv.gnugrep;
    tar       = nxfsenv.gnutar;
    coreutils = nxfsenv.coreutils;
    nxfs-defs = nxfs-defs;
  };
in

let
  gcc          = nxfsenv.gcc;
  bison        = nxfsenv.bison;
  flex         = nxfsenv.flex;
  texinfo      = nxfsenv.texinfo;
  m4           = nxfsenv.m4;
  binutils     = nxfsenv.binutils;
  gnumake      = nxfsenv.gnumake;
  gawk         = nxfsenv.gawk;
  gnutar       = nxfsenv.gnutar;
  gnugrep      = nxfsenv.gnugrep;
  gnused       = nxfsenv.gnused;
  findutils    = nxfsenv.findutils;
  diffutils    = nxfsenv.diffutils;
  coreutils    = nxfsenv.coreutils;
  bash         = nxfsenv.shell;
  which        = nxfsenv.which;
  glibc        = nxfsenv.glibc;

  version = nxfs-nixified-gcc-source.version;
in

nxfsenv.mkDerivation {
  name         = "nxfs-gcc-x1-3";
  version      = version;

  system       = builtins.currentSystem;

  inherit mpc mpfr gmp isl flex glibc;

  src          = nxfs-nixified-gcc-source;

  outputs      = [ "out" "source" ];

  target_tuple = nxfs-defs.target_tuple;

  buildPhase = ''
    # See also
    #   https://gcc.gnu.org/install/configure.html

    set -euo pipefail

    echo "nxfs-g++=$(which nxfs-g++)"
    echo "glibc=$glibc"

    src2=$src
    builddir=$TMPDIR/build

    mkdir -p $builddir

    mkdir -p $out
    mkdir -p $out/$target_tuple/lib
    mkdir $source

    bash_program=$(which bash)

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
    LDFLAGS="$LDFLAGS -L$flex/lib -L$mpc/lib -L$mpfr/lib -L$gmp/lib -L$isl/lib"
    LDFLAGS="$LDFLAGS -Wl,-rpath,$mpc/lib -Wl,-rpath,$mpfr/lib -Wl,-rpath,$gmp/lib"
    LDFLAGS="$LDFLAGS -Wl,-rpath,$isl/lib -Wl,-rpath,$glibc/lib"
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
    ln -s $glibc/lib/crti.o $out/$target_tuple/lib/crti.o
    ln -s $glibc/lib/crtn.o $out/$target_tuple/lib/crtn.o
    ln -s $glibc/lib/libc.so $out/$target_tuple/lib/libc.so
    ln -s $glibc/lib/libc.so.6 $out/$target_tuple/lib/libc.so.6
    # omitting: Mcrt1.o, Scrt1.o, crt1.o gcrt1.o grcrt1.o ld-linux-x86-64.so.2
    #           libBrokenLocale.so libBrokenLocale.so.1
    #           libanl.so libanl.so.1 etc.

    # here we tell nxfs-gcc to use native prepared-within-nix glibc (from stage 3)
    # instead of glibc baked into nxfs-gcc (from stage 2)
    #
    export NXFS_SYSROOT_DIR=$glibc

    # NOTE: nxfs-gcc automatically inserts flags
    #
    #          -Wl,--rpath=$NXFS_SYSROOT_DIR/lib -Wl,--dynamic-linker=$NXFS_SYSROOT_DIR/lib/ld-linux-x86-64.so.2
    #       We still need them explictly here
    #
    (cd $builddir \
      && $bash_program $src2/configure --prefix=$out --disable-bootstrap \
                       --with-native-system-header-dir=$glibc/include \
                       --enable-lto --disable-nls --with-mpc=$mpc --with-mpfr=$mpfr \
                       --with-gmp=$gmp --with-isl=$isl \
                       --enable-default-pie --enable-default-ssp \
                       --enable-shared --disable-multilib --disable-threads \
                       --disable-libatomic --disable-libgomp --disable-libquadmath \
                       --disable-libssp --disable-libvtv --disable-libstdcxx \
                       --enable-languages=c,c++ \
                       --with-stage1-ldflags="-B$glibc/lib -Wl,-rpath,$glibc/lib" \
                       --with-boot-ldflags="-B$glibc/lib -Wl,-rpath,$glibc/lib" \
                       CC=nxfs-gcc CXX=nxfs-g++ CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS")

    (cd $builddir && make SHELL=$CONFIG_SHELL)
    (cd $builddir && make install SHELL=$CONFIG_SHELL)

    # gcc build doesn't

    # can now remove the sysroot debris we temporarily put into $out/$target_tuple
    rm $out/$target_tuple/lib/crti.o
    rm $out/$target_tuple/lib/crtn.o
    rm $out/$target_tuple/lib/libc.so
    rm $out/$target_tuple/lib/libc.so.6

    (cd $src2 && (tar cf - . | tar xf - -C $source))
  '';

  buildInputs = [ gcc
                  bison
                  flex
                  texinfo
                  m4
                  binutils-wrapper
                  binutils
                  gnumake
                  gawk
                  gnutar
                  gnugrep
                  gnused
                  findutils
                  diffutils
                  coreutils
                  bash
                  which ];
}
