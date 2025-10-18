# effort to get reasonable stdenv-like derivation+attrset for bootstrap.
# separate evolution from nixpkgs stdenv

# config
{ config,
  ... }
:

{
  name,

  # stagepkgs.shell
  # stagepkgs.coreutils
  #
  stagepkgs
}
:

let
  stdenv-derivation = derivation {
    inherit name;
    system = builtins.currentSystem;
  };

  stdenv-here = let
    shell     = stagepkgs.shell;
    coreutils = stagepkgs.coreutils;
  in
    stdenv-derivation //
    rec {
      system = stdenv-derivation.system;

      mkDerivation = (import ../make-derivation/make-derivation.nix)
        {
          config = config;
          stdenv = stdenv-here;
        }

in
stdenv
