{
  # stdenv :: attrset+derivation
  stdenv,
} :

let
  version = "0.1";
in

stdenv.mkDerivation {
  name = "nxfs-popen-template";

  inherit version;

  src = ./src;

  buildPhase = ''
    set -e

    mkdir -p $out/src
    cp $src/nxfs_system.c $out/src
    cp $src/nxfs_popen.c $out/src
  '';
}
