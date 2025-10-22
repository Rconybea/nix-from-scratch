{
  # stdenv :: attrset+derivation
  stdenv,
  # perl :: derivation
  perl,
  # stageid :: string  - "2" for stage2, "3" for stage3 etc.
  stageid,
} :

let
  version = "6.7";
in

stdenv.mkDerivation {
  name         = "nxfs-texinfo-${stageid}";
  version      = version;

  src          = builtins.fetchTarball { name = "texinfo-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/texinfo/texinfo-${version}.tar.xz";
                                         sha256 = "0bgzsh574c3qh0s5mbq7iyrd5zfh3x431719yzch7jjg28kidm6r"; };

  buildPhase = ''
    set -e

    src2=$TMPDIR/src2
    # perl builds in source tree
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

    (cd $builddir && $shell $src2/configure --prefix=$out)

    make SHELL=$CONFIG_SHELL

    make install SHELL=$CONFIG_SHELL
  '';

  buildInputs = [ perl ];
}
