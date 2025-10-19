{
  # stdenv :: attrset
  stdenv,
} :

let
  version = "3.11";
in

stdenv.mkDerivation {
  name         = "nxfs-gnugrep-3";
  version      = version;

  src          = builtins.fetchTarball { name = "grep-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/grep/grep-${version}.tar.xz";
                                         sha256 = "0pm0zpzmmy6lq5ii03y1nqr1sdjalnwp69i5c926c9dm03v7v0bv"; };

  buildPhase=''
    set -e

    builddir=$TMPDIR

    shell_program=$shell

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$shell_program"

    (cd $builddir && $shell_program $src/configure --prefix=$out CFLAGS= LDFLAGS="-Wl,-enable-new-dtags")

    (cd $builddir && make SHELL=$CONFIG_SHELL)
    (cd $builddir && make install SHELL=$CONFIG_SHELL)
  '';

  buildInputs = [];
}
