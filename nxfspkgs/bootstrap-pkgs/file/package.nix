{
  # stdenv :: attrset+derivation
  stdenv,
  # stageid :: string  -- "2" for stage2, "3" for stage3
  stageid,
} :

let
  version = "5.44";
in

stdenv.mkDerivation {
  name         = "nxfs-file-${stageid}";
  version      = version;

  src          = builtins.fetchTarball { name = "file-${version}-source";
                                         url = "https://astron.com/pub/file/file-${version}.tar.gz";
                                         sha256 = "1zzm575fk4lsg8h0jk6jhcyk13w1qxm3ykssyqrmzq7wiginj9a3"; };

  buildPhase = ''
    set -e

    src2=$src
    #src2=$TMPDIR/src2
    builddir=$TMPDIR/build

    mkdir -p $src2
    mkdir -p $builddir

    shell_program=$shell

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$shell_program"

    (cd $builddir && $shell_program $src2/configure --prefix=$out --enable-install-program=hostname --enable-no-install-program=kill,uptime CFLAGS= LDFLAGS="-Wl,-enable-new-dtags")

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)
  '';

  buildInputs = [ ];
}
