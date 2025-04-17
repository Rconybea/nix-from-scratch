# similar in spirit to nixpkgs/top-level/default.nix
#
{
  nxfspkgs ? import <nxfspkgs> {}

,  # allow configuration attributes (if we ever have them) to be passed in as argument.
  config ? {}

, # overlays for extension
  overlays ? []

, # accumulate unexpected args
  ...
} @
# args :: attrset
  args :

let
  # nxfs-cacert :: derivation    ( SSL certificates, copied from build host)
  nxfs-cacert = import ./bootstrap/nxfs-cacert-0;

  # nxfs-defs :: { target_tuple :: string }
  #   expect nxfs-defs.target_tuple="x86_64-pc-linux-gnu"
  #
  nxfs-defs = import ./bootstrap-1/nxfs-defs.nix;

  # autotools eventually evaluates to derivation with defaults for:
  #   .builder .args .baseInputs .buildInputs .system
  # default builder requires pkgs.bash
  #
  # nxfs-autotools :: pkgs -> attrs -> derivation
  nxfs-autotools = import ./build-support/autotools;

  # TODO: need to callPackage on all these, once they're upgraded for it.
  bootstrap-1 = import ./bootstrap-1;
  bootstrap-2 = import ./bootstrap-2;
  bootstrap-3 = import ./bootstrap-3;
in

let
  # envpkgs :: attrset
  envpkgs = {
    # would like to drop this.
    # need autotools/default.nix to take nxfsenv instead of pkgs
    nxfsenv = nxfsenv-2;
  };

  # allPkgs :: attrset
  allPkgs = nxfspkgs // envpkgs;

  # bootstrap stdenv for stage-2
  nxfsenv-2 = {
    # coreutils,gnused,bash :: derivation
    gcc_wrapper  = import ./bootstrap-2/nxfs-gcc-wrapper-2;
    glibc        = import ./bootstrap-2/nxfs-glibc-stage1-2;
    perl         = import ./bootstrap-2/nxfs-perl-2;
    patch        = import ./bootstrap-2/nxfs-patch-2;
    findutils    = import ./bootstrap-2/nxfs-findutils-2;
    binutils     = import ./bootstrap-2/nxfs-binutils-2;
    coreutils    = import ./bootstrap-2/nxfs-coreutils-2;
    gawk         = import ./bootstrap-2/nxfs-gawk-2;
    gnumake      = import ./bootstrap-2/nxfs-gnumake-2;
    gnutar       = import ./bootstrap-2/nxfs-tar-2;
    gnugrep      = import ./bootstrap-2/nxfs-grep-2;
    gnused       = import ./bootstrap-2/nxfs-sed-2;
    bash         = import ./bootstrap-2/nxfs-bash-2;
    # mkDerivation :: attrs -> derivation
    mkDerivation = nxfs-autotools nxfsenv-2;

    #  expand with stuff from bootstrap-3/default.nix.nxfsenv { .. }
  };

   # bootstrap stdenv for stage-3 -- not used yet
