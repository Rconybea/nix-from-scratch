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
  # stageid :: string
  stageid,
} :

let
  version = "4.2.1";
in

stdenv.mkDerivation {
  name         = "nxfs-mpfr-${stageid}";

  gmp          = gmp;

  src          = fetchurl { name = "mpfr-${version}-source.tar.xz";
                            url = "https://ftpmirror.gnu.org/gnu/mpfr/mpfr-${version}.tar.xz";
                            hash = "sha256-J3gHNTpnJpeJlpRa8T5Sgp46vXqaW3+yeTiU4Y8fy7I=";
                            #sha256 = "1irpgc9aqyhgkwqk7cvib1dgr5v5hf4m0vaaknssyfpkjmab9ydq";
                          };

  buildPhase = ''
    set -e

    sourceDir=$(pwd)
    #src2=$TMPDIR/src2
    builddir=$TMPDIR/build

    #mkdir -p $src2
    mkdir -p $builddir

    ## 1. copy source tree to temporary directory,
    ##
    #(cd $src && (tar cf - . | tar xf - -C $src2))
    #
    ## 2. substitute nix-store path-to-bash for /bin/sh.
    ##
    ##
    #chmod -R +w $src2

    sed -i "1s:#!.*/bin/sh:#!${stdenv.shell}:" $sourceDir/tools/get_patches.sh

    #chmod -R -w $src2

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="${stdenv.shell}"

    (cd $builddir && $CONFIG_SHELL $sourceDir/configure --prefix=$out --with-gmp=$gmp CC=nxfs-gcc CFLAGS= LDFLAGS="-Wl,-enable-new-dtags")

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)
'';

  buildInputs = [ gmp ];
}
