{
  # stdenv :: attrset+derivation
  stdenv,
  # bzip2 :: derivation
  bzip2,
  # stageid :: string  -- "2" for stage2, "3" for stage3
  stageid,
} :

let
  version = "1.35";
in

stdenv.mkDerivation {
  name         = "nxfs-gnutar-${stageid}";
  version      = version;

  src          = builtins.fetchTarball { name = "tar-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/tar/tar-${version}.tar.xz";
                                         sha256 = "0cmdg6gq9v04631lfb98xg45la1b0y9r5wyspn97ri11krdlyfqz"; };

#  bzip2 = nxfsenv.bzip2;

  buildPhase = ''
    set -e

    builddir=$TMPDIR/build

    mkdir -p $builddir

    shell_program=$shell

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$shell_program"

    LDFLAGS="-Wl,-enable-new-dtags"

    (cd $builddir && $shell_program $src/configure --prefix=$out CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS")
    (cd $builddir && make SHELL=$CONFIG_SHELL)
    (cd $builddir && make install SHELL=$CONFIG_SHELL)
  '';

  buildInputs = [ ];

  propagatedBuildInputs = [
    bzip2
  ];
}
