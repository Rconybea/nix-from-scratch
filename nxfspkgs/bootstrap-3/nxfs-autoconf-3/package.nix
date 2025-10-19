{
  # stdenv :: attrset+derivation
  stdenv,
  # perl :: derivation
  perl,
  # m4 :: derivation
  m4,
} :

let
  version = "2.72";
in

stdenv.mkDerivation {
  name         = "nxfs-autoconf-3";

  src          = builtins.fetchTarball { name = "autoconf-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/autoconf/autoconf-${version}.tar.xz";
                                         sha256 = "1r3922ja9g5ziinpqxgfcc51jhrxvjqnrmc5054jgskylflxc1fp"; };

  buildPhase = ''
    set -e

    src2=$TMPDIR/src2
    builddir=$src2

    mkdir -p $src2

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

    # -e: stop questions after config.sh
    # -s: silent mode
    #
    # removing -Dcpp=nxfs-gcc (why did we need this)
    #
    (cd $builddir && $shell $src2/configure --prefix=$out)

    make SHELL=$CONFIG_SHELL

    make install SHELL=$CONFIG_SHELL
    '';

  buildInputs = [ perl m4 ];
}
