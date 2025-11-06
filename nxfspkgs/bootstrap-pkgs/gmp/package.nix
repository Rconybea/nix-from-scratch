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
  # m4 :: derivation
  m4,
  # stageid :: string
  stageid,
} :

let
  version = "6.3.0";
in

stdenv.mkDerivation {
  name         = "nxfs-gmp-${stageid}";
  version      = version;

  src          = builtins.fetchTarball { name = "gmp-${version}-source.tar.xz";
                                         url = "https://ftpmirror.gnu.org/gnu/gmp/gmp-${version}.tar.xz";
                                         sha256 = "1kc3dy4jxand0y118yb9715g9xy1fnzqgkwxy02vd57y2fhg2pcw"; };

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
    #chmod -R +w $src2

    sed -i "1s:#!.*/bin/sh:#!${stdenv.shell}:" $sourceDir/mpn/m4-ccas

    #chmod -R -w $src2

    # $sourceDir/configure honors CONFIG_SHELL
    export CONFIG_SHELL="${stdenv.shell}"

    (cd $builddir && $CONFIG_SHELL $sourceDir/configure --prefix=$out CC=nxfs-gcc CFLAGS= LDFLAGS="-Wl,-enable-new-dtags")

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)
    '';

  buildInputs = [ m4 ];
}
