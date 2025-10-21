{
  # stdenv :: attrset+derivation
  stdenv,
  # stageid :: string -- "2" for stage2, "3" for stage3
  stageid,
} :

let
  version = "1.4.19";
in

stdenv.mkDerivation {
  name         = "nxfs-m4-${stageid}";
  version      = version;

  src          = builtins.fetchTarball { name = "m4-${version}-source";
                                         url = "https://mirror.csclub.uwaterloo.ca/gnu/m4/m4-${version}.tar.gz";
                                         sha256 = "02xz8gal0fdc4gzjwyiy1557q31xcpg896yc0y6kd8s5jbynvdmf"; };

  m4_patch    = ./m4-patch.sh;

  buildPhase = ''
    src2=$TMPDIR/src2
    builddir=$TMPDIR/build

    mkdir -p $src2
    mkdir -p $builddir

    shell_program=$shell

    # 1. copy source tree to temporary directory,
    #
    (cd $src && (tar cf - . | tar xf - -C $src2))

    # 2. substitute nix-store path-to-bash for /bin/sh.
    #
    #
    chmod -R +w $src2

    (cd $src2 && $shell_program $m4_patch)

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$shell_program"

    (cd $builddir && $shell_program $src2/configure --prefix=$out CFLAGS= LDFLAGS="-Wl,-enable-new-dtags")

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)
    '';

  buildInputs = [ ];
}
