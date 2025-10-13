{
  # nxfsenv :: attrset
  nxfsenv
} :

let
  version = "3.8.2";

in

nxfsenv.mkDerivation {
  name         = "nxfs-bison-2";
  system       = builtins.currentSystem;

  inherit (nxfsenv) flex m4 coreutils gnumake gawk findutils diffutils;
  bash         = nxfsenv.shell;
  tar          = nxfsenv.gnutar;
  grep         = nxfsenv.gnugrep;
  sed          = nxfsenv.gnused;

  gcc_wrapper  = nxfsenv.toolchain;
  toolchain    = nxfsenv.toolchain.toolchain;

  builder      = "${nxfsenv.shell}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "bison-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/bison/bison-${version}.tar.xz";
                                         sha256 = "0w18vf97c1kddc52ljb2x82rsn9k3mffz3acqybhcjfl2l6apn59"; };
}
