# nxfspkgs : attrset
nxfspkgs :

let
  # pkg :: attrset -> derivation
  # overrides :: attrset
  #
  callPackageWith = pkg: overrides:
