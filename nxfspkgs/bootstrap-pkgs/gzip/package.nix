{
  # stdenv :: attrset+derivation
  stdenv,
  # stageid :: string  -- "2" for stage2, "3" for stage3
  stageid,
} :

let
  version = "1.13";
in

stdenv.mkDerivation {
  name         = "nxfs-gzip-${stageid}";
  version      = version;

  src          = builtins.fetchTarball { name = "gzip-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/gzip/gzip-${version}.tar.xz";
                                         sha256 = "093w3a12220gzy00qi9zy52mhjlgyyh7kiimsz5xa00fgf81rbp9"; };

  outputs      = [ "out" "source" ];

  buildPhase = ''
    set -e

    builddir=$TMPDIR/build

    mkdir -p $builddir

    mkdir $source

    src2=$source

    shell_program=$shell

    # 1. copy source tree to temporary directory,
    #
    (cd $src && (tar cf - . | tar xf - -C $src2))

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$shell_program"

    (cd $builddir && export CC=nxfs-gcc && export CFLAGS= && export LDFLAGS="-Wl,-enable-new-dtags" && $shell_program $src2/configure --prefix=$out)

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)
'';

  buildInputs = [ ];
}
