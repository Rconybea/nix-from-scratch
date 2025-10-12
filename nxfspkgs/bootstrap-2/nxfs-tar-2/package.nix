{
  nxfsenv
} :

let
  version = "1.35";
in

nxfsenv.mkDerivation {
  name         = "nxfs-gnutar-2";

  system       = builtins.currentSystem;

  inherit (nxfsenv) coreutils gnumake gawk gnutar findutils diffutils;
  bash         = nxfsenv.shell;
  grep         = nxfsenv.gnugrep;
  sed          = nxfsenv.gnused;
  gcc_wrapper  = nxfsenv.toolchain;
  toolchain    = nxfsenv.toolchain.toolchain;

  builder      = "${nxfsenv.shell}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "tar-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/tar/tar-${version}.tar.xz";
                                         sha256 = "0cmdg6gq9v04631lfb98xg45la1b0y9r5wyspn97ri11krdlyfqz"; };
}
