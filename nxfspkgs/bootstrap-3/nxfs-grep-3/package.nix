{
  # nxfsenv   :: attrset
  nxfsenv,
} :

let
  version = "3.11";
in

nxfsenv.mkDerivation {
  name         = "nxfs-gnugrep-3";
  version      = version;

  src          = builtins.fetchTarball { name = "grep-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/grep/grep-${version}.tar.xz";
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
    nxfsenv.gnused
    nxfsenv.findutils
    nxfsenv.diffutils
    nxfsenv.coreutils
    nxfsenv.shell
    nxfsenv.glibc
  ];
}
