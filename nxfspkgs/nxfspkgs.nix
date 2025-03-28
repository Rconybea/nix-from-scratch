# similar in spirit to nixpkgs/top-level/default.nix
#
{
  nxfspkgs ? import <nxfspkgs> {}

,  # allow configuration attributes (if we ever have them) to be passed in as argument.
  config ? {}

, # overlays for extension
  overlays ? []

, # accumulate unexpected args
  ...
} @
# args :: attrset
  args :

let
  # autotools eventually evaluates to derivation with defaults for:
  #   .builder .args .baseInputs .buildInputs .system
  # default builder requires pkgs.bash
  #
  # nxfs-autotools :: pkgs -> attrs -> derivation
  nxfs-autotools = import ./build-support/autotools;

  # TODO: need to callPackage on all these, once they're upgraded for it.
  bootstrap-1 = import ./bootstrap-1;
  bootstrap-2 = import ./bootstrap-2;
  bootstrap-3 = import ./bootstrap-3;
in

let
  # allPkgs :: attrset
  allPkgs = nxfspkgs // envpkgs;

  nxfsenv-3 = {
    # mkDerivation :: attrs -> derivation
    mkDerivation = nxfspkgs.nxfs-autoools allPkgs;
  };

  # envpkgs :: attrset
  envpkgs = {
    # use this with stdenv/default.nix -- after all, we're trying to construct a stdenv
    nxfsenv-prev = nxfsenv-3;
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
in

let
  # TODO: use callPackage on these, so they're overrideable
  coreutils-3    = bootstrap-3.coreutils-3;
  bash-3         = bootstrap-3.bash-3;
  which-3        = bootstrap-3.which-3;
  gcc-wrapper-3  = bootstrap-3.gcc-wrapper-3;
  glibc-stage1-3 = bootstrap-3.glibc-stage1-3;
  nxfsenv-3      = bootstrap-3.nxfsenv-3;
in

let
  mkDerivation-3 = (nxfs-autotools (allPkgs // { nxfsenv = { bash = bash-3; }; }));

  stdenv-nxfs = callPackage ./stdenv { gcc = gcc-wrapper-3;
                                       glibc = glibc-stage1-3;
                                       coreutils = coreutils-3;
                                       bash = bash-3;
                                       which = which-3;
                                       mkDerivation = mkDerivation-3; };
in

{
  nxfs-autotools = nxfs-autotools;

  # pills-example-1..nxfs-bootstrap-1 :: derivation
  pills-example-1       = import ./nix-pills/example1;

  nxfs-bash-0           = import ./bootstrap/nxfs-bash-0;
  nxfs-coreutils-0      = import ./bootstrap/nxfs-coreutils-0;
  nxfs-gnumake-0        = import ./bootstrap/nxfs-gnumake-0;

  nxfs-toolchain-0      = import ./bootstrap/nxfs-toolchain-0;
  nxfs-sysroot-0        = import ./bootstrap/nxfs-sysroot-0;

  nxfs-bootstrap-1      = import ./bootstrap-1;
  nxfs-bootstrap-1-demo = import ./bootstrap-1-demo;

  nxfs-bash-1           = import ./bootstrap-1/nxfs-bash-1;
  nxfs-toolchain-1      = import ./bootstrap-1/nxfs-toolchain-1;
  nxfs-sysroot-1        = import ./bootstrap-1/nxfs-sysroot-1;

  # nxfs-bootstrap-2-demo :: attrset

  # nxfs-gcc-2 :: derivation    gcc, wrapped
  nxfs-bootstrap-2      = import ./bootstrap-2;

  nxfs-gcc-wrapper-2    = import ./bootstrap-2/nxfs-gcc-wrapper-2;
  nxfs-gcc-stage2-2     = import ./bootstrap-2/nxfs-gcc-stage2-2;
  nxfs-bash-2           = import ./bootstrap-2/nxfs-bash-2;
  nxfs-binutils-2       = import ./bootstrap-2/nxfs-binutils-2;
  nxfs-coreutils-2      = import ./bootstrap-2/nxfs-coreutils-2;
  nxfs-bootstrap-2-demo = import ./bootstrap-2-demo;

  nxfs-defs             = import ./bootstrap-1/nxfs-defs.nix;

  stdenv-nxfs           = stdenv-nxfs;
}
