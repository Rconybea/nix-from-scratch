let
  bash = import ../../bootstrap/nxfs-bash-0;
in

derivation {
  name = "nix-pills-ex1c";
  builder = "${bash}/bin/bash";
  args = [ ./builder.sh ];
  buildInputs = [ ];
  system = builtins.currentSystem;
}
