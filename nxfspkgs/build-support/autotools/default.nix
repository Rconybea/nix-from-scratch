
# pkgs  :: attrset   nxfs package repository nix-from-scratch/nxfspkgs, possibly extended
pkgs :

# this function (rest of this file)
#   :: attrset->derivation will be invoked as nxfsenv.mkDerivation
#
# attrs :: attrset   caller attribute substitutions for derivation members
attrs :

let
  nxfsenv = pkgs.nxfsenv;
  bash = nxfsenv.bash;
in

let
  defaultAttrs = {
    builder = "${bash}/bin/bash";
    bash = bash;
    args = [ ./default-builder.sh ];
    setupScript = ./setup.sh;

    # baseInputs :: list(derivation)   elt d[i] passed to builder as nix-store path
    baseInputs = with pkgs; [
      nxfs-bootstrap-1.nxfs-coreutils-1
    ];
    # buildInputs :: list(derivation)  elt d[i] passed to builder as nix-store path
    buildInputs = [ ];
    system = builtins.currentSystem;
  };
in
derivation (defaultAttrs // attrs)
