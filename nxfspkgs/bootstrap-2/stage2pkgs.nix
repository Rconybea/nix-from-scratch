# Similar in spirit to nixpkgs/top-level/default.nix
# Intended to be composable and overrideable.
# See nxfspkgs/{default.nix, impure.nix, nxfspkgs.nix}
#
# Requires:
# 1. nixcpp built + installed. See nix-from-scratch/README)
# 2. stage0 packages built + imported. See nix-from-scratch/nxfspkgs/bootstrap/README
#
# Use:
#   $ nix-build path/to/nix-from/scratch/nxfspkgs -A stage2pkgs.diffutils-2
# or
#   $ export NIX_PATH=path/to/nix-from-scratch:${NIX_PATH}
#   $ nix-build '<nxfspkgs>' -A stage2pkgs.diffutils-2
#
# Major difference from nixpkgs.nix: w'ere carefully nesting
# nxfsenv attribute sets so that bootstrap process is more spelled out.
# See nxfsenv-2-0...
{
  # nxfspkgs: will be the contents of nxfspkgs/nxfspkgs.nix after composing
  # with config choices + overlays.
  # See nix-from-scratch/nxfspkgs/impure.nix
  #
  # The sole reason for pulling in <nxfspkgs> here is for nxfspkgs.stage2pkgs.
  # That refers to this nix function, after applying nxfspkgs configs + overlays.
  #
  # This choice allows user to customize/override stage2pkgs without (for example) cluttering NIX_PATH
  #
  nxfspkgs ? import <nxfspkgs> {}

,  # allow nxfspkgs configuration attributes (if we ever have them) to be passed in as arguments.
  config ? {}

, # overlays for extension
  overlays ? []

, # accumulate unexpected args
  ...
} @
  # args :: attrset
  #
  # alternative way to access all the arguments to this function, e.g:
  # args.nxfspkgs, args.config, args.overlays
  #
  args :

let
  # nxfs-defs :: { system :: string, target_tuple :: string }
  # e.g.
  #   nxfs-defs.system = "x86_64-linux"
  #   nxfs-defs.target_tuple = "x86_64-pc-linux-gnu"
  #
  nxfs-defs = import ../bootstrap-1/nxfs-defs.nix;

  # autotools eventually evaluates to derivation with defaults for:
  #   .builder .args .baseInputs .buildInputs .system
  # default builder requires pkgs.bash
  #
  # nxfs-autotools :: pkgs -> attrs -> derivation
  nxfs-autotools = import ../build-support/autotools;

  # possibly temporary? depends on whether it makes sense to push the stage2pkgs.nix patterns
  # down to stage1.  if so, may be able to retire this.  otherwise definitely keep.
  bootstrap-1 = import ./bootstrap-1;
in

let
  # allPkgs :: attrset
  #
  # provides all packages up to stage-2
  #
  allPkgs = nxfspkgs.stage2pkgs;

  bash-1 = import ../bootstrap-1/nxfs-bash-1/default.nix;

  # initial bootstrap stdenv for stage-2.
  #
  # NOTE: In nixpkgs stdenv pattern is to have attrs
  #         stdenv.cc             : wrapped C,C++ compiler. ${stdenv.cc}/bin/cc, ${stdenv.cc}/bin/c++
  #         stdenv.cc.cc          : unwrapped C,C++ compiler. ${stdenv.cc.cc}/bin/cc, ${stdenv.cc.cc}/bin/c++
  #         stdenv.cc.bintools    : binutils. ${stdenv.cc.bintools}/bin/ld, ${stdenv.cc.bintools}/bin/ar
  #         stdenv.cc.libc        : libc implementation. ${stdenv.cc.libc}/lib
  #         stdenv.cc.libc.dev    : libc headers. ${stdenv.cc.libc.dev}/include/stdio.h
  #         stdenv.cc.libc.static : static libraries, if prepared
  #       Unwrapped compiler will need bespoke flags to set RUNPATH etc.
  #       Wrapped compiler takes care of flags.
  #
  #       In nxfspkgs we use toolchain instead,
  #       since imported toolchain has binutils + gcc + glibc in a single package.
  #
  #       We won't have separate {glibc, cc} until almost the end of stage2.
  #       Won't use the same naming as nixpkgs, since that would be misleading.
  #       Instead:
  #         nxfsenv.toolchain          : wrapped C,C++ compiler.  Provides {gcc, g++, nxfs-gcc, nxfs-g++}
  #         nxfsenv.toolchain.toolchain: unwrapped C,C++ compiler + bintools + glibc + headers
  #
  #       Nixpkgs stdenv does *not* have gnumake,gawk,gnutar,gnugrep,gnused,diffutils
  #       All are passed separately.  That said,
  #         stdenv.initialPath  : list(derivation)  will contain top-level gnused.
  #
  #       on linux, expect stdenv.initialPath:
  #         [ coreutils gnugrep gnused findutils diffutlis gawk gnutar gzip bzip2 gnumake bash patch xz]
  #         ++ [ patchelf binutils ].
  #
  #       If we want to follow the nixpkgs strategy here, need a makeNxfsenv,
  #       since we're progressively changing what would appear in stdenv.initialPath
  #
  nxfsenv-1 = {
    toolchain = import ../bootstrap-1/nxfs-toolchain-wrapper-1/default.nix;
    coreutils = import ../bootstrap-1/nxfs-coreutils-1/default.nix;
    gnumake   = import ../bootstrap-1/nxfs-gnumake-1/default.nix;
    gawk      = import ../bootstrap-1/nxfs-gawk-1/default.nix;
    bash      = bash-1;
    shell     = bash-1;
    gnutar    = import ../bootstrap-1/nxfs-tar-1/default.nix;
    gnugrep   = import ../bootstrap-1/nxfs-grep-1/default.nix;
    gnused    = import ../bootstrap-1/nxfs-sed-1/default.nix;
    diffutils = import ../bootstrap-1/nxfs-diffutils-1/default.nix;
    # mkDerivation :: attrs -> derivation
    mkDerivation = nxfs-autotools nxfsenv-1;

    inherit nxfs-defs;
  };

  # in nixpkgs/lib/customisation.nix, similar function is lib.callPackageWith
  #
  # allPkgs   :: attrset
  # path      :: path        to some .nix file
  # overrides :: attrset   overrides; apply on top of allPkgs
  #
  makeCallPackage = allpkgs: path: overrides:
    let
      # fn :: attrset -> derivation
      fn = import path;
    in
      # builtins.functionArgs()    = formal parameters to fn
      # builtins.insertsectAttrs() = take from allPkgs just fn's arguments
      #
      fn ((builtins.intersectAttrs (builtins.functionArgs fn) allpkgs) // overrides);
in
let
  callPackage = makeCallPackage allPkgs;
in
let
  nxfsenv-2-0 = nxfsenv-1;
  diffutils-2 = callPackage ./nxfs-diffutils-2/package.nix { nxfsenv = nxfsenv-2-0; };
in
let
  nxfsenv-2-1 = nxfsenv-2-0 // { diffutils = diffutils-2; };
  findutils-2 = callPackage ./nxfs-findutils-2/package.nix { nxfsenv = nxfsenv-2-1; };
in
let
  nxfsenv-2-2 = nxfsenv-2-1 // { findutils = findutils-2; };
  gnused-2 = callPackage ./nxfs-sed-2/package.nix { nxfsenv = nxfsenv-2-2; };
in
{
  inherit gnused-2;
  inherit findutils-2;
  inherit diffutils-2;
}
