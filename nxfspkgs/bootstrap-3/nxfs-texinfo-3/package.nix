{
  nxfsenv,
} :

let
  version = "6.7";
in

nxfsenv.mkDerivation {
  name         = "nxfs-texinfo-3";
  version      = version;

  src          = builtins.fetchTarball { name = "texinfo-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/texinfo/texinfo-${version}.tar.xz";
                                         sha256 = "0bgzsh574c3qh0s5mbq7iyrd5zfh3x431719yzch7jjg28kidm6r"; };

  buildPhase = ''
    set -e

    src2=$TMPDIR/src2
    # perl builds in source tree
    builddir=$src2

    mkdir -p $src2

    # 1. copy source tree to temporary directory,
    #
    (cd $src && (tar cf - . | tar xf - -C $src2))

    # 2. since we're building in source tree,
    #    will need to be able to write there
    #
    chmod -R +w $src2

    bash_program=$bash/bin/bash

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
                  nxfsenv.bison
                  nxfsenv.flex
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
