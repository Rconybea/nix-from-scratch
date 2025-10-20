{
  # stdenv :: attrset+derivation
  stdenv,
  # stageid :: string  -- "2" for stage2, "3" for stage3
  stageid,
} :

let
  version = "6.5";
in

stdenv.mkDerivation {
  name         = "nxfs-ncurses-${stageid}";
  version      = version;

  src          = builtins.fetchTarball { name = "ncurses-${version}-source";
                                         url = "https://invisible-mirror.net/archives/ncurses/ncurses-${version}.tar.gz";
                                         sha256 = "0qnh977jny6mmw045if1imrdlf8n0nsbv79nxxlx9sgai4mpkn0n"; };

  buildPhase = ''
    set -euo pipefail

    builddir=$TMPDIR/build

    mkdir -p $builddir

    shell_program=$shell

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$shell_program"

    LDFLAGS="-Wl,-enable-new-dtags"

    (cd $builddir && $shell_program $src/configure --prefix=$out --with-shared --without-normal --without-debug --with-cxx-shared --enable-pc-files CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS")
    (cd $builddir && make SHELL=$CONFIG_SHELL)
    (cd $builddir && make TIC_PATH=./progrs/tic install SHELL=$CONFIG_SHELL)
    sed -e 's/^#if.*XOPEN.*$/#if 1/' -i  $out/include/ncursesw/curses.h

    (cd $out/lib && ln -sv libncursesw.so libncurses.so)
    (cd $out/lib && ln -sfv libncurses.so libcurses.so)
    (cd $out/lib && ln -sv libncurses.so libtinfo.so)
  '';

  buildInputs = [ ];
}
