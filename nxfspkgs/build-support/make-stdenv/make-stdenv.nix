# effort to get reasonable stdenv-like derivation+attrset for bootstrap.
# separate evolution from nixpkgs stdenv

# config
{ config,
  ... }
:

{
  name,

  # stagepkgs.shell/bin/bash
  # stagepkgs.coreutils
  #
  stagepkgs
}
:

let
  cc        = stagepkgs.cc;
  bintools  = stagepkgs.bintools;
  shell     = stagepkgs.shell;
  coreutils = stagepkgs.coreutils;
  gnumake   = stagepkgs.gnumake;
  gnutar    = stagepkgs.gnutar;
  gawk      = stagepkgs.gawk;
  gnugrep   = stagepkgs.gnugrep;
  gnused    = stagepkgs.gnused;
  diffutils = stagepkgs.diffutils;

  stdenv-derivation = derivation {
    inherit name;
    system = builtins.currentSystem;
  };

  stdenv-new =
    stdenv-derivation //
    rec {
      system = stdenv-derivation.system;

      shell = "${stagepkgs.shell}/bin/sh";

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
      initialPath = [ cc bintools coreutils shell gnumake gnutar gawk gnugrep gnused diffutils ];

      defaultBuilder = ./default-builder.sh;

      defaultSetup = ./setup.sh;

      # contents automatically append to nativeBuildInputs in all derivations
      # created by stdenv-new.mkDerivation
      #
      defaultNativeBuildInputs = [];

      # contents automatically append to buildInputs in all derivations
      # created by stdenv-new.mkDerivation
      #
      defaultBuildInputs = [];
    };
in
stdenv-new
