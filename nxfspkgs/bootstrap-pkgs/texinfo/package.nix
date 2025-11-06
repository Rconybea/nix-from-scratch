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
  # stageid :: string  - "2" for stage2, "3" for stage3 etc.
  stageid,
} :

let
  version = "6.7";
in

stdenv.mkDerivation {
  name         = "nxfs-texinfo-${stageid}";
  version      = version;

  src          = fetchurl { name = "texinfo-${version}-source.tar.xz";
                            url = "https://ftpmirror.gnu.org/gnu/texinfo/texinfo-${version}.tar.xz";
                            hash = "sha256-mIQDwVQtFa0ERgC5CZl7owebEOAyJMYRiBF/NnawLKo=";
                            #sha256 = "0bgzsh574c3qh0s5mbq7iyrd5zfh3x431719yzch7jjg28kidm6r";
                          };

  buildPhase = ''
    set -e

    sourceDir=$(pwd)
    #src2=$TMPDIR/src2
    # perl builds in source tree
    builddir=$sourceDir

    ## 1. copy source tree to temporary directory,
    ##
    #(cd $src && (tar cf - . | tar xf - -C $src2))
    #
    ## 2. since we're building in source tree,
    ##    will need to be able to write there
    ##
    #chmod -R +w $src2

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$shell"

    cd $builddir

    CCFLAGS=
    LDFLAGS="-Wl,-enable-new-dtags"

    (cd $builddir && $CONFIG_SHELL $sourceDir/configure --prefix=$out)

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)

    # verify something runs!
    $out/bin/makeinfo --version
  '';

  buildInputs = [ perl ];
}
