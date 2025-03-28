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
  #                gnused      :: derivation
  #                findutils   :: derivation
  #                diffutils   :: derivation
  #              }
  nxfsenv-3,
} :

let
  version = "3.11";
in

nxfsenv.mkDerivation {
  name         = "nxfs-gnugrep-3";
  version      = version;

  src          = builtins.fetchTarball { name = "grep-${version}-source";
                                         url = "https://ftp.gnu.org/gnu/grep/grep-${version}.tar.xz";
                                         sha256 = "0pm0zpzmmy6lq5ii03y1nqr1sdjalnwp69i5c926c9dm03v7v0bv"; };

  buildPhase=''
    set -e

    builddir=$TMPDIR

    bash_program=$bash/bin/bash

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$bash_program"

    (cd $builddir && $bash_program $src/configure --prefix=$out CFLAGS= LDFLAGS="-Wl,-enable-new-dtags")

    (cd $builddir && make SHELL=$CONFIG_SHELL)
    (cd $builddir && make install SHELL=$CONFIG_SHELL)
  '';

  buildInputs = [
    nxfsenv.gcc_wrapper
    nxfsenv.binutils
    nxfsenv.gawk
    nxfsenv.gnumake
    nxfsenv.gnugrep
    nxfsenv.gnutar
    nxfsenv-3.gnused
    nxfsenv-3.findutils
    nxfsenv-3.diffutils
    nxfsenv.coreutils
    nxfsenv.bash
    nxfsenv.glibc
  ];
}
