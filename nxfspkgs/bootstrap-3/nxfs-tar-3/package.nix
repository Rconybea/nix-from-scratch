{
  # nxfsenv   :: attrset
  nxfsenv
} :

let
  version = "1.35";
in

nxfsenv.mkDerivation {
  name         = "nxfs-gnutar-3";
  version      = version;

  src          = builtins.fetchTarball { name = "tar-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/tar/tar-${version}.tar.xz";
                                         sha256 = "0cmdg6gq9v04631lfb98xg45la1b0y9r5wyspn97ri11krdlyfqz"; };

  bzip2 = nxfsenv.bzip2;

  buildPhase = ''
    set -e

    builddir=$TMPDIR/build

    mkdir -p $builddir

    bash_program=$bash/bin/bash

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$bash_program"

    LDFLAGS="-Wl,-enable-new-dtags"

    (cd $builddir && $bash_program $src/configure --prefix=$out CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS")
    (cd $builddir && make SHELL=$CONFIG_SHELL)
    (cd $builddir && make install SHELL=$CONFIG_SHELL)
  '';

  buildInputs = [
    nxfsenv.gcc_wrapper
    nxfsenv.binutils
    nxfsenv.gawk
    nxfsenv.gnumake
    nxfsenv.gnutar
    nxfsenv.gnugrep
    nxfsenv.gnused
    nxfsenv.findutils
    nxfsenv.diffutils
    nxfsenv.coreutils
    nxfsenv.shell
    nxfsenv.glibc
  ];

  propagatedBuildInputs = [
    nxfsenv.bzip2
  ];
}
