{
  # autotools :: pkgs -> attrset -> derivation
  autotools = import ./autotools;
  # callPackage :: xxx
  callPackage = import ./callPackage.nix;
}