#  nxfsenv-3 = {
#    # mkDerivation :: attrs -> derivation
#    mkDerivation = nxfspkgs.nxfs-autotools nxfsenv-3;
#  };

  # allPkgs   :: attrset
  # path      :: path         to some .nix file
  # overrides :: attrset      overrides relative to allPkgs
  makeCallPackage = allPkgs: path: overrides:
    let
      # fn :: attrset -> derivation
      fn = import path;
    in
      # builtins.functionArgs()    = formal parameters to fn
      # builtins.insertsectAttrs() = take from allPkgs just fn's arguments
      #
      fn ((builtins.intersectAttrs (builtins.functionArgs fn) allPkgs) // overrides);
in
let
  callPackage = makeCallPackage allPkgs;
in
let
  popen-template = bootstrap-2.nxfs-popen-template-2;
in
let
  nxfsenv-3-0 = { nxfs-defs = nxfs-defs; };
  # which-3 :: derivation
  which-3     = callPackage ./bootstrap-3/nxfs-which-3 {};
  # diffutils-3 :: derivation
  diffutils-3 = callPackage ./bootstrap-3/nxfs-diffutils-3 {};
in
let
  nxfsenv-3-1 = nxfsenv-3-0 // { diffutils = diffutils-3; };
  # findutils-3 :: derivation
  findutils-3 = callPackage ./bootstrap-3/nxfs-findutils-3 { nxfsenv-3 = nxfsenv-3-1; };
in
let
  nxfsenv-3-2 = nxfsenv-3-1 // { findutils = findutils-3; };
  # gnused-3    :: derivation
  gnused-3 = callPackage ./bootstrap-3/nxfs-sed-3 { nxfsenv-3 = nxfsenv-3-2; };
in
let
  nxfsenv-3-3 = nxfsenv-3-2 // { gnused = gnused-3; };
  # gnugrep-3   :: derivation
  gnugrep-3 = callPackage ./bootstrap-3/nxfs-grep-3 { nxfsenv-3 = nxfsenv-3-3; };
in
let
  nxfsenv-3-3b = nxfsenv-3-3 // { gnugrep = gnugrep-3; };
  # bzip2-3     :: derivation
  bzip2-3 = callPackage ./bootstrap-3/nxfs-bzip2-3 { nxfsenv-3 = nxfsenv-3-3b;
                                                     patchelf     = import ./bootstrap-2/nxfs-patchelf-2; };
in
let
  nxfsenv-3-4 = nxfsenv-3-3b // { bzip2 = bzip2-3; };
  # gnutar-3    :: derivation
  gnutar-3 = callPackage ./bootstrap-3/nxfs-tar-3 { nxfsenv-3 = nxfsenv-3-4; };
in
let
  nxfsenv-3-5 = nxfsenv-3-4 // { gnutar = gnutar-3; };
  # gnubash-3   :: derivation
  bash-3 = callPackage ./bootstrap-3/nxfs-bash-3 { nxfsenv-3 = nxfsenv-3-5; };
in
let
  nxfsenv-3-6 = nxfsenv-3-5 // { bash = bash-3; };
  # popen-3     :: derivation
  popen-3 = callPackage ./bootstrap-3/nxfs-popen-3 { nxfsenv-3 = nxfsenv-3-6;
                                                     popen-template = popen-template; };
in
let
  # (reminder: popen doesn't belong in stdenv)
  nxfsenv-3-7 = nxfsenv-3-6;
  # gawk-3      :: derivation
  gawk-3 = callPackage ./bootstrap-3/nxfs-gawk-3 { nxfsenv-3 = nxfsenv-3-6;
                                                   popen = popen-3; };
in
let
  nxfsenv-3-8 = nxfsenv-3-7 // { gawk = gawk-3; };
  # gnumake-3   :: derivation
  gnumake-3 = callPackage ./bootstrap-3/nxfs-gnumake-3 { nxfsenv-3 = nxfsenv-3-8; };
in
let
  nxfsenv-3-9 = nxfsenv-3-8 // { gnumake = gnumake-3; };
  # coreutils-3 :: derivation
  coreutils-3 = callPackage ./bootstrap-3/nxfs-coreutils-3 { nxfsenv-3 = nxfsenv-3-9; };
in
let
  nxfsenv-3-10 = nxfsenv-3-9 // { coreutils = coreutils-3; };
  # pkgconf-3 :: derivation
  pkgconf-3    = callPackage ./bootstrap-3/nxfs-pkgconf-3  { nxfsenv-3 = nxfsenv-3-10; };
  # m4-3 :: derivation
  m4-3         = callPackage ./bootstrap-3/nxfs-m4-3       { nxfsenv-3 = nxfsenv-3-10; };
  # file-3 :: derivation
  file-3       = callPackage ./bootstrap-3/nxfs-file-3     { nxfsenv-3 = nxfsenv-3-10; };
  # zlib-3 :: derivation
  zlib-3       = callPackage ./bootstrap-3/nxfs-zlib-3     { nxfsenv-3 = nxfsenv-3-10; };
  # patchelf-3 :: derivation
  patchelf-3   = callPackage ./bootstrap-3/nxfs-patchelf-3 { nxfsenv-3 = nxfsenv-3-10; };
  # gperf-3 :: derivation
  gperf-3      = callPackage ./bootstrap-3/nxfs-gperf-3    { nxfsenv-3 = nxfsenv-3-10; };
  # patch-3 :: derivation
  patch-3      = callPackage ./bootstrap-3/nxfs-patch-3    { nxfsenv-3 = nxfsenv-3-10; };
  # gzip-3 :: derivation
  gzip-3       = callPackage ./bootstrap-3/nxfs-gzip-3     { nxfsenv-3 = nxfsenv-3-10; };
in
let
  nxfsenv-3-a11 = nxfsenv-3-10 // { pkgconf = pkgconf-3; };
  # libxcrypt-3 :: derivation
  libxcrypt-3 = callPackage ./bootstrap-3/nxfs-libxcrypt-3 { nxfsenv-3 = nxfsenv-3-a11; };
in
let
  nxfsenv-3-a12 = nxfsenv-3-a11;
  # perl-3 :: derivation
  perl-3 = callPackage ./bootstrap-3/nxfs-perl-3 { nxfsenv-3 = nxfsenv-3-a12;
                                                   libxcrypt = libxcrypt-3; };
in
let
  nxfsenv-3-b13 = nxfsenv-3-a12 // { m4 = m4-3;
                                     perl = perl-3; };
  # binutils-3 :: derivation
  binutils-3 = callPackage ./bootstrap-3/nxfs-binutils-3 { nxfsenv-3 = nxfsenv-3-b13;
                                                           libxcrypt = libxcrypt-3; };
  # autoconf-3 :: derivation
  autoconf-3 = callPackage ./bootstrap-3/nxfs-autoconf-3 { nxfsenv-3 = nxfsenv-3-b13; };
