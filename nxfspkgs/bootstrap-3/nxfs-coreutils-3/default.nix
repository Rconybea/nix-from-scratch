{
  # nxfsenv   :: { mkDerivation :: attrs -> derivation,
  #                gcc-wrapper :: derivation  (also as gcc_wrapper)
  #                binutils    :: derivation
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
  #                gnumake     :: derivation
  #                gawk        :: derivation
  #                bash        :: derivation
  #                gnutar      :: derivation
  #                gnugrep     :: derivation
  #                gnused      :: derivation
  #                findutils   :: derivation
  #                diffutils   :: derivation
  #              }
  nxfsenv-3,
} :

let
  version = "9.5";
in

nxfsenv.mkDerivation {
  name         = "nxfs-coreutils-3";

  src          = builtins.fetchTarball { name = "coreutils-${version}-source";
                                         url = "https://ftp.gnu.org/gnu/coreutils/coreutils-${version}.tar.xz";
                                         sha256 = "0250l3qc7w4l2lx2ws4wqsd2g2g2q0g6w32d9r7d9pgwqmrj2nkh"; };

  buildPhase = ''
    set -e

    src2=$src
    builddir=$TMPDIR/build

    mkdir -p $src2
    mkdir -p $builddir

    bash_program=$bash/bin/bash

    # ----------------------------------------------------------------
    # NOTE: omitting coreutils unicode patch
    #       since we don't need it for bootstrap
    # ----------------------------------------------------------------

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$bash_program"

    (cd $builddir && bash $src2/configure --prefix=$out --enable-install-program=hostname --enable-no-install-program=kill,uptime CC=nxfs-gcc CFLAGS= LDFLAGS="-Wl,-enable-new-dtags")

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)
  '';

  buildInputs = [ nxfsenv.gcc_wrapper
                  nxfsenv.binutils
                  nxfsenv.coreutils
                  nxfsenv-3.gnumake
                  nxfsenv-3.gawk
                  nxfsenv-3.gnutar
                  nxfsenv-3.gnugrep
                  nxfsenv-3.gnused
                  nxfsenv-3.findutils
                  nxfsenv-3.diffutils
                  nxfsenv-3.bash
                  nxfsenv.glibc
                ];
}
