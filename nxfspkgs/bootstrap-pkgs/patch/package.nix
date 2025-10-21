{
  # stdenv :: attrset+derivation
  stdenv,
  # stageid :: string   -- "2" for stage2, "3" for stage3
  stageid,
} :

let
  version = "2.7.6";
in

stdenv.mkDerivation {
  name         = "nxfs-patch-${stageid}";
  version      = version;

  src          = builtins.fetchTarball { name = "patch-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/patch/patch-${version}.tar.xz";
                                         sha256 = "1yiy0xq1ha193yga0canc9ijw4hbd92c93l7ksqlhmzsn2yph39n"; };

  buildPhase =
    ''
    set -euo pipefail

    src2=$src
    builddir=$TMPDIR/build

    mkdir -p $src2
    mkdir -p $builddir

    shell_program=$shell

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$shell_program"

    (cd $builddir && $shell_program $src2/configure --prefix=$out CC=nxfs-gcc CFLAGS= LDFLAGS="-Wl,-enable-new-dtags")

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)
    '';

  buildInputs = [ ];
}
