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
  # autocon :: derivation
  autoconf,
  # perl :: derivation
  perl,
  # stageid :: string
  stageid,
} :

let
  version = "1.16.5";
in

stdenv.mkDerivation {
  name         = "nxfs-automake-${stageid}";

  src          = fetchurl { name = "automake-${version}-source.tar.xz";
                            url = "https://ftpmirror.gnu.org/gnu/automake/automake-${version}.tar.xz";
                            hash = "sha256-8B1YzW2dd/vcqetLvV6tGYgij9tz1veiAfX41rEYtGk=";
                            #sha256 = "0pac10hgw6r4kbafdbxg7gpb503fq9a9a31r5hvdh95nd2pcngv0";
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

    ## 2. since we're building in source tree,
    ##    will need to be able to write there
    ##
    #chmod -R +w $src2

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="${stdenv.shell}"

    cd $builddir

    CCFLAGS=
    LDFLAGS="-Wl,-enable-new-dtags"

    (cd $builddir && $shell $sourceDir/configure --prefix=$out CC=nxfs-gcc CXX=nxfs-g++ LDFLAGS="$LDFLAGS")

    (cd $builddir && sed -i -e 's:#! */bin/sh:#! '$CONFIG_SHELL':' ./pre-inst-env)

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)
  '';

  buildInputs = [
                  perl
                ];

  propagatedBuildInputs = [ autoconf ];
}
