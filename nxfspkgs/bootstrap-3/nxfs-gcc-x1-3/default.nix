{
  # everything in nxfsenv is from bootstrap-2/
  #  nxfsenv :: { mkDerivation, ... }
  nxfsenv,
  #  nxfsenv-3 :: { coreutils, ... }
  nxfsenv-3,

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

  # sysroot :: derivation   --  for linux headers
  toolchain,
} :

let
  nxfs-defs = nxfsenv-3.nxfs-defs;

  # nxfs-nixified-gcc-source :: derivation
  nxfs-nixified-gcc-source = nixify-gcc-source {
    bash      = nxfsenv-3.bash;
    file      = nxfsenv-3.file;
    findutils = nxfsenv-3.findutils;
    sed       = nxfsenv-3.gnused;
    grep      = nxfsenv-3.gnugrep;
    tar       = nxfsenv-3.gnutar;
    coreutils = nxfsenv-3.coreutils;
    nxfs-defs = nxfs-defs;
  };
in

let
  gcc          = nxfsenv-3.gcc;
  bison        = nxfsenv-3.bison;
  flex         = nxfsenv-3.flex;
  texinfo      = nxfsenv-3.texinfo;
  m4           = nxfsenv-3.m4;
  binutils     = nxfsenv-3.binutils;
  gnumake      = nxfsenv-3.gnumake;
  gawk         = nxfsenv-3.gawk;
  gnutar       = nxfsenv-3.gnutar;
  gnugrep      = nxfsenv-3.gnugrep;
  gnused       = nxfsenv-3.gnused;
  findutils    = nxfsenv-3.findutils;
  diffutils    = nxfsenv-3.diffutils;
  coreutils    = nxfsenv-3.coreutils;
  bash         = nxfsenv-3.bash;
  which        = nxfsenv-3.which;
  glibc        = nxfsenv-3.glibc;

  version = nxfs-nixified-gcc-source.version;
in

nxfsenv.mkDerivation {
  name         = "nxfs-gcc-x1-3";
  version      = version;

  system       = builtins.currentSystem;

  inherit mpc mpfr gmp flex glibc;
  inherit toolchain;  # for system headers

  src          = nxfs-nixified-gcc-source;

  outputs      = [ "out" "source" ];

  target_tuple = nxfs-defs.target_tuple;

  buildPhase = ''
    # See also
    #   https://gcc.gnu.org/install/configure.html

    set -euo pipefail

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

    # do we need $toolchain/lib ?
    LDFLAGS="-B$glibc/lib -B$toolchain/lib"
    LDFLAGS="$LDFLAGS -L$flex/lib -L$mpc/lib -L$mpfr/lib -L$gmp/lib"
    LDFLAGS="$LDFLAGS -Wl,-rpath,$mpc/lib -Wl,-rpath,$mpfr/lib -Wl,-rpath,$gmp/lib"
    LDFLAGS="$LDFLAGS -Wl,-rpath,$glibc/lib -Wl,-rpath,$toolchain/lib"
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

    # glibc:
    #  - built by crosstools-ng gcc (adopted into nix store)
    #  - entirely from within nix, see nxfs-glibc-stage1-2
    # here we tell nxfs-gcc to use this glibc instead of crosstools-ng glibc
    #
    #export NXFS_SYSROOT_DIR=$glibc

    # NOTE: nxfs-gcc automatically inserts flags
    #
    #          -Wl,--rpath=$NXFS_SYSROOT_DIR/lib -Wl,--dynamic-linker=$NXFS_SYSROOT_DIR/lib/ld-linux-x86-64.so.2
    #       We still need them explictly here
    #
    (cd $builddir && $bash_program $src2/configure --prefix=$out --host=$target_tuple --build=$target_tuple --disable-bootstrap --with-native-system-header-dir=$toolchain/include --enable-lto --disable-nls --with-mpc=$mpc --with-mpfr=$mpfr --with-gmp=$gmp --enable-default-pie --enable-default-ssp --enable-shared --disable-multilib --disable-threads --disable-libatomic --disable-libgomp --disable-libquadmath --disable-libssp --disable-libvtv --disable-libstdcxx --enable-languages=c,c++ --with-stage1-ldflags="-B$glibc/lib -Wl,-rpath,$glibc/lib -B$toolchain/lib -Wl,-rpath,$toolchain/lib" --with-boot-ldflags="-B$glibc/lib -Wl,-rpath,$glibc/lib -B$toolchain/lib -Wl,-rpath,$toolchain/lib" CC=nxfs-gcc CXX=nxfs-g++ CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS")

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
