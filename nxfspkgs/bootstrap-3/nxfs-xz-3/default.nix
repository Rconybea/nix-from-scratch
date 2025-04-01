{
  # nxfsenv-3 :: derivation-set
  nxfsenv-3,
} :

let
  version = "5.6.2";

in

nxfsenv-3.mkDerivation {
  name         = "nxfs-xz-3";

  src          = builtins.fetchTarball { name = "xz-${version}-source";
                                         url = "https://github.com/tukaani-project/xz/releases/download/v${version}/xz-${version}.tar.gz";
                                         sha256 = "0574z4hj557c81v9kzpmvsck9d8nhv246631m6yq9pf4py5cchnw"; };

  buildPhase = ''
    src2=$TMPDIR/src2
    builddir=$TMPDIR/build

    mkdir -p $src2
    mkdir -p $builddir

    (cd $src && (tar cf - . | tar xf - -C $src2))

    chmod -R +w $src2

    bash_program=$bash/bin/bash

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$bash_program"

    LDFLAGS="-Wl,-rpath,$out/lib -Wl,-enable-new-dtags"

    (cd $builddir && $bash_program $src2/configure --prefix=$out CFLAGS= LDFLAGS="$LDFLAGS" --enable-shared)
    (cd $builddir && make SHELL=$CONFIG_SHELL)
    (cd $builddir && make install SHELL=$CONFIG_SHELL)

  '';

  buildInputs = [
    nxfsenv-3.gcc
    nxfsenv-3.binutils
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
