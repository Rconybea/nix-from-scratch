# in nixpkgs/lib/customisation.nix, similar function is lib.callPackageWith
#
# allpkgs   :: attrset
#
allpkgs:

# path      :: path        to some .nix file
#
path:

# overrides :: attrset   overrides; apply on top of allpkgs
#
overrides:

let
  # fn :: attrset -> derivation
  fn = import path;

in

# builtins.functionArgs()    = formal parameters to fn
# builtins.insertsectAttrs() = take from allpkgs just fn's arguments
#
fn ((builtins.intersectAttrs (builtins.functionArgs fn) allpkgs) // overrides)