in
let
  nxfsenv-3-b14 = nxfsenv-3-b13 // { autoconf = autoconf-3; };
  # automake-3 :: derivation
  automake-3 = callPackage ./bootstrap-3/nxfs-automake-3 { nxfsenv-3 = nxfsenv-3-b14; };
in
let
  # TODO: use callPackage on these, so they're overrideable
  gcc-wrapper-3  = bootstrap-3.gcc-wrapper-3;  # can comment this out
  glibc-stage1-3 = bootstrap-3.glibc-stage1-3;  # can comment this out
in
let
  nxfsenv-3-c13 = nxfsenv-3-b13 // { file = file-3; };
  # flex-3 :: derivation
  flex-3 = callPackage ./bootstrap-3/nxfs-flex-3 { nxfsenv-3 = nxfsenv-3-c13; };
  # gmp-3 :: derivation
  gmp-3 = callPackage ./bootstrap-3/nxfs-gmp-3 { nxfsenv-3 = nxfsenv-3-c13; };
in
let
  nxfsenv-3-c14 = nxfsenv-3-c13 // { flex = flex-3; };
  # bison-3 :: derivation
  bison-3 = callPackage ./bootstrap-3/nxfs-bison-3 { nxfsenv-3 = nxfsenv-3-c14; };
in
let
  nxfsenv-3-b15 = nxfsenv-3-b14 // nxfsenv-3-c14 // { bison = bison-3; };
  # texinfo-3 :: derivation
  texinfo-3 = callPackage ./bootstrap-3/nxfs-texinfo-3 { nxfsenv-3 = nxfsenv-3-b15; };
in
let
  # mpfr-3 :: derivation
  mpfr-3 = callPackage ./bootstrap-3/nxfs-mpfr-3 { nxfsenv-3 = nxfsenv-3-b13;
                                                   gmp = gmp-3;
                                                 };
in
let
  # mpc-3 :: derivation
  mpc-3 = callPackage ./bootstrap-3/nxfs-mpc-3 { nxfsenv-3 = nxfsenv-3-c13;
                                                 gmp = gmp-3;
                                                 mpfr = mpfr-3; };
in
let
  # editor bait: pkg-config
  nxfsenv-3-d13 = nxfsenv-3-10 // { pkgconf = pkgconf-3;
                                    zlib = zlib-3; };
  # python-3 :: derivation
  python-3 = callPackage ./bootstrap-3/nxfs-python-3 { nxfsenv-3 = nxfsenv-3-d13;
                                                       popen = popen-3;
                                                     };
in
let
  nxfsenv-3-16 = nxfsenv-3-10 // { perl     = perl-3;
                                   texinfo  = texinfo-3;
                                   bison    = bison-3;
                                   flex     = flex-3;
                                   file     = file-3;
                                   pkgconf  = pkgconf-3;
                                   m4       = m4-3;
                                   python   = python-3;
                                   zlib     = zlib-3;
                                   gperf    = gperf-3;
                                   patch    = patch-3;
                                   gzip     = gzip-3;
                                   patchelf = patchelf-3;
                                   which    = which-3;
                                 };
in
let
  nxfsenv-3-94 = nxfsenv-3-16 // { };
  glibc-stage1-3 = callPackage ./bootstrap-3/nxfs-glibc-stage1-3
    { nxfsenv-3           = nxfsenv-3-94;
      nixify-glibc-source = bootstrap-2.nxfs-nixify-glibc-source;
      lc-all-sort         = bootstrap-2.nxfs-lc-all-sort-2;
      locale-archive      = bootstrap-1.nxfs-locale-archive-1;
      toolchain-wrapper   = bootstrap-1.nxfs-toolchain-wrapper-1;
      toolchain           = bootstrap-1.nxfs-toolchain-1;
      sysroot             = bootstrap-1.nxfs-sysroot-1;
    };
in
let
  nxfsenv-3-95 = nxfsenv-3-94 // { glibc-stage1 = glibc-stage1-3; };
  # TODO switch to nxfsenv-3.glibc, along with libstdcxx
  gcc-x0-wrapper-3 = callPackage ./bootstrap-3/nxfs-gcc-x0-wrapper-3
    { nxfsenv-3   = nxfsenv-3-95;
      glibc       = glibc-stage1-3;
      bootstrap-1 = bootstrap-1;
    };
in
let
  nxfsenv-3-95a = nxfsenv-3-95 // { binutils = binutils-3; };
  binutils-x0-wrapper-3 = callPackage ./bootstrap-3/nxfs-binutils-xo-wrapper-3
    {
      nxfsenv-3   = nxfsenv-3-95a;
      glibc       = glibc-stage1-3;
    };
