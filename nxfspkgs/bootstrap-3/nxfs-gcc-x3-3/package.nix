{
  # everything in nxfsenv is from bootstrap-2/
  #  nxfsenv :: { mkDerivation, ... }
  nxfsenv,
  # binutils-stage1-wrapper-2 :: derivation
  binutils-wrapper,
  # nixify-gcc-source :: attrset -> derivation
  nixify-gcc-source,
  # mpc :: derivation
  mpc,
  # mpfr :: derivation
  mpfr,
  # gmp :: derivation
  gmp,
#  # glibc :: derivation
#  glibc,
  # toolchain :: derivation
  toolchain
} :

let
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

  # nxfs-defs :: attrset
  nxfs-defs = nxfsenv.nxfs-defs;
in

let
  # nxfs-nixified-gcc-source :: derivation
  nxfs-nixified-gcc-source = nixify-gcc-source {
    bash      = bash;
    file      = file;
    findutils = findutils;
    sed       = gnused;
    grep      = gnugrep;
    tar       = gnutar;
    coreutils = coreutils;
    nxfs-defs = nxfs-defs;
  };
in

nxfsenv.mkDerivation {
  name         = "nxfs-gcc-x3-3";
  version      = nxfs-nixified-gcc-source.version;
  system       = builtins.currentSystem;

  inherit glibc;

  toolchain    = toolchain;

  inherit mpc mpfr gmp flex;

  bash         = bash;

  src          = nxfs-nixified-gcc-source;

  target_tuple = nxfs-defs.target_tuple;

  buildPhase = ''
    # See also
    #   https://gcc.gnu.org/install/configure.html

    set -e

    src2=$src
    builddir=$TMPDIR/build

    mkdir -p $builddir
    mkdir -p $out/$target_tuple/lib

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
    ln -s $glibc/lib/crt1.o $out/$target_tuple/lib/crt1.o
    ln -s $glibc/lib/crti.o $out/$target_tuple/lib/crti.o
    ln -s $glibc/lib/crtn.o $out/$target_tuple/lib/crtn.o
    ln -s $glibc/lib/libc.so $out/$target_tuple/lib/libc.so
    ln -s $glibc/lib/libc.so.6 $out/$target_tuple/lib/libc.so.6
    ln -s $glibc/lib/Scrt1.o $out/$target_tuple/lib/Scrt1.o
    # omitting: Mcrt1.o, gcrt1.o grcrt1.o ld-linux-x86-64.so.2
    #           libBrokenLocale.so libBrokenLocale.so.1
    #           libanl.so libanl.so.1 etc.

    # NOTE: nxfs-gcc automatically inserts flags
    #
    #          -Wl,--rpath=$NXFS_SYSROOT_DIR/lib -Wl,--dynamic-linker=$NXFS_SYSROOT_DIR/lib/ld-linux-x86-64.so.2
    #       We still need them explictly here
    #
    (cd $builddir && $bash_program $src2/configure --prefix=$out --disable-bootstrap --with-native-system-header-dir=$toolchain/include --enable-lto --disable-nls --with-mpc=$mpc --with-mpfr=$mpfr --with-gmp=$gmp --enable-default-pie --enable-default-ssp --enable-shared --disable-multilib --enable-threads --enable-libatomic --enable-libgomp --enable-libquadmath --enable-libssp --enable-libvtv --enable-libstdcxx --enable-languages=c,c++ --with-stage1-ldflags="-B$glibc/lib -Wl,-rpath,$glibc/lib -B$toolchain/lib -Wl,-rpath,$toolchain/lib" --with-boot-ldflags="-B$glibc/lib -Wl,-rpath,$glibc/lib -B$toolchain/lib -Wl,-rpath,$toolchain/lib" CC=nxfs-gcc CXX=nxfs-g++ CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS")

    (cd $builddir && make SHELL=$CONFIG_SHELL)
    (cd $builddir && make install SHELL=$CONFIG_SHELL)

    # can now remove the toolchain(sysroot) debris we temporarily put into $out/$target_tuple
    rm $out/$target_tuple/lib/crt1.o
    rm $out/$target_tuple/lib/crti.o
    rm $out/$target_tuple/lib/crtn.o
    rm $out/$target_tuple/lib/libc.so
    rm $out/$target_tuple/lib/libc.so.6
    rm $out/$target_tuple/lib/Scrt1.o
  '';

  # note: will appear in path left-to-right
  buildInputs  = [ bison
                   flex
                   texinfo
                   m4
                   diffutils
                   findutils
                   binutils-wrapper
                   binutils
                   gcc
                   gnumake
                   gawk
                   gnugrep
                   gnused
                   gnutar
                   coreutils
                   bash
                   which
                 ];

} // {
  # experiment
  # ----------
  # Encountered problem with nixpkgs builds-on-top-of-nxfs, where
  # it (specifically stdenv/generic/default.nix, invoked from stdenv2nix-minimal)
  # complains if nixpkgs.patchelf.stdenv.cc.cc doesn't advertise itself as coming
  # from bootstrapFiles.
  #
  # See:
  # - assertion (isBuiltByBootstrapFilesCompiler (prevStage).patchelf)
  #   in nixpkgs/pkgs/stdenv/linux/default.nix
  # - isBuiltByBootstrapFilesCompiler defined in nixpkgs/pkgs/stdenv/linux/default.nix
  #
  # Try setting this passthru, see if that unwedges
  #
  passthru.isFromBootstrapFiles = true;
}
