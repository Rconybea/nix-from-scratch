{
  nxfsenv
} :

let
  version = "3.11";
in

nxfsenv.mkDerivation {
  name         = "nxfs-grep-2";
  system       = builtins.currentSystem;

  inherit (nxfsenv) coreutils gnumake gawk gnutar gnugrep gnused findutils diffutils;
  bash         = nxfsenv.shell;
  gcc_wrapper  = nxfsenv.toolchain;
  toolchain    = nxfsenv.toolchain.toolchain;

  builder      = "${nxfsenv.shell}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "grep-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/grep/grep-${version}.tar.xz";
                                         sha256 = "0pm0zpzmmy6lq5ii03y1nqr1sdjalnwp69i5c926c9dm03v7v0bv"; };
}
