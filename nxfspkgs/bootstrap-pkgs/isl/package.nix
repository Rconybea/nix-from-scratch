{
  # stdenv :: attrset+derivation
  stdenv,
  # fetchurl :: {url|urls,
  #              hash|sha256|sha512|sha1|md5,
  #              name,
  #              curlOpts|curlOptsList,
  #              postFetch, downloadToTemp,
  #              impureEnvVars, meta, passthru, preferLocalBuild} -> derivation
  fetchurl,
  # gmp :: derivation
  gmp,
  # stageid :: string   -- "2" for stage2 etc.
  stageid,
} :

let
  version = "0.24";
in

stdenv.mkDerivation {
  name         = "nxfs-isl-${stageid}";
  version      = version;

  gmp          = gmp;

  src          = builtins.fetchTarball { name = "isl-${version}-source.tar.bz2";
                                         url = "https://gcc.gnu.org/pub/gcc/infrastructure/isl-${version}.tar.bz2";
                                         sha256 = "sha256:05rkpcwxm1cq0pp10vzkaadppyqylkx79p306js2xm869pibjfl9";
                                       };

  buildPhase = ''
    set -e

    echo "NIX_CFLAGS_COMPILE=$NIX_CFLAGS_COMPILE"
    echo "NIX_LDFLAGS=$NIX_LDFLAGS"

    sourceDir=$(pwd)
    #src2=$TMPDIR/src2
    builddir=$TMPDIR/build

    #mkdir -p $src2
    mkdir -p $builddir

    ## 1. copy source tree to temporary directory,
    ##
    #(cd $src && (tar cf - . | tar xf - -C $src2))
    #
    ## $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$shell"

    (cd $builddir && $CONFIG_SHELL $sourceDir/configure --prefix=$out --with-gmp=$gmp CC=nxfs-gcc CPPFLAGS="-I$gmp/include" CFLAGS="$NIX_CFLAGS_COMPILE" LDFLAGS="$NIX_LDFLAGS -Wl,-enable-new-dtags")

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)

'';

  buildInputs = [ gmp ];
}
