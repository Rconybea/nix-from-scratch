{
  # nxfsenv :: attrset
  nxfsenv,
} :

let
  version = "9.5";
in

nxfsenv.mkDerivation {
  name         = "nxfs-coreutils-3";

  src          = builtins.fetchTarball { name = "coreutils-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/coreutils/coreutils-${version}.tar.xz";
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
                  nxfsenv.gnumake
                  nxfsenv.gawk
                  nxfsenv.gnutar
                  nxfsenv.gnugrep
                  nxfsenv.gnused
                  nxfsenv.findutils
                  nxfsenv.diffutils
                  nxfsenv.bash
                  nxfsenv.glibc
                ];
}
