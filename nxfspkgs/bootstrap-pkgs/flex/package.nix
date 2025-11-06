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
  version = "2.6.4";
in

stdenv.mkDerivation {
  name         = "nxfs-flex-${stageid}";
  version      = version;

  src          = builtins.fetchTarball { name = "flex-${version}-source.tar.gz";
                                         url = "https://github.com/westes/flex/releases/download/v${version}/flex-${version}.tar.gz";
                                         sha256 = "05gbq5hklzdfvjjc3hyr98hrm8wkr20ds0y3l7c825va798c04qw";
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
    #(cd $src && (tar cf - . | tar xf - -C $src2))N
    #
    ## 2. since we're building in source tree,
    ##    will need to be able to write there
    ##
    #chmod -R +w $src2

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="${stdenv.shell}"

    cd $builddir

    CCFLAGS=
    LDFLAGS="-Wl,-enable-new-dtags"

    (cd $builddir && $shell $sourceDir/configure --prefix=$out)

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)
  '';

  buildInputs = [ m4 ];
}