in
let
  nxfsenv-3-96 = nxfsenv-3-95a // { };
  # gcc-x1-3 :: derivation
  gcc-x1-3 = callPackage ./bootstrap-3/nxfs-gcc-x1-3
    { nxfsenv-3            = nxfsenv-3-96;
      gcc-stage1-wrapper-3 = gcc-x0-wrapper-3;
      binutils-wrapper     = binutils-x0-wrapper-3; #bootstrap-2.nxfs-binutils-stage1-wrapper-2;  # but try nxfsenv-3 version
      mpc                  = mpc-3;
      mpfr                 = mpfr-3;
      gmp                  = gmp-3;
      nixify-gcc-source    = bootstrap-2.nxfs-nixify-gcc-source;
      glibc                = glibc-stage1-3;
      sysroot              = bootstrap-1.nxfs-sysroot-1;
    };
in
let
  nxfsenv-3-97 = nxfsenv-3-96 // { gcc-stage1 = gcc-x1-3; };
  # gcc-stage2-wrapper-3 :: derivation
  gcc-x1-wrapper-3 = callPackage ./bootstrap-3/nxfs-gcc-x1-wrapper-3
    { nxfsenv-3 = nxfsenv-3-97;
      glibc = glibc-stage1-3;
      bootstrap-1 = bootstrap-1;
    };
in
let
  nxfsenv-3-98 = nxfsenv-3-97 // { };
  # libstdcxx-stage2-3 :: derivation
  libstdcxx-x2-3 = callPackage ./bootstrap-3/nxfs-libstdcxx-x2-3
    { nxfsenv-3            = nxfsenv-3-98;
      gcc-x1-wrapper-3     = gcc-x1-wrapper-3;
      nixify-gcc-source    = bootstrap-2.nxfs-nixify-gcc-source;
      glibc                = glibc-stage1-3;
      mpc                  = mpc-3;
      mpfr                 = mpfr-3;
      gmp                  = gmp-3;
    };
in
let
  nxfsenv-3-99 = nxfsenv-3-98 // { libstdcxx = libstdcxx-x2-3; };
  # gcc-stage3-wrapper-3 :: derivation
  gcc-x2-wrapper-3 = callPackage ./bootstrap-3/nxfs-gcc-x2-wrapper-3
    { nxfsenv-3     = nxfsenv-3-99;
      gcc-unwrapped = gcc-x1-3;
      libstdcxx     = libstdcxx-x2-3;
      glibc         = glibc-stage1-3;
    };
in
let
  # gcc-x3-3 :: derivation
  gcc-x3-3 = callPackage ./bootstrap-3/nxfs-gcc-x3-3
    { nxfsenv-3         = nxfsenv-3-99;
      nixify-gcc-source = bootstrap-2.nxfs-nixify-gcc-source;
      gcc-x2-wrapper-3  = gcc-x2-wrapper-3;
      binutils-wrapper  = bootstrap-2.nxfs-binutils-stage1-wrapper-2;
      mpc               = bootstrap-2.nxfs-mpc-2;
      mpfr              = bootstrap-2.nxfs-mpfr-2;
      gmp               = bootstrap-2.nxfs-gmp-2;
      glibc             = glibc-stage1-3;
      sysroot           = bootstrap-1.nxfs-sysroot-1;  # for linux headers
    };
in
let
  nxfsenv-3-100 = nxfsenv-3-99 // { gcc-x3-3 = gcc-x3-3; };

  # gcc-wrapper-3 :: derivation
  gcc-wrapper-3 = callPackage ./bootstrap-3/nxfs-gcc-wrapper-3
    { nxfsenv-3 = nxfsenv-3-100;
      gcc-unwrapped = gcc-x3-3;
      glibc = glibc-stage1-3;
    };

in
let
  nxfsenv-3-101 = nxfsenv-3-100 // { gcc = gcc-wrapper-3;
                                     gcc-unwrapped = gcc-x3-3;
                                   };
  mkDerivation-3 = (nxfs-autotools nxfsenv-3-101);
in
let
  nxfsenv-3-102 = nxfsenv-3-101 // { mkDerivation = mkDerivation-3; };

  openssl-3 = callPackage ./bootstrap-3/nxfs-openssl-3
    { nxfsenv-3 = nxfsenv-3-102; };
in
let
  nxfsenv-3-103 = nxfsenv-3-102 // { openssl = openssl-3; };

# moved to before gnutar-3
#  bzip2-3 = callPackage ./bootstrap-3/nxfs-bzip2-3
#    { nxfsenv-3 = nxfsenv-3-103;
#      patchelf = patchelf-3;
#    };

  xz-3 = callPackage ./bootstrap-3/nxfs-xz-3
    { nxfsenv-3 = nxfsenv-3-103; };

  curl-3 = callPackage ./bootstrap-3/nxfs-curl-3
    { nxfsenv-3 = nxfsenv-3-103; };
