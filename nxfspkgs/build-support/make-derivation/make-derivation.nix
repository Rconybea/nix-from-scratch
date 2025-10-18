# simplied, but modelling
#   nixpkgs/pkgs/stdenv/generic/make-derivation.nix
#
# - package name
#   - name if provided;
#   - pname-version if both pname,version provided;
#   - pname otherwise
#
# - stdenv
#     stdenv.shell                     default builder (derivation)
#     stdenv.defaultSetup              default setup input (path)
#     stdenv.defaultNativeBuildInputs  default native build inputs
#     stdenv.defaultBuildInputs        default build inputs

{ config,
  stdenv,
  ... }
:

let
  # mkDerivation :: { name, ... } -> derivation
  #
  # derivation has attributes:
  #   system
  #   builder :: path
  #   args :: list
  #
  #   prePhases, preConfigurePhases, preBuildPhases, preInstallPhases,
  #    preFixupPhases, postPhases :: [ string ]
  #   preUnpack, postUnpack, prePatch, postPatch, preConfigure,
  #    postConfigure, preBuild, postBuild, preInstall, postInstall,
  #    preFixup, postFixup :: string
  #
  #   nativeBuildInputs :: [ derivation ]
  #   buildInputs :: [ derivation ]
  #
  #   patches :: list [ path ]
  #   configureFlags :: list [ string? ]
  #   makeFlags :: list [ string? ]
  #
  #   enableParallelBuilding :: bool
  #
  #   overrideAttrs :: (attrs -> attrs') -> derivation
  #   meta :: attrset
  #   passthru :: attrset
  #
  mkDerivation =
    { name ? ""
    , pname ? ""
    , version ? ""

    # Source
    , src ? null
    , srcs ? []

    # Dependencies
    , buildInputs ? []
    , nativeBuildInputs ? []
    , propagatedBuildInputs ? []
    , propagatedNativeBuildInputs ? []

    # Setup script
    , setupScript ? stdenv.defaultSetup

    # Build phases
    , phases ? []
    , prePhases ? []
    , preConfigurePhases ? []
    , preBuildPhases ? []
    , preInstallPhases ? []
    , preFixupPhases ? []
    , postPhases ? []

    # Phase overrides
    , configurePhase ? null
    , buildPhase ? null
    , checkPhase ? null
    , installPhase ? null
    , fixupPhase ? null

    # Phase hooks
    , preUnpack ? ""
    , postUnpack ? ""
    , prePatch ? ""
    , postPatch ? ""
    , preConfigure ? ""
    , postConfigure ? ""
    , preBuild ? ""
    , postBuild ? ""
    , preInstall ? ""
    , postInstall ? ""
    , preFixup ? ""
    , postFixup ? ""

    # Other attributes
    , patches ? []
    , configureFlags ? []
    , makeFlags ? []
    , meta ? {}
    , passthru ? {}
    , enableParallelBuilding ? true

    , ... } @ attrs:

    let
      # Compute the final name
      name' = if name != "" then name
              else if pname != "" && version != "" then "${pname}-${version}"
              else if pname != "" then pname
              else throw "must specify name or pname";

      # Default phases if not specified
      defaultPhases = [
        "unpackPhase"
        "patchPhase"
        "configurePhase"
        "buildPhase"
        "checkPhase"
        "installPhase"
        "fixupPhase"
        "installCheckPhase"
      ];

      # The actual derivation
      derivation' = derivation
        ({
          name = name';
          inherit (stdenv) system shell defaultSetup baseInputs initialPath;

          builder = "${stdenv.shell}";
          args = [ "-e" stdenv.defaultBuilder ];

          # Pass through build inputs
          inherit
            propagatedBuildInputs;

          # Setup script that runs all phases
          inherit
            setupScript
            prePhases preConfigurePhases preBuildPhases preInstallPhases
            preFixupPhases postPhases;

          # Pass through all the hooks
          inherit
            preUnpack postUnpack prePatch postPatch
            preConfigure postConfigure preBuild postBuild
            preInstall postInstall preFixup postFixup;

          # Dependencies get processed into environment variables
          nativeBuildInputs = nativeBuildInputs ++ stdenv.defaultNativeBuildInputs;
          buildInputs = buildInputs ++ stdenv.defaultBuildInputs;

          inherit patches configureFlags makeFlags;
          inherit enableParallelBuilding;

          # All other attributes
        } // (removeAttrs attrs [
          "name" "pname" "version" "buildInputs" "nativeBuildInputs"
          # ... other processed attributes
        ]));

    in derivation' // {
      inherit meta passthru;
      # Override function for easy modification
      overrideAttrs = f: mkDerivation (attrs // f attrs);
    };

in
mkDerivation
