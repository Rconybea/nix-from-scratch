{
  # nxfsenv :: derivation
  nxfsenv,
  # gmp :: derivation
  gmp
} :

let
  version = "4.2.1";
in

nxfsenv.mkDerivation {
  name         = "nxfs-mpfr-3";

  gmp          = gmp;

  src          = builtins.fetchTarball { name = "mpfr-${version}-source";
                                         url = "https://ftp.gnu.org/gnu/mpfr/mpfr-${version}.tar.xz";
                                         sha256 = "1irpgc9aqyhgkwqk7cvib1dgr5v5hf4m0vaaknssyfpkjmab9ydq"; };

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

    # 2. substitute nix-store path-to-bash for /bin/sh.
    #
    #
    chmod -R +w $src2
    sed -i "1s:#!.*/bin/sh:#!$bash_program:" $src2/tools/get_patches.sh
    chmod -R -w $src2

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$bash_program"

    (cd $builddir && $bash_program $src2/configure --prefix=$out --with-gmp=$gmp CC=nxfs-gcc CFLAGS= LDFLAGS="-Wl,-enable-new-dtags")

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
                  nxfsenv.findutils
                  nxfsenv.diffutils
                  nxfsenv.coreutils
                  nxfsenv.shell
  ];
}
