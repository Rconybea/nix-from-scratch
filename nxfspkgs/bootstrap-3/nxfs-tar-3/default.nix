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
  #                bzip2       :: derivation
  #                gnugrep     :: derivation
  #                gnused      :: derivation
  #                findutils   :: derivation
  #                diffutils   :: derivation
  #              }
  nxfsenv-3,
} :

let
  version = "1.35";
in

nxfsenv.mkDerivation {
  name         = "nxfs-tar-3";
  version      = version;

  src          = builtins.fetchTarball { name = "tar-${version}-source";
                                         url = "https://ftp.gnu.org/gnu/tar/tar-${version}.tar.xz";
                                         sha256 = "0cmdg6gq9v04631lfb98xg45la1b0y9r5wyspn97ri11krdlyfqz"; };

  bzip2 = nxfsenv-3.bzip2;

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


    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$bash_program"

    #CFLAGS="$bzip2/include"
    LDFLAGS="-Wl,-enable-new-dtags"

    (cd $builddir && $bash_program $src2/configure --prefix=$out CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS")
    (cd $builddir && make SHELL=$CONFIG_SHELL)
    (cd $builddir && make install SHELL=$CONFIG_SHELL)
  '';

  buildInputs = [
    nxfsenv.gcc_wrapper
    nxfsenv.binutils
    nxfsenv.gawk
    nxfsenv.gnumake
    nxfsenv.gnutar
    nxfsenv-3.gnugrep
    nxfsenv-3.gnused
    nxfsenv-3.findutils
    nxfsenv-3.diffutils
    nxfsenv.coreutils
    nxfsenv.bash
    nxfsenv.glibc
  ];

  propagatedBuildInputs = [
    nxfsenv-3.bzip2
  ];
}
