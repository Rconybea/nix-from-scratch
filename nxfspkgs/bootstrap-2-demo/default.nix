let
  # nxfspkgs :: attrset (kitchen sink, mostly derivations)
  nxfspkgs = import <nxfspkgs>;

  bootstrap = nxfspkgs.nxfs-bootstrap-2;
  bootstrap-1 = nxfspkgs.nxfs-bootstrap-1;
in

let
  # allPkgs :: attrset
  allPkgs = nxfspkgs // localpkgs;

  # like a nixpkgs stdenv, but for nix-from-scratch bootstrap stage 2
  nxfsenv = {
    # mkDerivation  :: attrs -> derivation
    mkDerivation = nxfspkgs.nxfs-autotools allPkgs;
    # gcc           :: derivation
    gcc-wrapper  = bootstrap.nxfs-gcc-wrapper-2;
    # gcc-unwrapped :: derivation
    gcc          = bootstrap.nxfs-gcc-stage2-2;
    # bash         :: derivation
    bash         = bootstrap.nxfs-bash-2;
    # binutils     :: derivation
    binutils     = bootstrap.nxfs-binutils-2;
    # gawk         :: derivation
    gawk         = bootstrap.nxfs-gawk-2;
    # sed          :: derivation
    gnused       = bootstrap.nxfs-sed-2;
    # coreutils    :: derivation
    coreutils    = bootstrap.nxfs-coreutils-2;
    # sysroot      :: derivation
    sysroot      = bootstrap-1.nxfs-sysroot-1;
    # nxfs-defs    :: { target_tuple :: string }
    nxfs-defs    = bootstrap.nxfs-defs;
  };

  # path      :: path         to some .nix file
  # overrides :: attrset      overides relative to allPkgs
  callPackage = path: overrides:
    let
      # fn :: attrset -> derivation
      fn = import path;
    in
      # builtins.functionArgs()    = formal parameters to fn
      # builtins.insertsectAttrs() = take from allPkgs just fn's arguments
      #
      fn ((builtins.intersectAttrs (builtins.functionArgs fn) allPkgs) // overrides);

  # localpkgs :: attrset
  localpkgs = with nxfspkgs; {
    nxfsenv = nxfsenv;

    # awk-2       :: derivation
    awk-2 = callPackage ./awk-2 {};
    # hello-cxx-2 :: derivation
    hello-cxx-2 = callPackage ./hello-cxx-2 {};
  };

in
localpkgs
