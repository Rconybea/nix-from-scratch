# nixpkgs/default.nix
#  -> nixpkgs/pkgs/top-level/impure.nix
#     (does config.nix stuff; overlays.nix stuff),
#     assembles vars
#       {localSystem, crossSystem, config, overlays, crossOverlays, stdenvStages}
#     stdenvStages: "function booting final package set for a specific standard
#                    environment"
#     -> nixpkgs/pkgs/top-level/default.nix
#

{
  pkgs ? import <nixpkgs> {}
}:

with pkgs;

let
  nixfromscratch_packages = rec {
    inherit pkgs;
  };
in
nixfromscratch_packages
