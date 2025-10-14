{
  # nxfsenv   :: attrset
  nxfsenv,
} :

let
  version = "2.3.0";
in

nxfsenv.mkDerivation {
  name         = "nxfs-pkgconf-2";
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

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$bash_program"

    (cd $builddir && export CC=nxfs-gcc && export CFLAGS= && export LDFLAGS="-Wl,-enable-new-dtags" && bash $src2/configure --prefix=$out)

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)

    (cd $out/bin && ln -s pkgconf pkg-config)
'';

  buildInputs = [ nxfsenv.toolchain  # gcc wrapper
                  nxfsenv.toolchain.toolchain  # gcc, binutils, glibc
                  nxfsenv.coreutils
                  nxfsenv.gnumake
                  nxfsenv.gawk
                  nxfsenv.gnutar
                  nxfsenv.gnugrep
                  nxfsenv.gnused
                  nxfsenv.findutils
                  nxfsenv.diffutils
                  nxfsenv.shell
                  #nxfsenv.glibc   # not present in stage2
                ];
}
