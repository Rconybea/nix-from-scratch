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
  nxfsenv-3,
} :

let
  version = "2.3.0";
in

nxfsenv.mkDerivation {
  name         = "nxfs-pkgconf-3";
  version      = version;

  src          = builtins.fetchTarball { name = "pkgconf-${version}-source";
                                         url = "https://distfiles.ariadne.space/pkgconf/pkgconf-${version}.tar.xz";
                                         sha256 = "1xrwjysmjkf4q9ygbzq5crhyckpqn18mi208m6l9hk731mf5vvk6"; };

  outputs = [ "out" "source" ];

  buildPhase = ''
    set -e

    builddir=$TMPDIR/build

    mkdir -p $builddir

    mkdir $source

    src2=$source

    bash_program=$bash/bin/bash

    # 1. copy source tree to temporary directory,
    #
    (cd $src && (tar cf - . | tar xf - -C $src2))

    # ----------------------------------------------------------------
    # NOTE: omitting coreutils unicode patch
    #       since we don't need it for bootstrap
    # ----------------------------------------------------------------

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$bash_program"

    (cd $builddir && export CC=nxfs-gcc && export CFLAGS= && export LDFLAGS="-Wl,-enable-new-dtags" && bash $src2/configure --prefix=$out)

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)

    (cd $out/bin && ln -s pkgconf pkg-config)
'';

  buildInputs = [ nxfsenv.gcc_wrapper
                  nxfsenv.binutils
                  nxfsenv-3.coreutils
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
