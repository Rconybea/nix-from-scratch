{
  # stdenv :: attrset+derivation
  stdenv,
  # m4 :: derivation
  m4,
} :

let
  version = "2.6.4";
in

stdenv.mkDerivation {
  name         = "nxfs-flex-3";
  version      = version;

  src          = builtins.fetchTarball { name = "flex-${version}-source";
                                         url = "https://github.com/westes/flex/releases/download/v${version}/flex-${version}.tar.gz";
                                         sha256 = "05gbq5hklzdfvjjc3hyr98hrm8wkr20ds0y3l7c825va798c04qw"; };

  buildPhase = ''
    set -e

    src2=$TMPDIR/src2
    builddir=$TMPDIR/build

    mkdir -p $src2
    mkdir -p $builddir

    # 1. copy source tree to temporary directory,
    #
    (cd $src && (tar cf - . | tar xf - -C $src2))

    # 2. since we're building in source tree,
    #    will need to be able to write there
    #
    chmod -R +w $src2

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$shell"

    cd $builddir

    CCFLAGS=
    LDFLAGS="-Wl,-enable-new-dtags"

    (cd $builddir && $shell $src2/configure --prefix=$out)

    make SHELL=$CONFIG_SHELL

    make install SHELL=$CONFIG_SHELL
  '';

  buildInputs = [ m4
    #nxfsenv.perl
  ];
}
