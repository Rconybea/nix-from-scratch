# Similar in spirit to nixpkgs/top-level/default.nix
# Intended to be composable and overrideable.
# See nxfspkgs/{default.nix, impure.nix, nxfspkgs.nix}
#
# Requires:
# 1. nixcpp built + installed. See nix-from-scratch/README)
# 2. stage0 packages built + imported. See nix-from-scratch/nxfspkgs/bootstrap/README
#
# Use:
#   $ nix-build path/to/nix-from/scratch/nxfspkgs -A stage3pkgs.diffutils-3
# or
#   $ export NIX_PATH=path/to/nix-from-scratch:${NIX_PATH}
#   $ nix-build '<nxfspkgs>' -A stage3pkgs.diffutils-3
#
# Major difference from nixpkgs.nix: w'ere carefully nesting
# nxfsenv attribute sets so that bootstrap process is more spelled out.
# See nxfsenv-2-0...
{
  # nxfspkgs: will be the contents of nxfspkgs/nxfspkgs.nix after composing
  # with config choices + overlays.
  # See nix-from-scratch/nxfspkgs/impure.nix
  #
  # The sole reason for pulling in <nxfspkgs> here is for nxfspkgs.stage3pkgs.
  # That refers to this nix function, after applying nxfspkgs configs + overlays.
  #
  # This choice allows user to customize/override stage3pkgs without (for example) cluttering NIX_PATH
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
  stage2pkgs = nxfspkgs.stage2pkgs;

  # nxfs-defs :: { target_tuple :: string }
  #   expect nxfs-defs.target_tuple="x86_64-pc-linux-gnu"
  #
  nxfs-defs = import ./bootstrap-1/nxfs-defs.nix;

  # autotools eventually evaluates to derivation with defaults for:
  #   .builder .args .baseInputs .buildInputs .system
  # default builder requires pkgs.bash
  #
  # nxfs-autotools :: pkgs -> attrs -> derivation
  nxfs-autotools = import ../build-support/autotools;

  # bootstrap stdenv for stage-2
  nxfsenv-2        = {
    # coreutils,gnused,bash :: derivation
    gcc_wrapper    = stage2pkgs.gcc-wrapper-2;
    glibc          = stage2pkgs.glibc-2;
    perl           = stage2pkgs.perl-2;
    patch          = stage2pkgs.patch-2;
    patchelf       = stage2pkgs.patchelf-2;
    findutils      = stage2pkgs.findutils-2;
    binutils       = stage2pkgs.binutils-2;
    coreutils      = stage2pkgs.coreutils-2;
    gawk           = stage2pkgs.gawk-2;
    gnumake        = stage2pkgs.gnumake-2;
    gnutar         = stage2pkgs.gnutar-2;
    gnugrep        = stage2pkgs.gnugrep-2;
    gnused         = stage2pkgs.gnused-2;
    # want this to be shell
    bash           = stage2pkgs.bash-2;
    shell          = stage2pkgs.bash-2;
    # mkDerivation :: attrs -> derivation
    mkDerivation   = nxfs-autotools nxfsenv-2;

    #  expand with stuff from bootstrap-3/default.nix.nxfsenv { .. }

    nxfs-defs      = nxfs-defs;
  };

  # in nixpkgs/lib/customisation.nix, similar function is lib.callPackageWith
  #
  # makeCallPackage :: allpkgs -> path -> overrides -> result
  #
  # where:
  # - 'import path' evaluates to a function ... -> result
  # - allpkgs   :: attrset
  # - path      :: path        to some .nix file
  # - overrides :: attrset   overrides; apply on top of allpkgs
  #
  makeCallPackage = import ../lib/makeCallPackage.nix;
in
let
  callPackage = makeCallPackage nxfspkgs.stage3pkgs;
in
let
  nxfsenv-3-00 = nxfsenv-2;
  # which-3 :: derivation
  which-3 = callPackage ./nxfs-which-3/package.nix { nxfsenv = nxfsenv-3-00; };
  # diffutils-3 :: derivation
  diffutils-3 = callPackage ./nxfs-diffutils-3/package.nix { nxfsenv = nxfsenv-3-00; };
in
let
  # nxfsenv-3-1 :: attrset
  nxfsenv-3-1 = nxfsenv-3-00 // { diffutils = diffutils-3; };
  # findutils-3 :: derivation
  findutils-3 = callPackage ./nxfs-findutils-3/package.nix { nxfsenv = nxfsenv-3-1; };
in
let
  # nxfsenv-3-2 :: attrset
  nxfsenv-3-2 = nxfsenv-3-1 // { findutils = findutils-3; };
  # gnused-3 :: derivation
  gnused-3 = callPackage ./nxfs-sed-3/package.nix { nxfsenv = nxfsenv-3-2; };
in
let
  # nxfsenv-3-3 :: attrset
  nxfsenv-3-3 = nxfsenv-3-2 // { gnused = gnused-3; };
  # gnugrep-3 :: derivation
  gnugrep-3 = callPackage ./nxfs-grep-3/package.nix { nxfsenv = nxfsenv-3-3; };
in
let
  # nxfsenv-3-3b :: attrset
  nxfsenv-3-3b = nxfsenv-3-3 // { gnugrep = gnugrep-3; };
  # bzip2-3 :: derivation
  bzip2-3 = callPackage ./nxfs-bzip2-3/package.nix { nxfsenv = nxfsenv-3-3b; };
in
let
  # nxfsenv-3-4 :: attrset
  nxfsenv-3-4 = nxfsenv-3-3b // { bzip2 = bzip2-3; };
  # gnutar-3    :: derivation
  gnutar-3 = callPackage ./nxfs-tar-3/package.nix { nxfsenv = nxfsenv-3-4; };
in
let
  # nxfsenv-3-5 :: attrset
  nxfsenv-3-5 = nxfsenv-3-4 // { gnutar = gnutar-3; };
  # bash-3 :: derivation
  bash-3 = callPackage ./nxfs-bash-3/package.nix { nxfsenv = nxfsenv-3-5; };
in
let
  # nxfsenv-3-6 :: attrset
  nxfsenv-3-6 = nxfsenv-3-5 // { bash = bash-3; shell = bash-3; };
  # (text-only -> natural to use stage2 derivation)
  # popen-3     :: derivation
  popen-3 = callPackage ../bootstrap-2/nxfs-popen-2/package.nix { nxfsenv = nxfsenv-3-6;
                                                                  popen-template = stage2pkgs.popen-template-2; };
in
let
  nxfsenv-3-7 = nxfsenv-3-6;
  gawk-3 = callPackage ./nxfs-gawk-3/package.nix { nxfsenv = nxfsenv-3-6;
                                                   popen = popen-3;
                                                 };
in
let
  # nxfsenv-3-9 :: attrset
  nxfsenv-3-8 = nxfsenv-3-7 // { gawk = gawk-3; };
  # gnumake-3   :: derivation
  gnumake-3 = callPackage ./nxfs-gnumake-3/package.nix { nxfsenv = nxfsenv-3-8; };
in
let
  # nxfsenv-3-9 :: attrset
  nxfsenv-3-9 = nxfsenv-3-6 // { gnumake = gnumake-3; };
  # coreutils-3 :: derivation
  coreutils-3 = callPackage ./nxfs-coreutils-3/package.nix { nxfsenv = nxfsenv-3-9; };
in
let
  # nxfsenv-3-10 :: attrset
  nxfsenv-3-10 = nxfsenv-3-9 // { coreutils = coreutils-3; };
  # pkgconf-3 :: derivation
  pkgconf-3    = callPackage ./nxfs-pkgconf-3/package.nix  { nxfsenv = nxfsenv-3-10; };
  # m4-3 :: derivation
  m4-3         = callPackage ./nxfs-m4-3/package.nix { nxfsenv = nxfsenv-3-10; };
  # file-3 :: derivation
  file-3       = callPackage ./nxfs-file-3/package.nix { nxfsenv = nxfsenv-3-10; };
  # zlib-3 :: derivation
  zlib-3       = callPackage ./nxfs-zlib-3/package.nix { nxfsenv = nxfsenv-3-10; };
  # gzip-3 :: derivation
  gzip-3       = callPackage ./nxfs-gzip-3/package.nix     { nxfsenv = nxfsenv-3-10; };
  # patch-3 :: derivation
  patch-3      = callPackage ./nxfs-patch-3/package.nix    { nxfsenv = nxfsenv-3-10; };
  # gperf-3 :: derivation
  gperf-3      = callPackage ./nxfs-gperf-3/package.nix    { nxfsenv = nxfsenv-3-10; };
  # patchelf-3 :: derivation
  patchelf-3   = callPackage ./nxfs-patchelf-3/package.nix { nxfsenv = nxfsenv-3-10; };
in
let
  # nxfsenv-3-a11 :: attrset
  nxfsenv-3-a11 = nxfsenv-3-10 // { pkgconf = pkgconf-3; };

  # libxcrypt-3 :: derivation
  libxcrypt-3  = callPackage ./nxfs-libxcrypt-3/package.nix { nxfsenv = nxfsenv-3-a11; };
in
let
  # nxfsenv-3-a12 :: attrset
  nxfsenv-3-a12 = nxfsenv-3-a11 // { libxcrypt = libxcrypt-3; };
  # perl-3 :: derivation
  perl-3 = callPackage ./nxfs-perl-3/package.nix { nxfsenv = nxfsenv-3-a12; };
in
let
  # nxfsenv-3-b13 :: attrset
  nxfsenv-3-b13 = nxfsenv-3-a12 // { m4 = m4-3;
                                     perl = perl-3;
                                   };
  # binutils-3 :: derivation
  binutils-3 = callPackage ./nxfs-binutils-3/package.nix { nxfsenv = nxfsenv-3-b13; };

  # autoconf-3 :: derivation
  autoconf-3 = callPackage ./nxfs-autoconf-3/package.nix { nxfsenv = nxfsenv-3-b13; };

