# { lib, stdenv}
#  -> nmae
#  -> env
#  -> buildCommand
#  -> derivation

{
  # lib :: attrset
  lib,
  # stdenv :: attrset+derivation
  stdenv
} :

let
  stdenv' = stdenv;
in

name :

env :

lib.runCommandWith {
  stdenv = stdenv';
  runLocal = true;
  inherit name;
  derivationArgs = env;
}
