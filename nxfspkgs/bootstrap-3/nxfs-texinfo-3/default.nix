{
  # nxfsenv   :: { mkDerivation :: attrs -> derivation,
  #                gcc-wrapper :: derivation  (also as gcc_wrapper)
  #                binutils    :: derivation
  #                perl        :: derivation
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
  #                perl        :: derivation
  #                m4          :: derivation
  #                flex        :: derivation
  #                pkgconf     :: derivation
  #                coreutils   :: derivation
  #                gnumake     :: derivation
  #                gawk        :: derivation
  #                bash        :: derivation
  #                gnutar      :: derivation
  #                gnugrep     :: derivation
  #                gnused      :: derivation
  #                findutils   :: derivation
  #                diffutils   :: derivation
  #              }
  nxfsenv-3
} :

let
  version = "6.7";
in

nxfsenv.mkDerivation {
  name         = "nxfs-texinfo-3";
  version      = version;

  src          = builtins.fetchTarball { name = "texinfo-${version}-source";
                                         url = "https://ftp.gnu.org/gnu/texinfo/texinfo-${version}.tar.xz";
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
                  nxfsenv-3.perl
                  nxfsenv-3.m4
                  nxfsenv-3.bison
                  nxfsenv-3.flex
                  nxfsenv-3.gnumake
                  nxfsenv-3.gawk
                  nxfsenv-3.gnutar
                  nxfsenv-3.gnugrep
                  nxfsenv-3.gnused
                  nxfsenv-3.findutils
                  nxfsenv-3.diffutils
                  nxfsenv-3.coreutils
                  nxfsenv-3.bash ];
}