in
let
  nxfsenv-3-104 = nxfsenv-3-103 // { bzip2 = bzip2-3;
                                     xz = xz-3;
                                     curl = curl-3;
                                     cacert = nxfs-cacert; };

  # want a usable derivation using curl, that also has SSL certificates
  fetchurl-3 = callPackage ./bootstrap-3/nxfs-fetchurl-3 { nxfsenv-3 = nxfsenv-3-104; };
in
let
  nixpkgspath = <nixpkgs>;
  nixpkgs = import nixpkgspath {};
in
let
  # <nixpkgs>.lib
  lib-nixpkgs = nixpkgs.lib;
in
let
  # a nxfs-only "stdenv" (not using this for anything..)
  stdenv-nxfs = callPackage ./stdenv { gcc          = gcc-wrapper-3;
                                       glibc        = glibc-stage1-3;
                                       xz           = xz-3;
                                       patchelf     = patchelf-3;
                                       patch        = patch-3;
                                       file         = file-3;
                                       gnumake      = gnumake-3;
                                       gzip         = gzip-3;
                                       gnutar       = gnutar-3;
                                       bzip2        = bzip2-3;
                                       gawk         = gawk-3;
                                       gnugrep      = gnugrep-3;
                                       gnused       = gnused-3;
                                       coreutils    = coreutils-3;
                                       findutils    = findutils-3;
                                       diffutils    = diffutils-3;
                                       bash         = bash-3;
                                       which        = which-3;
                                       mkDerivation = mkDerivation-3; };

  # stdenv2nix-no-cc :: attrs -> derivation
  stdenv2nix-no-cc = callPackage ./stdenv-to-nix
    { inherit nixpkgspath; }
    {
      # to see attrs in regular nixpkgs:
      #  $ nix repl
      #  > :l <nixpkgs>
      #  > config
      #
      config = config // { allowAliases = true;
                           allowUnsupportedSystem = false;
                           allowBroken = false;
                           checkMeta = false;
                           configurePlatformsByDefault = true;
                           enableParallelBuildingByDefault = false;
                         };

      # collects final bootstrap packages (built here in nxfspkgs) that
      # we want to use to drive a nixpkgs-compatible stdenv
      #
      # ----------------------------------------------------------------
      # WARNING: to be used in stdenv, attrs added below must also add to
      #          stdenv-to-nix argsStdenv.initialPath
      # ----------------------------------------------------------------
      #
      nxfs-bootstrap-pkgs = {
        system    = nxfs-defs.system;
        gcc       = null;
        #binutils  = binutils-x0-wrapper-3;  # todo: industrial-strength gcc wrapper should hold this, match nixpkgs pattern
        patch     = patch-3;
        xz        = xz-3;
        gnumake   = gnumake-3;
        gzip      = gzip-3;
        gnutar    = gnutar-3;
        bzip2     = bzip2-3;
        gawk      = gawk-3;
        gnugrep   = gnugrep-3;
        gnused    = gnused-3;
        bash      = bash-3;
        coreutils = coreutils-3;
        diffutils = diffutils-3;
        findutils = findutils-3;
#        which    = which-3;
      };
    };
in
let
  # works!
  # btw, similar invocation of bintools-wrapper in [nixpkgs/pkgs/stdenv/linux/default.nix]
  #
  bintools-wrapper-nixpkgs = callPackage (nixpkgspath + "/pkgs/build-support/bintools-wrapper")
    { name                   = "nxfs-bintools-wrapper";
      lib                    = lib-nixpkgs;
      stdenvNoCC             = stdenv2nix-no-cc;  # will use stdenvNoCC.mkDerivation
      runtimeShell           = bash-3;
      bintools               = binutils-3;
      coreutils              = coreutils-3;
      gnugrep                = gnugrep-3;
      libc                   = glibc-stage1-3;
      nativeTools            = false;
      nativeLibc             = false;
      expand-response-params = "";
    };
in
let
  # works! at least in the sense that builds derivation and can invokve gcc
  # similar invocation of gcc-wrapper in [nixpkgs/pkgs/build-support/cc-wrapper]
  #
  # gcc-wrapper-nixpkgs :: derivation
  gcc-wrapper-nixpkgs = callPackage (nixpkgspath + "/pkgs/build-support/cc-wrapper")
    {
      name                   = "nxfs-gcc-wrapper";
      lib                    = lib-nixpkgs;
      stdenvNoCC             = stdenv2nix-no-cc;
      runtimeShell           = bash-3;
      cc                     = gcc-x3-3;
      libc                   = glibc-stage1-3;
      bintools               = bintools-wrapper-nixpkgs;
      coreutils              = coreutils-3;
      zlib                   = false; # looks like not needed for gcc
      nativeTools            = false;
      nativeLibc             = false;
      # nativePrefix = ""       # defaults to empty string; must match bintools.nativePrefix
      # propagateDoc?           # take from cc
      extraTools             = [];
      extraPackages          = [];
      extraBuildCommands     = "";
      nixSupport             = {};  # will appear as gcc-wrapper-nixpkgs.nixSupport, also in $out/nix-support
      gnugrep                = gnugrep-3;
      expand-response-params = "";
      libcxx                 = libstdcxx-x2-3;
      # useCcForLibs?           # whether or not to add -B, -L to nix-support/{cc-cflags,cc-ldflags}
      #   default: yes for clang, no if cross-compiling, no if cc from bootstrap files,
      #            yes if complicated where-are-we-in-bootstrap tests,
      #            otherwise false
      # gccForLibs?             # default: cc, if useCcForLibs is true
      # fortify-headers?        # default: null
      # includeFortifyHeaders?  # default: null
    };
