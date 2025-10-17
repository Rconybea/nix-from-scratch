let
  # nxfspkgs :: attrset (kitchen sink, mostly derivations)
  nxfspkgs = import <nxfspkgs> {};

  stage2pkgs = nxfspkgs.stage2pkgs;
#  bootstrap-1 = nxfspkgs.nxfs-bootstrap-1;
in

let
  # allPkgs :: attrset
  allPkgs = nxfspkgs // localpkgs;

  # autotools eventually evaluates to derivation with defaults for:
  #   .builder .args .baseInputs .buildInputs .system
  # default builder requires pkgs.bash
  #
  # nxfs-autotools :: pkgs -> attrs -> derivation
  nxfs-autotools = import ../build-support/autotools;

  # like a nixpkgs stdenv, but for nix-from-scratch bootstrap stage 2
  nxfsenv-0 =
    let
      # mkDerivation  :: attrs -> derivation
      mkDerivation = nxfspkgs.nxfs-autotools allPkgs;
      # gcc           :: derivation
      gcc-wrapper  = stage2pkgs.gcc-wrapper-2;
      # gcc-unwrapped :: derivation
      gcc          = stage2pkgs.gcc-x3-2;
      # gnumake        :: derivation
      gnumake      = stage2pkgs.gnumake-2;
      # bash         :: derivation
      shell        = stage2pkgs.bash-2;
      # binutils     :: derivation
      binutils     = stage2pkgs.binutils-2;
      # gzip         :: derivation
      gzip         = stage2pkgs.gzip-2;
      # gawk         :: derivation
      gawk         = stage2pkgs.gawk-2;
      # gnutar       :: derivation
      gnutar       = stage2pkgs.gnutar-2;
      # gnugrep      :: derivation
      gnugrep      = stage2pkgs.gnugrep-2;
      # sed          :: derivation
      gnused       = stage2pkgs.gnused-2;
      # coreutils    :: derivation
      coreutils    = stage2pkgs.coreutils-2;
      # findutils    :: derivation
      findutils    = stage2pkgs.findutils-2;
      # diffutils    :: derivation
      diffutils    = stage2pkgs.diffutils-2;
      # sysroot      :: derivation
#      sysroot      = bootstrap-1.nxfs-sysroot-1;
      # nxfs-defs    :: { target_tuple :: string }
      nxfs-defs    = stage2pkgs.nxfs-defs;
    in
      {
        inherit coreutils shell gnumake gzip gawk gnugrep gnutar gnused findutils diffutils;

        # mkDerivation :: attrs -> derivation
        mkDerivation = nxfs-autotools nxfsenv-0;

        # these automtically populate PATH :-> corresponding executables
        # are implicitly available to all nix derivations using this nxfsenv.
        #
        # initialPath :: [ derivation ]
        #
        initialPath = [ coreutils shell gnumake gzip gawk gnugrep gnused gnutar findutils diffutils
                        # toolchain
                      ];

        inherit nxfs-defs;
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
    hello-cxx-2 = callPackage ./hello-cxx-2 { nxfsenv = nxfsenv-0 // { gcc-wrapper = stage2pkgs.gcc-wrapper-2;
                                                                       gcc = stage2pkgs.gcc-x3-2;
                                                                       binutils = stage2pkgs.binutils-2;
                                                                     }; };
  };

in
localpkgs
