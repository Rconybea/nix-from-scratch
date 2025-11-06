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
  # flex :: derivation
  flex,
  # m4 :: derivation
  m4,
  # stageid :: string  - "2" for stage2, "3" for stage3 etc.
  stageid,
} :

let
  version = "3.8.2";
in

stdenv.mkDerivation {
  name         = "nxfs-bison-${stageid}";
  version      = version;

  src          = fetchurl { name = "bison-${version}-source.tar.xz";
                            url = "https://ftpmirror.gnu.org/gnu/bison/bison-${version}.tar.xz";
                            hash = "sha256-m7oCFMz38QecXVkhAEUie89hlRmEDr+oDNOEnP9aW/I=";
                            #sha256 = "0w18vf97c1kddc52ljb2x82rsn9k3mffz3acqybhcjfl2l6apn59";
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
    ## 2. since we're building in source tree,
    ##    will need to be able to write there
    ##
    #chmod -R +w $src2

    sed -i "1s:#!.*/bin/sh:#!${stdenv.shell}:" $sourceDir/build-aux/move-if-change

    #chmod -R -w $src2

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="${stdenv.shell}"

    cd $builddir

    CCFLAGS=
    LDFLAGS="-Wl,-enable-new-dtags"

    (cd $builddir && $CONFIG_SHELL $sourceDir/configure --prefix=$out)

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)
  '';

  buildInputs = [ perl flex m4 ];
}
