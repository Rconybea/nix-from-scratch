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
  # perl :: derivation
  perl,
  # m4 :: derivation
  m4,
  # stageid :: string -- "2" for stage2, "3" for stage3 etc.
  stageid,
} :

let
  version = "2.72";
in

stdenv.mkDerivation {
  name         = "nxfs-autoconf-${stageid}";

  src          = fetchurl { name = "autoconf-${version}-source.tar.xz";
                            url = "https://ftpmirror.gnu.org/gnu/autoconf/autoconf-${version}.tar.xz";
                            hash = "sha256-uohcExlXjWyU1G6bDc60AUyq/iSQ5Deg28o/JwoiP1o="; };

  buildPhase = ''
    set -e

    sourceDir=$(pwd)
    builddir=$sourceDir

    ## 1. copy source tree to temporary directory,
    ##
    #(cd $src && (tar cf - . | tar xf - -C $src2))

    ## 2. since we're building in source tree,
    ##    will need to be able to write there
    ##
    #chmod -R +w $src2

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="${stdenv.shell}"

    cd $builddir

    CCFLAGS=
    LDFLAGS="-Wl,-enable-new-dtags"

    # -e: stop questions after config.sh
    # -s: silent mode
    #
    # removing -Dcpp=nxfs-gcc (why did we need this)
    #
    (cd $builddir && $shell $sourceDir/configure --prefix=$out)

    make SHELL=$CONFIG_SHELL

    make install SHELL=$CONFIG_SHELL
    '';

  buildInputs = [ perl m4 ];
}