in
let
  stdenv2nix-config-0 = config // { allowAliases = true;
                                    allowUnsupportedSystem = false;
                                    allowBroken = false;
                                    checkMeta = false;
                                    configurePlatformsByDefault = true;
                                    enableParallelBuildingByDefault = false;
                                    strictDepsByDefault = false;
                                  };

  # stdenv2nix :: attrs -> derivation
  stdenv2nix-minimal = callPackage ./stdenv-to-nix
    { inherit nixpkgspath; }
    {
      config = stdenv2nix-config-0;

      # collects final bootstrap packages (built here) that
      # we want to use to drive a nixpkgs-compatible stdenv.
      #
      # ----------------------------------------------------------------
      # WARNING: to be used in stdenv, attrs added below must also add to
      #          stdenv-to-nix argsStdenv.initialPath
      # ----------------------------------------------------------------
      #
      nxfs-bootstrap-pkgs = {
        system    = nxfs-defs.system;
        gcc       = gcc-wrapper-nixpkgs;
        binutils  = bintools-wrapper-nixpkgs;
        patch     = patch-3;
        xz        = xz-3;
        gnumake   = gnumake-3;
        gzip      = gzip-3;
        gnutar    = gnutar-3;
        bzip2     = bzip2-3;
        gawk      = gawk-3;
        gnugrep   = gnugrep-3;
        gnused    = gnused-3;
        bash      = bash-3;
        coreutils = coreutils-3;
        diffutils = diffutils-3;
        findutils = findutils-3;
        #        which    = which-3;
      };
    };
in
let
  stdenv2nix-config = stdenv2nix-config-0 // { replaceStdenv = stdenv2nix-minimal; };
in
let
  # for some reason attempting to inject patchelf via overlay fails.
  # (complaint from stdenv [nixpkgs/pkgs/stdenv/linux/default.nix] that previous
  # stage patchelf isn't from bootstrapTools..
  # Point mayyyyy be that nuke-references is going to be used on things from within
  # scope of bootstrapTools and that won't work for patchelf built on top of a nxfs toolchain
  # anyway, the check is something our nxfs patchelf doesn't pass
  # )

  patchelf-nixpkgs = (callPackage (nixpkgspath + "/pkgs/development/tools/misc/patchelf")
    {
      stdenv   = stdenv2nix-minimal;
      fetchurl = stdenv2nix-minimal.fetchurlBoot;
      lib      = nixpkgs.lib;
    });

  overlay = self: super: {
    config = config // { allowAliases = true;
                         allowUnsupportedSystem = false;
                         allowBroken = false;
                         checkMeta = false;
                         configurePlatformsByDefault = true;
                         enableParallelBuildingByDefault = false;
                         strictDepsByDefault = false;
                       };

    # stdenv: this assignment isn't effective - still gets various bootstrap tests
    #stdenv = stdenv2nix-minimal;
    fetchurl = stdenv2nix-minimal.fetchurlBoot;

    zlib = super.zlib.override { stdenv = stdenv2nix-minimal; };
    # xz has carve-out to prevent CONFIG_SHELL pointing to bash in bootstrapTools
    # In this context that leaves CONFIG_SHELL pointing to /bin/sh, which wedges build
    xz = (super.xz.overrideAttrs (old: { preConfigure=""; })).override { stdenv = stdenv2nix-minimal; };
    #patchelf = super.patchelf.override { stdenv = stdenv2nix-minimal; };
    #bzip2 = super.bzip2.override { stdenv = stdenv2nix-minimal; };
    #xz = super.xz.override { stdenv = stdenv2nix-minimal; }.overrideAttrs
    #  (old: { preConfigure=""; });
    file = super.file.override { stdenv = stdenv2nix-minimal; };
    which = super.which.override { stdenv = stdenv2nix-minimal; };
    #gzip = super.gzip.override { stdenv = stdenv2nix-minimal; };
    #texinfo = super.texinfo.override { stdenv = stdenv2nix-minimal; };
    #coreutils = super.coreutils.override { stdenv = stdenv2nix-minimal; };
  };
  nixpkgs = import nixpkgspath { overlays = [ overlay ]; };
