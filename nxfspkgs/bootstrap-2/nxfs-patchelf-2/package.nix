{
  # nxfsenv :: attrset
  nxfsenv
} :

let
  version = "0.18.0";
in

nxfsenv.mkDerivation {
  name         = "nxfs-patchelf-2";

  system       = builtins.currentSystem;

  inherit (nxfsenv) coreutils gnumake gawk gnused findutils diffutils;
  bash         = nxfsenv.shell;
  tar          = nxfsenv.gnutar;
  grep         = nxfsenv.gnugrep;
  sed          = nxfsenv.gnused;

  gcc_wrapper  = nxfsenv.toolchain;
  toolchain    = nxfsenv.toolchain.toolchain;

  builder      = "${nxfsenv.shell}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "patchelf-${version}-source";
                                         url = "https://github.com/NixOS/patchelf/releases/download/${version}/patchelf-${version}.tar.gz";
                                         sha256 = "0s328cmgrbhsc344q323dhg70h8lf8532ywjf8jwjirxq6a5h06w"; };
}
