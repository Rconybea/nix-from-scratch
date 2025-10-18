{
  # nxfsenv :: derivation
  nxfsenv,
  # gmp :: derivation
  gmp
} :

let
  version = "0.24";
in

nxfsenv.mkDerivation {
  name         = "nxfs-isl-3";
  version      = version;

  gmp          = gmp;

  src          = builtins.fetchTarball { name = "isl-${version}-source";
                                         url = "https://gcc.gnu.org/pub/gcc/infrastructure/isl-${version}.tar.bz2";
                                         sha256 = "sha256:05rkpcwxm1cq0pp10vzkaadppyqylkx79p306js2xm869pibjfl9";
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

    (cd $builddir && $bash_program $src2/configure --prefix=$out --with-gmp=$gmp CC=nxfs-gcc CPPFLAGS="-I$gmp/include" CFLAGS= LDFLAGS="-L$gmp/lib -Wl,-rpath,$gmp/lib -Wl,-enable-new-dtags")

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
