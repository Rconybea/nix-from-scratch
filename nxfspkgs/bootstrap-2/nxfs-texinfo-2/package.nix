{
  # nxfsenv :: attrset
  nxfsenv
} :

let
  version = "6.7";

in

nxfsenv.mkDerivation {
  name         = "nxfs-texinfo-2";

  system       = builtins.currentSystem;

  inherit (nxfsenv) autoconf m4 perl file coreutils gnumake gawk findutils diffutils;
  bash         = nxfsenv.shell;
  tar          = nxfsenv.gnutar;
  grep         = nxfsenv.gnugrep;
  sed          = nxfsenv.gnused;
  gnused       = nxfsenv.gnused;

  gcc_wrapper  = nxfsenv.toolchain;
  toolchain    = nxfsenv.toolchain.toolchain;

  builder      = "${nxfsenv.shell}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "texinfo-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/texinfo/texinfo-${version}.tar.xz";
                                         sha256 = "0bgzsh574c3qh0s5mbq7iyrd5zfh3x431719yzch7jjg28kidm6r"; };
}
