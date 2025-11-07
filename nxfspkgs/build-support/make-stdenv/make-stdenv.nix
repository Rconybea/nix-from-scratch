# effort to get reasonable stdenv-like derivation+attrset for bootstrap.
# separate evolution from nixpkgs stdenv

# config
{ config,
  ... }
:

{
  # name :: string
  name,
  # stagepkgs :: attrset
  stagepkgs,
}
:

let
  cc        = stagepkgs.cc;
  bintools  = stagepkgs.bintools;
  patchelf  = stagepkgs.patchelf;
  patch     = stagepkgs.patch;
  shellpkg  = stagepkgs.shell;
  coreutils = stagepkgs.coreutils;
  gzip      = stagepkgs.gzip;
  xz        = stagepkgs.xz;
  gnumake   = stagepkgs.gnumake;
  gnutar    = stagepkgs.gnutar;
  gawk      = stagepkgs.gawk;
  gnugrep   = stagepkgs.gnugrep;
  gnused    = stagepkgs.gnused;
  findutils = stagepkgs.findutils;
  diffutils = stagepkgs.diffutils;

  stdenv-derivation = derivation {
    inherit name;
    system = builtins.currentSystem;

    # minimal builder
    builder = "${shellpkg}/bin/sh";

    args = [ "-e"
             (builtins.toFile "builder.sh"
               ''
                 mkdir -p $out
                 cp ${./setup.sh} $out/setup
                 cp ${./default-builder.sh} $out/default-builder

                 # Make them available at well-known paths
                 ln -s ${./setup.sh} $out/setup.sh
               '') ];

    PATH = "${coreutils}/bin";
  };

  stdenv-new =
    stdenv-derivation //
    {
      system = stdenv-derivation.system;

      shell = "${shellpkg}/bin/sh";

      inherit cc;

      # attributes that appear in call to mkDerivation:
      # 1. can be accessed directly from build script
      # 2. appear in package dependencies; when they change
      #    package must be rebuilt.
      #
      # mkDerivation :: attrs -> derivation
      #
      mkDerivation = (import ../make-derivation/make-derivation.nix)
        {
          config = config;
          stdenv = stdenv-new;
        };

      # libraries, headers, pkgconfig files etc. always available
      # for inputs in this list.
      #
      # Expect this to be empty for a final stdenv coming out of bootstrap.
      # May be non-empty for upstream stdenv candidates *during* stdenv bootstrap
      #
      baseInputs = [ ];

      # these automtically populate PATH :-> corresponding bin directories
      # are available to all nix derivations using this stdenv; but nothijng else!
      #
      # If a package wants other attributes (headers, libraries, pkgconfig files, ...)
      # it should add package to buildInputs
      #
      # initialPath :: [ derivation,.. ]
      #
      initialPath = [ cc bintools patchelf patch coreutils shellpkg
                      gzip xz gnumake gnutar gawk gnugrep gnused findutils diffutils ];

      defaultBuilder = ./default-builder.sh;

      defaultSetup = ./setup.sh;

      # contents automatically append to nativeBuildInputs in all derivations
      # created by stdenv-new.mkDerivation.   These are *build-time* dependencies
      #
      defaultNativeBuildInputs = [
        # note: setup.sh supports just-a-bash-script dependencies,
        #       see loop over recursive completion of package depenencies
        #
        ../setup-hooks/strip.sh
      ];

      # contents automatically append to buildInputs in all derivations
      # created by stdenv-new.mkDerivation.   These are *run-time* dependencies
      #
      defaultBuildInputs = [];
    };
in
stdenv-new
