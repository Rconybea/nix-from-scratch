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
  #                m4          :: derivation
  #                perl        :: derivation
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
  nxfsenv-3,
  # libxcrypt :: derivation
  libxcrypt
} :

let
  version = "2.43.1";
in

nxfsenv.mkDerivation {
  name         = "nxfs-binutils-3";
  version      = version;

  src          = builtins.fetchTarball { name = "binutils-${version}-source";
                                         url = "https://sourceware.org/pub/binutils/releases/binutils-${version}.tar.xz";
                                         sha256 = "1z0lq9ia19rw1qk09i3im495s5zll7xivdslabydxl9zlp3wy570"; };

  buildPhase = ''
    set -e

    src2=$TMPDIR/src2
    #builddir=$src2
    builddir=$TMPDIR/build

    mkdir -p $src2
    mkdir -p $builddir

    # 1. copy source tree to temporary directory,
    #
    (cd $src && (tar cf - . | tar xf - -C $src2))

    # 2. since we're modifying source tree,
    #    will need to be able to write there
    #
    chmod -R +w $src2

    bash_program=$bash/bin/bash

    sed -i -e "s:/bin/sh:$bash_program:" $src2/mkinstalldirs

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$bash_program"

    CCFLAGS=
    LDFLAGS="-Wl,-enable-new-dtags"

    # -e: stop questions after config.sh
    # -s: silent mode
    #
    # removing -Dcpp=nxfs-gcc (why did we need this)
    #
    (cd $builddir && $bash_program $src2/configure --prefix=$out)

    (cd $builddir && make SHELL=$CONFIG_SHELL MAKEINFO=true)

    (cd $builddir && make install SHELL=$CONFIG_SHELL MAKEINFO=true)
    '';

  buildInputs = [ libxcrypt
                  nxfsenv.gcc_wrapper
                  nxfsenv.binutils
                  nxfsenv-3.perl
                  nxfsenv-3.pkgconf
                  nxfsenv-3.gnumake
                  nxfsenv-3.gawk
                  nxfsenv-3.gnutar
                  nxfsenv-3.gnugrep
                  nxfsenv-3.gnused
                  nxfsenv-3.findutils
                  nxfsenv-3.diffutils
                  nxfsenv-3.coreutils
                  nxfsenv-3.bash
                ];
}
