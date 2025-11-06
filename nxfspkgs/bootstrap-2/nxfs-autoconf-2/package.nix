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
  # stageid :: string
  stageid,
} :

let
  name = "nxfs-autoconf-${stageid}";
  version = "2.72";

in

stdenv.mkDerivation {
  name         = name;
  version      = version;

  src = fetchurl { name = "autoconf-${version}-source.tar.xz";
                   url = "https://ftpmirror.gnu.org/gnu/autoconf/autoconf-${version}.tar.xz";
                   sha256 = "1r3922ja9g5ziinpqxgfcc51jhrxvjqnrmc5054jgskylflxc1fp";
                 };

  buildPhase = ''
    sourceDir=$(pwd)

    builddir=$TMPDIR/build

    mkdir -p $builddir

    (cd $builddir && ${stdenv.shell} $sourceDir/configure --prefix=$out CC=nxfs-gcc LDFLAGS="-Wl,-enable-new-dtags")
    (cd $builddir && make SHELL=${stdenv.shell})
    (cd $builddir && make install SHELL=${stdenv.shell})

    $out/bin/autoconf --version
  '';

  buildInputs = [ ];

#  system       = builtins.currentSystem;
#  inherit (nxfsenv) m4 perl coreutils gnumake gawk findutils diffutils;
#  bash         = nxfsenv.shell;
#  tar          = nxfsenv.gnutar;
#  grep         = nxfsenv.gnugrep;
#  sed          = nxfsenv.gnused;
#  gnused       = nxfsenv.gnused;
#  gcc_wrapper  = nxfsenv.toolchain;
#  toolchain    = nxfsenv.toolchain.toolchain;
#  builder      = "${nxfsenv.shell}/bin/bash";
#  args         = [ ./builder.sh ];
#
#  src          = builtins.fetchTarball { name = "autoconf-${version}-source";
#                                         url = "https://ftpmirror.gnu.org/gnu/autoconf/autoconf-${version}.tar.xz";
#                                         sha256 = "1r3922ja9g5ziinpqxgfcc51jhrxvjqnrmc5054jgskylflxc1fp"; };
}