in
let

  # this will try to build, but still winds up requiring nixpkgs bootstrap
  #zlib-nixpkgs2 = nixpkgs.zlib.override { stdenv = stdenv2nix-minimal; };
  zlib-nixpkgs2 = nixpkgs.zlib;
  xz-nixpkgs2 = nixpkgs.xz;   # nixpgks/pkgs/tools/compression/xz
  patchelf-nixpkgs2 = nixpkgs.patchelf; # nixpkgs/pkgs/development/tools/misc/patchelf
#  bzip2-nixpkgs2 = nixpkgs.bzip2;
  file-nixpkgs2 = nixpkgs.file;
  which-nixpkgs2 = nixpkgs.which;
#  gzip-nixpkgs2 = nixpkgs.gzip;
#  texinfo-nixpkgs2 = nixpkgs.texinfo;
#  bash-nixpkgs2 = nixpkgs.bash;

  coreutils-nixpkgs2 = nixpkgs.coreutils;

  fetchurl-nixpkgs = callPackage (nixpkgspath + "/pkgs/build-support/fetchurl")
    { lib = nixpkgs.lib;
      curl = curl-3;
      stdenvNoCC = stdenv2nix-no-cc;
      cacert = nxfs-cacert;
    };

  zlib-nixpkgs = (callPackage (nixpkgspath + "/pkgs/development/libraries/zlib")
    {
      stdenv   = stdenv2nix-minimal;
      fetchurl = stdenv2nix-minimal.fetchurlBoot;
      lib      = nixpkgs.lib;

      # used for tests..
      testers  = false;
      minizip  = false;
    });
in
let
  xz-nixpkgs = (callPackage (nixpkgspath + "/pkgs/tools/compression/xz")
    {
      stdenv = stdenv2nix-minimal;
      fetchurl = stdenv2nix-minimal.fetchurlBoot;
      lib = nixpkgs.lib;
      zlib = zlib-nixpkgs;
      isMinimalBuild = true;

      writeScript = nixpkgs.lib.writeScript;

      # for tests..
      testers = false;
    });

in
#let
#  perl-interpreter-nixpkgs = (import (nixpkgspath + "/pkgs/development/interpreters/perl")
#    {
#      callPackage = makeCallPackage
#        (nxfspkgs // envpkgs // { lib = nixpkgs.lib;
#                                  fetchurl = stdenv2nix-minimal.fetchurlBoot;
#                                  stdenv = stdenv2nix-minimal;
#                                  config = stdenv2nix-config;
#                                  coreutils = coreutils-3;
#                                  zlib = zlib-nixpkgs;
#                                  fetchFromGitHub = nixpkgs.fetchFromGitHub;
#                                  buildPackages = stdenv2nix-minimal.buildPackages;
#                                });
#    });
#in
let
#  perl-nixpkgs = perl-interpreter-nixpkgs.perl538;
  bison-nixpkgs = (callPackage (nixpkgspath + "/pkgs/development/tools/parsing/bison")
    {
      fetchurl = stdenv2nix-minimal.fetchurlBoot;
    });
  bash-nixpkgs = (callPackage (nixpkgspath + "/pkgs/shells/bash/5.nix")
    {
      fetchurl = stdenv2nix-minimal.fetchurlBoot;

    });
  texinfo-nixpkgs = (callPackage (nixpkgspath + "/pkgs/development/tools/misc/texinfo/7.0.nix")
    {
      fetchurl = stdenv2nix-minimal.fetchurlBoot;
      lib = nixpkgs.lib;
    });
  cmake-minimal-nixpkgs = (callPackage (nixpkgspath + "/pkgs/by-name/cm/cmake/package.nix")
    {
      stdenv = stdenv2nix-minimal;
      fetchurl = stdenv2nix-minimal.fetchurlBoot;
      lib = nixpkgs.lib;
      zlib = zlib-nixpkgs;
      isMinimalBuild = true;

      testers = false;
      minizip = false;
      writeScript = nixpkgs.lib.writeScript;
    });
