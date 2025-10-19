{
  # stdenv :: attrset+derivation
  stdenv,
  # m4 :: derivation
  m4
} :

let
  version = "6.3.0";
in

stdenv.mkDerivation {
  name         = "nxfs-gmp-3";
  version      = version;

  src          = builtins.fetchTarball { name = "gmp-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/gmp/gmp-${version}.tar.xz";
                                         sha256 = "1kc3dy4jxand0y118yb9715g9xy1fnzqgkwxy02vd57y2fhg2pcw"; };

  buildPhase = ''
    set -e

    src2=$TMPDIR/src2
    builddir=$TMPDIR/build

    mkdir -p $src2
    mkdir -p $builddir

    # 1. copy source tree to temporary directory,
    #
    (cd $src && (tar cf - . | tar xf - -C $src2))

    # 2. substitute nix-store path-to-bash for /bin/sh.
    #
    chmod -R +w $src2
    sed -i "1s:#!.*/bin/sh:#!$shell:" $src2/mpn/m4-ccas
    chmod -R -w $src2

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$shell"

    (cd $builddir && $shell $src2/configure --prefix=$out CC=nxfs-gcc CFLAGS= LDFLAGS="-Wl,-enable-new-dtags")

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)
    '';

  buildInputs = [ m4
    #nxfsenv.file
  ];
}
