{
  # stdenv :: attrset+derivation
  stdenv,
  # autocon :: derivation
  autoconf,
  # perl :: derivation
  perl,
} :

let
  version = "1.16.5";
in

stdenv.mkDerivation {
  name         = "nxfs-automake-3";

  src          = builtins.fetchTarball { name = "automake-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/automake/automake-${version}.tar.xz";
                                         sha256 = "0pac10hgw6r4kbafdbxg7gpb503fq9a9a31r5hvdh95nd2pcngv0"; };

# NOTE: build problems with 1.17
#
#  src          = builtins.fetchTarball { name = "automake-1.17-source";
#                                         url = "https://ftpmirror.gnu.org/gnu/automake/automake-1.17.tar.xz";
#                                         sha256 = "1nwgz937zikw5avzhvvzf57i917pq0q05s73wqr28abwqxa3bll8"; };

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

    (cd $builddir && $shell $src2/configure --prefix=$out CC=nxfs-gcc CXX=nxfs-g++ LDFLAGS="$LDFLAGS")

    (cd $builddir && sed -i -e 's:#! */bin/sh:#! '$shell':' ./pre-inst-env)

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)
  '';

  buildInputs = [
                  perl
 #                 nxfsenv.m4
                ];

  propagatedBuildInputs = [ autoconf ];
}
