let
  # attrset (kitchensink, mostly filled with derivations)
  nxfspkgs = import <nxfspkgs>;

  bootstrap = nxfspkgs.nxfs-bootstrap-1;
in

let
  # allPkgs :: attrset
  allPkgs = nxfspkgs // localpkgs;

  # like a nixpkgs stdenv, but for nix-from-scratch bootstrap stage 1
  nxfsenv = {
    # mkDerivation :: attrs -> derivation
    mkDerivation = nxfspkgs.nxfs-autotools allPkgs;
    # bash :: derivation
    bash = bootstrap.nxfs-bash-1; #nxfspkgs.nxfs-bash-1;
    # toolchain :: derivation
    toolchain = bootstrap.nxfs-toolchain-1;
    # sysroot :: derivation
    sysroot = bootstrap.nxfs-sysroot-1;
    # nxfs-defs :: { target_tuple :: string }
    nxfs-defs = bootstrap.nxfs-defs;
  };

  # path      :: path         to some .nix file
  # overrides :: attrset      overides relative to allPkgs
  callPackage = path: overrides:
    let
      # fn :: attrset -> derivation
      fn = import path;
    in
      # builtins.functionArgs() = formal parameters to fn
      # builtins.insertsectAttrs() = take from allPkgs just fn's arguments
      #
      fn ((builtins.intersectAttrs (builtins.functionArgs fn) allPkgs) // overrides);

  # localpkgs :: attrset
  localpkgs = with nxfspkgs; {
    nxfsenv = nxfsenv;

    # hello-b-1 :: derivation
    hello-b-1 = callPackage ./hello-b-1/default.nix { };
  };

in
localpkgs
