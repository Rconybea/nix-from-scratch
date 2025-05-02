# Taken from nixpkgs/pkgs/build-support/trivial-builders
#
# Awkward to use from home location, because trivial-builders has various
# other dependencies with which we don't want to tangle.
#
# trivial-builders needs:
#   lib, config, stdenv, stdenvNoCC, jq, lndir, runtimeShell, shellcheck-minimal.
#
# but
#   makeSetupHook
# only needs:
#   lib
#
# Docs in doc/build-helpers/special/makesetuphook.section.md
# See https://nixos.org/manual/nixpkgs/unstable/#sec-pkgs.makeSetupHook
#
{ lib, stdenvNoCC, stdenv }:

let
  inherit (lib)
    optionalAttrs
    warn
  ;

in

rec {
  # Docs in doc/build-helpers/trivial-build-helpers.chapter.md
  # See https://nixos.org/manual/nixpkgs/unstable/#trivial-builder-runCommand
  runCommand = name: env: runCommandWith {
    stdenv = stdenvNoCC;
    runLocal = false;
    inherit name;
    derivationArgs = env;
  };

  # Docs in doc/build-helpers/trivial-build-helpers.chapter.md
  # See https://nixos.org/manual/nixpkgs/unstable/#trivial-builder-runCommandWith
  runCommandWith =
    let
      # prevent infinite recursion for the default stdenv value
      defaultStdenv = stdenv;
    in
    {
      # which stdenv to use, defaults to a stdenv with a C compiler, pkgs.stdenv
      stdenv ? defaultStdenv
      # whether to build this derivation locally instead of substituting
    , runLocal ? false
      # extra arguments to pass to stdenv.mkDerivation
    , derivationArgs ? { }
      # name of the resulting derivation
    , name
      # TODO(@Artturin): enable strictDeps always
    }: buildCommand:
      stdenv.mkDerivation ({
        enableParallelBuilding = true;
        inherit buildCommand name;
        passAsFile = [ "buildCommand" ]
          ++ (derivationArgs.passAsFile or [ ]);
      }
      // lib.optionalAttrs (! derivationArgs?meta) {
        pos = let args = builtins.attrNames derivationArgs; in
          if builtins.length args > 0
          then builtins.unsafeGetAttrPos (builtins.head args) derivationArgs
          else null;
      }
      // (lib.optionalAttrs runLocal {
        preferLocalBuild = true;
        allowSubstitutes = false;
      })
      // builtins.removeAttrs derivationArgs [ "passAsFile" ]);


  makeSetupHook =
    { name ? lib.warn "calling makeSetupHook without passing a name is deprecated." "hook"
    , deps ? [ ]
      # hooks go in nativeBuildInput so these will be nativeBuildInput
    , propagatedBuildInputs ? [ ]
      # these will be buildInputs
    , depsTargetTargetPropagated ? [ ]
    , meta ? { }
    , passthru ? { }
    , substitutions ? { }
    }:
    script:
    runCommand name
      (substitutions // {
        # TODO(@Artturin:) substitutions should be inside the env attrset
        # but users are likely passing non-substitution arguments through substitutions
        # turn off __structuredAttrs to unbreak substituteAll
        __structuredAttrs = false;
        inherit meta;
        inherit depsTargetTargetPropagated;
        propagatedBuildInputs =
          # remove list conditionals before 23.11
          lib.warnIf (!lib.isList deps) "'deps' argument to makeSetupHook must be a list. content of deps: ${toString deps}"
            (lib.warnIf (deps != [ ]) "'deps' argument to makeSetupHook is deprecated and will be removed in release 23.11., Please use propagatedBuildInputs instead. content of deps: ${toString deps}"
              propagatedBuildInputs ++ (if lib.isList deps then deps else [ deps ]));
        strictDeps = true;
        # TODO 2023-01, no backport: simplify to inherit passthru;
        passthru = passthru
          // optionalAttrs (substitutions?passthru)
          (warn "makeSetupHook (name = ${lib.strings.escapeNixString name}): `substitutions.passthru` is deprecated. Please set `passthru` directly."
            substitutions.passthru);
      })
      (''
        mkdir -p $out/nix-support
        cp ${script} $out/nix-support/setup-hook
        recordPropagatedDependencies
      '' + lib.optionalString (substitutions != { }) ''
        substituteAll ${script} $out/nix-support/setup-hook
      '');
}
