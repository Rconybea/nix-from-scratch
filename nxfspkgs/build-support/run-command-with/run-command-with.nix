# {lib, stdenv}
#   -> {stdenv, runLocal, derivationArgs, name}
#   -> buildCommand
#   -> derivation

{
  # lib :: attrset
  lib,
  # stdenv :: attrset+derivation   -- default stdenv
  stdenv,
} :

let
  defaultStdenv = stdenv;
in

{
  # which stdenv to use.  defaults to nxfspkgs.stdenv
  #
  # stdenv :: derivation+attrset
  stdenv ? defaultStdenv,
  # whether to build locally. Of course we must, don't have a binary cache for nxfspkgs.
  # (nixpkgs defaults to false here)
  #
  # runLocal :: bool
  runLocal ? true,
  # extra args, if any, for stdenv.mkDerivation
  #
  # derivationArgs :: attrset
  derivationArgs ? {},
  # name :: string
  name,
} :

# buildCommand :: string
buildCommand :

stdenv.mkDerivation (
  {
    enableParallelBuilding = true;
    inherit buildCommand name;
    passAsFile = [ "buildCommand" ] ++ (derivationArgs.passAsFile or [ ]);
  }
  // lib.optionalAttrs (!derivationArgs ? meta) {
    pos =
      let
        args = builtins.attrNames derivationArgs;
      in
        if builtins.length args > 0 then
          builtins.unsafeGetAttrPos (builtins.head args) derivationArgs
        else
          null;
  }
  // (lib.optionalAttrs runLocal { preferLocalBuild = true;
                                   allowSubstitutes = false; })
  // builtins.removeAttrs derivationArgs [ "passAsFile" ]
)
