# nxfsenv :: attrset   nxfs package repository nix-from-scratch/nxfspkgs, possibly extended
#
# Require:
#   nxfsenv.coreutils :: derivation. Suitable version of (probably gnu) coreutils
#                        Expect ${nxfsenv.coreutils}/bin to provide at bare minimum
#                        {mkdir, cp, rm, chmod, nproc}; probably others.
#   nxfsenv.bash      :: derivation. With ${nxfsenv.bash}/bin/bash
#
nxfsenv :

# this function (rest of this file)
#   :: attrset->derivation will be invoked as nxfsenv.mkDerivation
#
# attrs :: attrset   caller attribute substitutions for derivation members
attrs :

let
  bash = nxfsenv.bash;
in

let
  defaultAttrs = {
    builder = "${bash}/bin/bash";
    bash = bash;
    args = [ ./default-builder.sh ];
    setupScript = ./setup.sh;

    # baseInputs :: list(derivation)   elt d[i] passed to builder as nix-store path
    baseInputs = [ nxfsenv.coreutils ];
    # buildInputs :: list(derivation)  elt d[i] passed to builder as nix-store path
    buildInputs = [ ];

    # inputs that should also be preserved for runtime.
    propagatedBuildInputs = [ ];

    system = builtins.currentSystem;
  };
in
derivation (defaultAttrs // attrs)
