# nxfsenv :: attrset   nxfs package repository nix-from-scratch/nxfspkgs, possibly extended
#
# Require:
#   nxfsenv.initialPath :: [ derivation ].
#                        add /bin directories from these derivations to PATH
#   nxfsenv.coreutils :: derivation. Suitable version of (probably gnu) coreutils
#                        Expect ${nxfsenv.coreutils}/bin to provide at bare minimum
#                        {mkdir, cp, rm, chmod, nproc}; probably others.
#   nxfsenv.bash      :: derivation. With ${nxfsenv.bash}/bin/bash
#
nxfsenv :

let
  # mkDerivation :: attrs -> derivation
  #
  mkDerivation =
    # this function (rest of this file)
    #   :: attrset->derivation will be invoked as nxfsenv.mkDerivation
    #
    # attrs :: attrset   caller attribute substitutions for derivation members
    attrs :

    let
      bash = nxfsenv.shell;
    in

      let
        defaultAttrs = {
          builder = "${bash}/bin/bash";

          shell = nxfsenv.shell;
          # TODO: atavism, remove
          bash = nxfsenv.shell;

          args = [ ./default-builder.sh ];
          setupScript = ./setup.sh;

          # baseInputs :: list(derivation)   elt d[i] passed to builder as nix-store path
          baseInputs = [ nxfsenv.coreutils ];
          # buildInputs :: list(derivation)  elt d[i] passed to builder as nix-store path
          buildInputs = [ ];
          # inputs that should also be preserved for runtime.
          propagatedBuildInputs = [ ];

          inherit (nxfsenv) initialPath;

          system = builtins.currentSystem;
        };
      in
        derivation (defaultAttrs // attrs);
in
mkDerivation
