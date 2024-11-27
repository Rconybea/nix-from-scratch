let
  bash = import ../../bootstrap/nxfs-bash-0;
in

derivation {
  name = "nix-pills-ex1";
  builder = "${bash}/bin/bash";
  buildInputs = [ ];
  system = builtins.currentSystem;
}
