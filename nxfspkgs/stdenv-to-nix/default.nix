# Make a stdenv by substituting nix-from-scratch stdenv-args into the nixpkgs
# pipeline for building a linux stdenv.
#
# nixpkgs bootstrap process for linux stdenv [nixpkgs/pkgs/stdenv/linux/default.nix]
# constructs a pipeline of 'stageFun's.
#
# While each 'stageFun' is distinct, each applies some variation on top of
# shared generic stdenv [nixpkgs/pkgs/stdenv/generic/default.nix]
#
# The function here supplies arguments to the generic stdenv builder.
#
# Called from [nxfspkgs/nxfspkgs.nix] to make nxfs top-level attribute 'stdenv2nix'
#

{
  # the path!  not the attribute set!
  nixpkgspath ? <nixpkgs>
} :

let
  nixpkgs = import nixpkgspath {};
in

{
  # NOTE: config here is nxfspkgs-config, not nixpkgs-config!
  config,

  lib ? nixpkgs.lib,

  # nxfs-bootstrap-pkgs :: attrset
  nxfs-bootstrap-pkgs
} :

let
  # see [nxfspkgs/nxfspkgs.nix]
  nxfspkgs = nxfs-bootstrap-pkgs;
in

let
  # somehow doesn't work if we use lib
  platform = lib.systems.elaborate nxfspkgs.system;
  #platform = { system = builtins.currentSystem; };
in

let
  # makeGenericStdenv :: attrs -> (attrs -> derivation)
  #
  makeGenericStdenv = import (nixpkgspath + "/pkgs/stdenv/generic/default.nix");
  #makeGenericStdenv = import ./generic.nix; # trying local

  # argsStdenv holds the stdenv ingredients that nixpkgs's makeGenericStdenv expects from us
  argsStdenv = {
    inherit config;

    buildPlatform = platform;
    hostPlatform = platform;
    targetPlatform = platform;
    fetchurlBoot = nxfspkgs.fetchurlBoot;

    cc = nxfspkgs.gcc;
    shell = "${nxfspkgs.bash}/bin/bash";

    initialPath = [ nxfspkgs.coreutils ];
  };

in

makeGenericStdenv argsStdenv
