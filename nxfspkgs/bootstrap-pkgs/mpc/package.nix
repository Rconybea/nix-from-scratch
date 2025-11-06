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
  # mpfr :: derivation
  mpfr,
  # gmp :: derivation
  gmp,
  # stageid :: string  -- "2" for stage2, "3" for stage3 etc.
  stageid,
} :

let
  version = "1.3.1";
in

stdenv.mkDerivation {
  name         = "nxfs-mpc-${stageid}";
  version      = version;

  mpfr         = mpfr;
  gmp          = gmp;

  src          = fetchurl { name = "mpc-${version}-source.tar.gz";
                            url = "https://ftpmirror.gnu.org/gnu/mpc/mpc-${version}.tar.gz";
                            hash = "sha256-q2QkkvXPiCt0qgy3MM1BCoHtzb7IlRg86TDnBsHHWbg=";
                            #sha256 = "1b6layaybj039fajx8dpy2zvcfy7s02y3y4lficz16vac0fsd0jk";
                          };

  buildPhase = ''
    #set -e

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

    (cd $builddir && $CONFIG_SHELL $sourceDir/configure --prefix=$out --with-mpfr=$mpfr --with-gmp=$gmp CC=nxfs-gcc CFLAGS= LDFLAGS="-Wl,-enable-new-dtags")

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)

'';

  buildInputs = [];
}