in
{
  nxfs-autotools = nxfs-autotools;

  which-3              = which-3;
  diffutils-3          = diffutils-3;
  findutils-3          = findutils-3;
  gnused-3             = gnused-3;
  gnugrep-3            = gnugrep-3;
  gnutar-3             = gnutar-3;
  bash-3               = bash-3;
  popen-3              = popen-3;
  gawk-3               = gawk-3;
  gnumake-3            = gnumake-3;
  coreutils-3          = coreutils-3;
  pkgconf-3            = pkgconf-3;
  m4-3                 = m4-3;
  file-3               = file-3;
  zlib-3               = zlib-3;
  patchelf-3           = patchelf-3;
  gperf-3              = gperf-3;
  patch-3              = patch-3;
  gzip-3               = gzip-3;
  libxcrypt-3          = libxcrypt-3;
  perl-3               = perl-3;
  binutils-3           = binutils-3;
  autoconf-3           = autoconf-3;
  automake-3           = automake-3;
  flex-3               = flex-3;
  gmp-3                = gmp-3;
  bison-3              = bison-3;
  texinfo-3            = texinfo-3;
  mpfr-3               = mpfr-3;
  mpc-3                = mpc-3;
  python-3             = python-3;
  glibc-stage1-3       = glibc-stage1-3;
  gcc-x0-wrapper-3     = gcc-x0-wrapper-3;
  binutils-x0-wrapper-3 = binutils-x0-wrapper-3;
  gcc-x1-3             = gcc-x1-3;
  gcc-x1-wrapper-3     = gcc-x1-wrapper-3;
  libstdcxx-x2-3       = libstdcxx-x2-3;
  gcc-x2-wrapper-3     = gcc-x2-wrapper-3;
  gcc-x3-3             = gcc-x3-3;
  gcc-wrapper-3        = gcc-wrapper-3;
  bzip2-3              = bzip2-3;
  xz-3                 = xz-3;
  openssl-3            = openssl-3;
  curl-3               = curl-3;

  nxfs-bash-0           = import ./bootstrap/nxfs-bash-0;
  nxfs-coreutils-0      = import ./bootstrap/nxfs-coreutils-0;
  nxfs-gnumake-0        = import ./bootstrap/nxfs-gnumake-0;

  nxfs-toolchain-0      = import ./bootstrap/nxfs-toolchain-0;
  nxfs-sysroot-0        = import ./bootstrap/nxfs-sysroot-0;

  # pills-example-1..nxfs-bootstrap-1 :: derivation
  pills-example-1       = import ./nix-pills/example1;

  nxfs-bootstrap-1      = import ./bootstrap-1;
  nxfs-bootstrap-1-demo = import ./bootstrap-1-demo;

  nxfs-bash-1           = import ./bootstrap-1/nxfs-bash-1;
  nxfs-toolchain-1      = import ./bootstrap-1/nxfs-toolchain-1;
  nxfs-sysroot-1        = import ./bootstrap-1/nxfs-sysroot-1;

  # nxfs-bootstrap-2-demo :: attrset

  # nxfs-gcc-2 :: derivation    gcc, wrapped
  nxfs-bootstrap-2      = import ./bootstrap-2;

  nxfs-gcc-wrapper-2    = import ./bootstrap-2/nxfs-gcc-wrapper-2;
  nxfs-gcc-stage2-2     = import ./bootstrap-2/nxfs-gcc-stage2-2;
  nxfs-glibc-stage1-2   = import ./bootstrap-2/nxfs-glibc-stage1-2;
  nxfs-bash-2           = import ./bootstrap-2/nxfs-bash-2;
  nxfs-binutils-2       = import ./bootstrap-2/nxfs-binutils-2;
  nxfs-coreutils-2      = import ./bootstrap-2/nxfs-coreutils-2;
  nxfs-bootstrap-2-demo = import ./bootstrap-2-demo;

  nxfs-defs             = import ./bootstrap-1/nxfs-defs.nix;

  mkDerivation-3        = mkDerivation-3;

  stdenv-nxfs           = stdenv-nxfs;
  stdenv2nix-no-cc      = stdenv2nix-no-cc;
  stdenv2nix-minimal    = stdenv2nix-minimal;

  bintools-wrapper-nixpkgs = bintools-wrapper-nixpkgs;
  gcc-wrapper-nixpkgs = gcc-wrapper-nixpkgs;

  # fetchurl-nixpkgs :: { url :: string, urls :: list[string], ... } -> ... store-path?
  fetchurl-nixpkgs      = fetchurl-nixpkgs;
  zlib-nixpkgs2          = zlib-nixpkgs2;
  zlib-nixpkgs          = zlib-nixpkgs;
  xz-nixpkgs2           = xz-nixpkgs2;
  xz-nixpkgs            = xz-nixpkgs;
  patchelf-nixpkgs2     = patchelf-nixpkgs2;
  patchelf-nixpkgs      = patchelf-nixpkgs;
#  bzip2-nixpkgs2        = bzip2-nixpkgs2;
  file-nixpkgs2         = file-nixpkgs2;
  which-nixpkgs2        = which-nixpkgs2;
#  gzip-nixpkgs2         = gzip-nixpkgs2;
#  texinfo-nixpkgs2      = texinfo-nixpkgs2;
#  bash-nixpkgs2         = bash-nixpkgs2;
#  coreutils-nixpkgs2    = coreutils-nixpkgs2;
#  perl-nixpkgs          = perl-nixpkgs;
  bison-nixpkgs         = bison-nixpkgs;
  bash-nixpkgs          = bash-nixpkgs;
  texinfo-nixpkgs       = texinfo-nixpkgs;
  cmake-minimal-nixpkgs = cmake-minimal-nixpkgs;
}