in
let
  # nxfsenv-b14 :: attrset
  nxfsenv-3-b14 = nxfsenv-3-b13 // { autoconf = autoconf-3; };
  # autoconf-3 :: derivation
  automake-3 = callPackage ./nxfs-automake-3/package.nix { nxfsenv = nxfsenv-3-b14; };
in
let
  # nxfsenv-3-c13 :: attrset
  nxfsenv-3-c13 = nxfsenv-3-b13 // { file = file-3; };
  # flex-3 :: derivation
  flex-3 = callPackage ./nxfs-flex-3/package.nix { nxfsenv = nxfsenv-3-c13; };
  # gmp-3 :: derivation
  gmp-3 = callPackage ./nxfs-gmp-3/package.nix { nxfsenv = nxfsenv-3-c13; };
  # mpfr-3 :: derivation
  mpfr-3 = callPackage ./nxfs-mpfr-3/package.nix { nxfsenv = nxfsenv-3-b13;
                                                   gmp = gmp-3;
                                                 };
in
let
  nxfsenv-3-c14 = nxfsenv-3-c13 // { flex = flex-3; };
  # bison-3 :: derivation
  bison-3 = callPackage ./nxfs-bison-3/package.nix { nxfsenv = nxfsenv-3-c14; };
in
{
  inherit mpfr-3;
  inherit gmp-3;
  inherit bison-3;
  inherit flex-3;
  inherit automake-3;
  inherit autoconf-3;
  inherit binutils-3;
  inherit perl-3;
  inherit libxcrypt-3;
  inherit patchelf-3;
  inherit gperf-3;
  inherit patch-3;
  inherit gzip-3;
  inherit zlib-3;
  inherit file-3;
  inherit m4-3;
  inherit pkgconf-3;
  inherit coreutils-3;
  inherit gnumake-3;
  inherit gawk-3;
  inherit popen-3;
  inherit bash-3;
  inherit gnutar-3;
  inherit bzip2-3;
  inherit gnugrep-3;
  inherit gnused-3;
  inherit findutils-3;
  inherit diffutils-3;
  inherit which-3;
}
