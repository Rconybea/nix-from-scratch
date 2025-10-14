{
  # nxfsenv :: attrset
  nxfsenv,
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
    set -euo pipefail

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
                  nxfsenv.gnumake
                  nxfsenv.gawk
                  nxfsenv.gnutar
                  nxfsenv.gnugrep
                  nxfsenv.gnused
                  nxfsenv.findutils
                  nxfsenv.diffutils
                  nxfsenv.coreutils
                  nxfsenv.shell
  ];
}
