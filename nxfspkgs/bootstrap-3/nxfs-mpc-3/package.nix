{
  # nxfsenv :: derivation
  nxfsenv,
  # mpfr :: derivation
  mpfr,
  # gmp :: derivation
  gmp
} :

let
  version = "1.3.1";
in

nxfsenv.mkDerivation {
  name         = "nxfs-mpc-3";
  version      = version;

  mpfr         = mpfr;
  gmp          = gmp;

  src          = builtins.fetchTarball { name = "mpc-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/mpc/mpc-${version}.tar.gz";
                                         sha256 = "1b6layaybj039fajx8dpy2zvcfy7s02y3y4lficz16vac0fsd0jk";
                                       };

  buildPhase = ''
    set -e

    src2=$TMPDIR/src2
    builddir=$TMPDIR/build

    mkdir -p $src2
    mkdir -p $builddir

    bash_program=$bash/bin/bash

    # 1. copy source tree to temporary directory,
    #
    (cd $src && (tar cf - . | tar xf - -C $src2))

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$bash_program"

    (cd $builddir && $bash_program $src2/configure --prefix=$out --with-mpfr=$mpfr --with-gmp=$gmp CC=nxfs-gcc CFLAGS= LDFLAGS="-Wl,-enable-new-dtags")

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)

'';

  buildInputs = [ nxfsenv.gcc_wrapper
                  nxfsenv.binutils
                  nxfsenv.m4
                  nxfsenv.gnumake
                  nxfsenv.gawk
                  nxfsenv.gnutar
                  nxfsenv.gnugrep
                  nxfsenv.gnused
                  nxfsenv.file
                  nxfsenv.findutils
                  nxfsenv.diffutils
                  nxfsenv.coreutils
                  nxfsenv.shell ];
}
