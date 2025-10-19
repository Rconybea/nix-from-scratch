{
  # stdenv :: attrset+derivation
  stdenv,
  # perl :: derivation
  perl,
  # pkgconf :: derivation
  pkgconf,
} :

let
  version = "4.4.36";
in

stdenv.mkDerivation {
  name         = "nxfs-libxcrypt-3";
  version      = version;

  src = builtins.fetchTarball {
    name = "libxcrypt-${version}-source";
    url = "https://github.com/besser82/libxcrypt/releases/download/v${version}/libxcrypt-${version}.tar.xz";
    sha256 = "1iflya5d4ndgjg720p40x19c1j2g72zn64al8f74x3h4bnapqx1d";
  };

  buildPhase = ''
    #!/bin/bash

    set -euo pipefail

    src2=$TMPDIR/src2
    builddir=$TMPDIR/build

    mkdir -p $src2
    mkdir -p $builddir

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
    sed -i -e "s:/bin/sh:$shell:g" $src2/build-aux/scripts/move-if-change

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$shell"

    (cd $builddir && $shell $src2/configure --prefix=$out --enable-hashes=strong,glibc --disable-werror CC=nxfs-gcc CFLAGS="-std=gnu17" LDFLAGS="-Wl,-enable-new-dtags")

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)
'';

  buildInputs = [
    perl
    pkgconf
  ];
}
