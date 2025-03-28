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
} :

let
  version = "4.4.36";
in

nxfsenv.mkDerivation {
  name         = "nxfs-libxcrypt-3";
  version      = version;

  src = builtins.fetchTarball {
    name = "libxcrypt-${version}-source";
    url = "https://github.com/besser82/libxcrypt/releases/download/v${version}/libxcrypt-${version}.tar.xz";
    sha256 = "1iflya5d4ndgjg720p40x19c1j2g72zn64al8f74x3h4bnapqx1d";
  };
#  target_tuple = nxfs-defs.target_tuple;

  buildPhase = ''
    #!/bin/bash

    set -e

    src2=$TMPDIR/src2
    builddir=$TMPDIR/build

    mkdir -p $src2
    mkdir -p $builddir

    bash_program=$bash/bin/bash

    # 1. copy source tree to temporary directory,
    #
    (cd $src && (tar cf - . | tar xf - -C $src2))

    # 2. substitute nix-store path-to-bash for /bin/sh.
    #
    #
    chmod -R +w $src2

    # Must skip:
    #   .m4 and .in files (assume they trigger re-running autoconf)
    #   test/ files
    #
    sed -i -e "s:/bin/sh:$bash_program:g" $src2/build-aux/scripts/move-if-change

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$bash_program"

    # 1.
    # we shouldn't need special compiler/linker instructions,
    # since stage-1 toolchain "knows where it lives"
    #
    # 2.
    # do need to give --host and --build arguments to configure,
    # since we're using a cross compiler.

    (cd $builddir && $bash_program $src2/configure --prefix=$out --enable-hashes=strong,glibc --disable-werror CC=nxfs-gcc CFLAGS="-std=gnu17" LDFLAGS="-Wl,-enable-new-dtags")

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)
'';

  buildInputs = [ nxfsenv.gcc_wrapper
                  nxfsenv.binutils
                  nxfsenv.perl
                  nxfsenv-3.pkgconf
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
