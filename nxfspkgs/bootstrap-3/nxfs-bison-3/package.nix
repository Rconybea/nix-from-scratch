{
  # nxfsenv :: derivation
  nxfsenv,
} :

let
  version = "3.8.2";
in

nxfsenv.mkDerivation {
  name         = "nxfs-bison-3";
  version      = version;

  src          = builtins.fetchTarball { name = "bison-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/bison/bison-${version}.tar.xz";
                                         sha256 = "0w18vf97c1kddc52ljb2x82rsn9k3mffz3acqybhcjfl2l6apn59"; };
  buildPhase = ''
    set -e

    src2=$TMPDIR/src2
    builddir=$TMPDIR/build

    mkdir -p $src2
    mkdir -p $builddir

    # 1. copy source tree to temporary directory,
    #
    (cd $src && (tar cf - . | tar xf - -C $src2))

    bash_program=$bash/bin/bash

    # 2. since we're building in source tree,
    #    will need to be able to write there
    #
    chmod -R +w $src2
    sed -i "1s:#!.*/bin/sh:#!$bash_program:" $src2/build-aux/move-if-change
    chmod -R -w $src2

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$bash_program"

    cd $builddir

    CCFLAGS=
    LDFLAGS="-Wl,-enable-new-dtags"

    (cd $builddir && $bash_program $src2/configure --prefix=$out)

    make SHELL=$CONFIG_SHELL

    make install SHELL=$CONFIG_SHELL
  '';

  buildInputs = [ nxfsenv.gcc_wrapper
                  nxfsenv.binutils
                  nxfsenv.perl
                  nxfsenv.m4
                  nxfsenv.flex
                  nxfsenv.file
                  nxfsenv.gnumake
                  nxfsenv.gawk
                  nxfsenv.gnutar
                  nxfsenv.gnugrep
                  nxfsenv.gnused
                  nxfsenv.findutils
                  nxfsenv.diffutils
                  nxfsenv.coreutils
                  nxfsenv.shell ];
}
