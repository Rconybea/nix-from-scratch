{
  nxfsenv
} :

let
  version = "5.2.32";
in

nxfsenv.mkDerivation {
  name         = "nxfs-bash-2";

  system       = builtins.currentSystem;

  inherit (nxfsenv) coreutils gnumake gawk ncurses findutils diffutils;
  bash         = nxfsenv.shell;
  tar          = nxfsenv.gnutar;
  grep         = nxfsenv.gnugrep;
  sed          = nxfsenv.gnused;

  gcc_wrapper  = nxfsenv.toolchain;
  toolchain    = nxfsenv.toolchain.toolchain;

  builder      = "${nxfsenv.shell}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "bash-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/bash/bash-${version}.tar.gz";
                                         sha256 = "1bhqakwia1zpnq9kgpn7kxsgvgh5b8nysanki0j2m7v7im4yjcvp"; };
}
