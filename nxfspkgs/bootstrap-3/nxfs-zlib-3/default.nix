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
} :

let
  version = "1.3.1";
in

nxfsenv.mkDerivation {
  name         = "nxfs-zlib-3";

  system       = builtins.currentSystem;

  src          = builtins.fetchTarball { name = "zlib-${version}-source";
                                         url = "https://zlib.net/fossils/zlib-${version}.tar.gz";
                                         sha256 = "1xx5zcp66gfjsxrads0gkfk6wxif64x3i1k0czmqcif8bk43rik9"; };

  # TODO: postprocess to add -Wl,-rpath to zlib.pc

  buildPhase = ''
    set -e

    src2=$TMPDIR/src2
    builddir=$TMPDIR/build

    mkdir -p $src2
    mkdir -p $builddir

    # this might get us past the build.
    # Won't work for invoking `locate`, because location here will
    # be readonly downstream
    #
    #mkdir -p $out/var/lib/locate

    bash_program=$bash/bin/bash

    # 1. copy source tree to temporary directory,
    #
    (cd $src && (tar cf - . | tar xf - -C $src2))

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$bash_program"

    (cd $builddir && export CC=nxfs-gcc && export CFLAGS= && export LDFLAGS="-Wl,-enable-new-dtags" && bash $src2/configure --prefix=$out)

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)
    '';

  buildInputs = [ nxfsenv.gcc_wrapper
                  nxfsenv.binutils
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
