{
  # stdenv :: attrset+derivation
  stdenv,
} :

let
  version = "3.0.4";
in

stdenv.mkDerivation {
  name         = "nxfs-gperf-3";
  version      = version;

  src          = builtins.fetchTarball { name = "gperf-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/gperf/gperf-${version}.tar.gz";
                                         sha256 = "12pqgvxmyckqv1b5qhi80qmwkvpvr604w7qckbn1dfkykl96rdgb"; };

  buildPhase = ''
    set -e

    src2=$TMPDIR/src2
    builddir=$TMPDIR/build

    mkdir -p $src2
    mkdir -p $builddir

    shell_program=$shell

    # 1. copy source tree to temporary directory,
    #
    (cd $src && (tar cf - . | tar xf - -C $src2))

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$shell_program"

    (cd $builddir && $shell_program $src2/configure --prefix=$out CC=nxfs-gcc CC_FOR_BUILD=nxfs-gcc CFLAGS= LDFLAGS="-Wl,-enable-new-dtags")

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)
'';

  buildInputs = [ ];
}
