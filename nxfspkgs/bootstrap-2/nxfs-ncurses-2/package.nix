{
  nxfsenv
} :

let
  version = "6.5";
in

nxfsenv.mkDerivation {
  name         = "nxfs-ncurses-2";

  system       = builtins.currentSystem;

  inherit (nxfsenv) gzip coreutils gnumake gawk findutils diffutils;
  bash         = nxfsenv.shell;
  tar          = nxfsenv.gnutar;
  grep         = nxfsenv.gnugrep;
  sed          = nxfsenv.gnused;
  gcc_wrapper  = nxfsenv.toolchain;
  toolchain    = nxfsenv.toolchain.toolchain;

  builder      = "${nxfsenv.shell}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "ncurses-${version}-source";
                                         url = "https://invisible-mirror.net/archives/ncurses/ncurses-${version}.tar.gz";
                                         sha256 = "0qnh977jny6mmw045if1imrdlf8n0nsbv79nxxlx9sgai4mpkn0n"; };
}
