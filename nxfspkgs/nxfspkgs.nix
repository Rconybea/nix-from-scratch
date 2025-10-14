# similar in spirit to nixpkgs/top-level/default.nix
#
{
  # will be the contents of *this file* after composing with config choices + overlays
  # see nix-from-scratch/nxfspkgs/impure.nix
  #
  nxfspkgs ? import <nxfspkgs> {}

,  # allow configuration attributes (if we ever have them) to be passed in as arguments.
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
  #bootstrap-3 = import ./bootstrap-3;  # superseded

  # new version of stage2 bootstrap.  intend to replace bootstrap-2
  stage2pkgs = (import ./bootstrap-2/stage2pkgs.nix) args;
  stage3pkgs = (import ./bootstrap-3/stage3pkgs.nix) args;
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
    gcc_wrapper  = stage2pkgs.gcc-wrapper-2;
    glibc        = stage2pkgs.glibc-2;
    perl         = stage2pkgs.perl-2;
    patch        = stage2pkgs.patch-2;
    findutils    = stage2pkgs.findutils-2;
    binutils     = stage2pkgs.binutils-2;
    coreutils    = stage2pkgs.coreutils-2;
    gawk         = stage2pkgs.gawk-2;
    gnumake      = stage2pkgs.gnumake-2;
    gnutar       = stage2pkgs.gnutar-2;
    gnugrep      = stage2pkgs.gnugrep-2;
    gnused       = stage2pkgs.gnused-2;
    # want this to be shell
    bash         = stage2pkgs.bash-2;
    shell        = stage2pkgs.bash-2;
    # mkDerivation :: attrs -> derivation
    mkDerivation = nxfs-autotools nxfsenv-2;

    #  expand with stuff from bootstrap-3/default.nix.nxfsenv { .. }
  };

in
let
  popen-template = bootstrap-2.nxfs-popen-template-2;
in
let
  # which-3, diffutils-3 :: derivation
  which-3 = stage3pkgs.which-3;
  diffutils-3 = stage3pkgs.diffutils-3;
  findutils-3 = stage3pkgs.findutils-3;
  gnused-3 = stage3pkgs.gnused-3;
  gnugrep-3 = stage3pkgs.gnugrep-3;
in
let
  # callPackage :: path -> attrset -> result,
  # where path is a nix expression that evalutes to :: result
  #
  callPackage = (import ./lib/makeCallPackage.nix) allPkgs;
  #
  nxfsenv-3-3b = { gnugrep = gnugrep-3;
                   gnused = gnused-3;
                   diffutils = diffutils-3;
                   findutils = findutils-3;
                   nxfs-defs = nxfs-defs;
                 };
in
let
  # bzip2-3     :: derivation
  bzip2-3 = callPackage ./bootstrap-3/nxfs-bzip2-3 { nxfsenv-3 = nxfsenv-3-3b;
                                                     patchelf  = import ./bootstrap-2/nxfs-patchelf-2; };
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
  nxfsenv-3-6 = nxfsenv-3-5 // { bash = bash-3; shell = bash-3; };
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
                                     perl = perl-3;
                                     libxcrypt = libxcrypt-3;
                                   };
  # binutils-3 :: derivation
  binutils-3 = callPackage ./bootstrap-3/nxfs-binutils-3 { nxfsenv-3 = nxfsenv-3-b13; };

  # autoconf-3 :: derivation
  autoconf-3 = callPackage ./bootstrap-3/nxfs-autoconf-3 { nxfsenv-3 = nxfsenv-3-b13; };
in
let
  nxfsenv-3-b14 = nxfsenv-3-b13 // { autoconf = autoconf-3; };

  # automake-3 :: derivation
  automake-3 = callPackage ./bootstrap-3/nxfs-automake-3 { nxfsenv-3 = nxfsenv-3-b14; };
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
  nxfsenv-3-16 = nxfsenv-3-10 // { binutils = binutils-3;
                                   perl     = perl-3;
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
  # TODO: do we still need toolchain?  should use nxfs-gcc-wrapper-2
  glibc-x1-3 = callPackage ./bootstrap-3/nxfs-glibc-x1-3
    { nxfsenv-3           = nxfsenv-3-94;
      nixify-glibc-source = bootstrap-2.nxfs-nixify-glibc-source;
      lc-all-sort         = bootstrap-2.nxfs-lc-all-sort-2;
      locale-archive      = bootstrap-1.nxfs-locale-archive-1;
      toolchain-wrapper   = bootstrap-1.nxfs-toolchain-wrapper-1;
      toolchain           = bootstrap-1.nxfs-toolchain-1;
    };
in
let
  nxfsenv-3-95 = nxfsenv-3-94 // { glibc = glibc-x1-3; };

  gcc-x0-wrapper-3 = callPackage ./bootstrap-3/nxfs-gcc-x0-wrapper-3
    { nxfsenv-3   = nxfsenv-3-95; };
in
let
  nxfsenv-3-95a = nxfsenv-3-95 // { binutils = binutils-3; };
  binutils-x0-wrapper-3 = callPackage ./bootstrap-3/nxfs-binutils-xo-wrapper-3
    {
      nxfsenv-3   = nxfsenv-3-95a;
      glibc       = glibc-x1-3;
    };
in
let
  nxfsenv-3-96 = nxfsenv-3-95a // { gcc = gcc-x0-wrapper-3; };

  # gcc-x1-3 :: derivation
  gcc-x1-3 = callPackage ./bootstrap-3/nxfs-gcc-x1-3
    { nxfsenv-3            = nxfsenv-3-96;
      binutils-wrapper     = binutils-x0-wrapper-3;
      mpc                  = mpc-3;
      mpfr                 = mpfr-3;
      gmp                  = gmp-3;
      nixify-gcc-source    = bootstrap-2.nxfs-nixify-gcc-source;
      toolchain            = bootstrap-1.nxfs-toolchain-1; # for linux headers
    };
in
let
  nxfsenv-3-97 = nxfsenv-3-96 // { gcc-stage1 = gcc-x1-3; };
  # gcc-stage2-wrapper-3 :: derivation
  gcc-x1-wrapper-3 = callPackage ./bootstrap-3/nxfs-gcc-x1-wrapper-3
    { nxfsenv-3 = nxfsenv-3-97; };
in
let
  nxfsenv-3-98 = nxfsenv-3-97 // { gcc = gcc-x1-wrapper-3; };
  # libstdcxx-stage2-3 :: derivation
  libstdcxx-x2-3 = callPackage ./bootstrap-3/nxfs-libstdcxx-x2-3
    { nxfsenv-3            = nxfsenv-3-98;
      nixify-gcc-source    = bootstrap-2.nxfs-nixify-gcc-source;
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
    };
in
let
  nxfsenv-3-99a = nxfsenv-3-99 // { gcc = gcc-x2-wrapper-3; };

  # gcc-x3-3 :: derivation
  gcc-x3-3 = callPackage ./bootstrap-3/nxfs-gcc-x3-3
    { nxfsenv-3         = nxfsenv-3-99a;
      nixify-gcc-source = bootstrap-2.nxfs-nixify-gcc-source;
      binutils-wrapper  = binutils-x0-wrapper-3;
      mpc               = mpc-3;
      mpfr              = mpfr-3;
      gmp               = gmp-3;
      toolchain         = bootstrap-1.nxfs-toolchain-1;  # for linux headers
    };
in
let
  nxfsenv-3-100 = nxfsenv-3-99 // { gcc-unwrapped = gcc-x3-3; };

  # gcc-wrapper-3 :: derivation
  gcc-wrapper-3 = callPackage ./bootstrap-3/nxfs-gcc-wrapper-3
    { nxfsenv-3 = nxfsenv-3-100; };

in
let
  nxfsenv-3-101 = nxfsenv-3-100 // { gcc = gcc-wrapper-3; };

  # mkDerivation-3 :: attrs -> derivation
  mkDerivation-3 = (nxfs-autotools nxfsenv-3-101);
in
let
  nxfsenv-3-102 = nxfsenv-3-101 // { mkDerivation = mkDerivation-3; };

  openssl-3 = callPackage ./bootstrap-3/nxfs-openssl-3
    { nxfsenv-3 = nxfsenv-3-102; };
in
let
  nxfsenv-3-103 = nxfsenv-3-102 // { openssl = openssl-3; };

  xz-3 = callPackage ./bootstrap-3/nxfs-xz-3
    { nxfsenv-3 = nxfsenv-3-103; };

  curl-3 = callPackage ./bootstrap-3/nxfs-curl-3
    { nxfsenv-3 = nxfsenv-3-103; };
in
let
  nxfsenv-3-103a = nxfsenv-3-102 // { xz = xz-3; curl = curl-3; };

  # TODO: promote this as far upstream as we can go.
  #
  # Ultimately: get nix fetchurl working in bootstrap-2 (or maybe bootstrap-1)
  #
  cacert-3 = callPackage ./bootstrap-3/nxfs-cacert-3 { nxfsenv-3 = nxfsenv-3-103a; };
in
let
  nxfsenv-3-104 = nxfsenv-3-103 // { bzip2 = bzip2-3;
                                     xz = xz-3;
                                     curl = curl-3;
                                     cacert = cacert-3; };

  # want a usable derivation using curl, that also has SSL certificates
  fetchurl-3 = (import ./bootstrap-3/nxfs-fetchurl-3) { nxfsenv-3 = nxfsenv-3-104;
                                                        curl = curl-3;
                                                        cacert = cacert-3;
                                                      };
  # will be the tarball itself.
  test-fetch-3 = fetchurl-3 {
    name = "test-fetch-3-zlib-v1.3.1.tar.gz";
    url = "https://github.com/madler/zlib/archive/v1.3.1.tar.gz";
    sha256 = "sha256-F+iIY/NgBnKrSRgvIXKBtvxNPHYr3jYZNeQ2qVIU0Fw=";
  };
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
                                       glibc        = glibc-x1-3;
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
      # Incomplete config will break nixpkgs in a variety of ways.
      # editor bait: error: attribute
      #
      # See also [stdenv2nix-config-0] below
      #
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
                           showDerivationWarnings = [ ];
                           strictDepsByDefault = false;
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
        patch     = patch-3;
        patchelf  = patchelf-3;
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
      libc                   = glibc-x1-3;
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
      libc                   = glibc-x1-3;
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
  # See also [stdenv2nix-no-cc] above
  #
  stdenv2nix-config-0 = config // { allowAliases = true;
                                    allowUnsupportedSystem = false;
                                    allowBroken = false;
                                    checkMeta = false;
                                    configurePlatformsByDefault = true;
                                    enableParallelBuildingByDefault = false;
                                    showDerivationWarnings = [ ];
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
        patchelf  = patchelf-3;
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
  # not sure this has any effect -- failed experiment?
  stdenv2nix-config = stdenv2nix-config-0 // { replaceStdenv = stdenv2nix-minimal; };
in
let
  # try getting stdenv bootstrap stages so we can inspect derivations from nix repl.
  # Just using this for inspection, not otherwise useful.
  #
  # This isn't quite the same things as what nixpkgs uses, we're not supplying overlays
  # (see [nixpkgs/pkgs/top-level/default.nix])
  #
  # Here we're following nixpkgs/default.nix expression
  #   stages = stdenvStages {
  #     inherit lib localSystem crossSystem config overlays crossOverlays
  #   }
  # with argument
  #   stdenvStages ? import ../stdenv
  #
  # USE:
  #   $ nix repl
  #   > (builtins.elemAt stdenv-stages 0) {}
  #   {
  #     __raw = true; binutils = null; coreutils = null; gcc-unwrapped = null; gnugrep = null;
  #   }
  stdenv-stages = (callPackage (nixpkgspath + "/pkgs/stdenv")
    (let
      localSystem = nixpkgs.lib.systems.elaborate builtins.currentSystem;
    in
      {
        lib = nixpkgs.lib;
        localSystem = localSystem;
        crossSystem = localSystem; # same as localSystem
        config = stdenv2nix-config-0;
        overlays = [];
        crossOverlays = [];
      }));

  # for some reason attempting to inject patchelf via overlay fails.
  # (complaint from stdenv [nixpkgs/pkgs/stdenv/linux/default.nix] that previous
  # stage patchelf isn't built by bootstrap files compiler..
  # Point mayyyyy be that nuke-references is going to be used on things from within
  # scope of bootstrapTools and that won't work for patchelf built on top of a nxfs toolchain
  # anyway, the check is something our nxfs patchelf doesn't pass
  # )

  # works, but not if we try to replace nixpkgs.patchelf with this derivation
  # debug tools
  #   $ nix repl
  #   > :l <nxfspkgs>
  #   > builtins.attrNames patchelf-nixpkgs
  #   > patchelf-nixpkgs.stdenv.cc --> nxfs-gcc-wrapper-14.2.0.drv
  #   > patchelf-nixpkgs.stdenv.cc.cc --> nxfs-gcc-x3-3.drv
  #
  patchelf-nixpkgs = (callPackage (nixpkgspath + "/pkgs/development/tools/misc/patchelf")
    {
      stdenv   = stdenv2nix-minimal;
      fetchurl = stdenv2nix-minimal.fetchurlBoot;
      lib      = nixpkgs.lib;
    });

  # NOT YET
  #   needs ncurses, termcap (but won't use), fetchpatch, fetchurl, lib, stdenv
  #
  readline82-nixpkgs = (callPackage (nixpkgspath + "/pkgs/development/libraries/readline/8.2.nix")
    {

    });

  # NOT YET
  #   needs readline, texinfo, bison
  bash-nixpkgs = (callPackage (nixpkgspath + "/pkgs/shells/bash/5.nix")
    {
    });

  overlay = self: super:
    # RULES:
    #  - overlay should not be recursive (so can compose with other overlays).  Use 'self'
    #  - refs to library functions should use 'super'
    #  - refs to other packages should use 'self' rather than 'super'
    #  - overlays should not depend on any nix packages except {'self', 'super'}

    let
      # establish package-set in which callPackage tracks the effects introduced by this overlay.
      #newScope = extra: super.lib.callPackageWith (super // defaults // extra);
      #defaults = {};
    in
      {
        config = config // { allowAliases = true;
                             allowUnsupportedSystem = false;
                             allowBroken = false;
                             checkMeta = false;
                             configurePlatformsByDefault = true;
                             enableParallelBuildingByDefault = false;
                             strictDepsByDefault = false;
                           };

        # --------------------------------
        # stdenv: this assignment isn't immediate effective.  Triggers bootstrap asserts:
        # (1) isFromBootstrapFiles (prevStage).binutils.bintools
        #stdenv = stdenv2nix-minimal;
        # --------------------------------

        fetchurl = stdenv2nix-minimal.fetchurlBoot;

        # builds! - with stdenvStages, don't even need override
        #gnu-config = super.gnu-config.override { stdenv = stdenv2nix-minimal; };

        # builds! - with stdenvStages, don't even need override
        #zlib = super.zlib.override { stdenv = stdenv2nix-minimal; };

        # builds! - with stdenvStages, don't need override
        # xz has carve-out to prevent CONFIG_SHELL pointing to bash in bootstrapTools
        # In this context that leaves CONFIG_SHELL pointing to /bin/sh, which wedges build
        #xz = (super.xz.overrideAttrs (old: { preConfigure=""; })); # .override { stdenv = stdenv2nix-minimal; };

        # Does not work: presumably nixpkgs patchelf derivation gets injected somewhere.
        # (1) checks patchelf.stdenv.cc.cc satisfies 'isBuiltByBootstrapFilesCompiler'
        # (2) checks .... satisfies 'isBuiltByNixpkgsCompiler'
        #patchelf = patchelf-nixpkgs;
        #
        # Also does not work: complains that patchelf isn't built by bootstrapFiles compiler.
        # check is in nixpkgs/pkgs/stdenv/linux/defualt.nix:
        #   isBuiltByBootstrapFilesCompiler
        #    = pkgs: isFromNixpkgs pkg && isFromBootstrapFiles pkg.stdenv.cc.cc
        #patchelf = super.patchelf.override { stdenv = stdenv2nix-minimal; };
        #
        # On second thought, assertions come from nixpkgs/pkgs/stdenv/linux/default.nix.
        # Our minimal stdenv only depends on nixpkgs/pkgs/stdenv/generic/default.nix,
        # so presumably interference from linux/default.nix is coming from somewhere else.

        #bzip2 = super.bzip2.override { stdenv = stdenv2nix-minimal; };

        makeSetupHook =
          (callPackage ./build-support/trivial-builders-0.nix
            {
              stdenv = stdenv2nix-minimal;
              stdenvNoCC = stdenv2nix-no-cc;
              lib = self.lib; })
            .makeSetupHook;

        dieHook = super.dieHook;

        # builds! -- with stdenvStages, don't need override
        # file = super.file.override { stdenv = stdenv2nix-minimal; };
        # builds!  -- with stdenvStages, don't need override
        # which = super.which.override { stdenv = stdenv2nix-minimal; };
        # builds!
        #pkg-config-unwrapped = super.pkg-config-unwrapped.override {
        #  stdenv = stdenv2nix-minimal;
        #  libiconv = stdenv2nix-minimal.cc.libc; };

        # builds! -- with stdenvStages, don't need override
        # pkg-config = super.pkg-config.override { stdenvNoCC = stdenv2nix-no-cc; };

        # builds!
#        gettext = super.gettext.override {
##          stdenv = stdenv2nix-minimal;
##          fetchurl = stdenv2nix-minimal.fetchurlBoot;
#          bash = bash-3;
#        };

        ncurses = (super.ncurses.overrideAttrs (old: { passthru.binlore = null; })).override {
          mouseSupport = false; # 1. would be nice; 2. relies on pkgs/servers/gpm; 3. gpm needs a bunch of deps
          gpm = null;
          binlore = null; # some sort of dependency analyzer thing; only affects passthru.binlore. Too many deps

          # for tests
          testers = false;
        };

        # builds!
#        perl536 = (super.perl536.overrideAttrs (old: {})).override {
#          fetchFromGitHub = null;
#          makeWrapper = null;
#          enableCrypt = false;
#        };

        # builds!
#        perl538 = (super.perl538.overrideAttrs (old: {})).override {
#          fetchFromGitHub = null;
#          makeWrapper = null;
#          #      enableCrypt = false;
#        };

#        perl = self.perl538;

        # perl536, perl538, perl:
        #   This gets us working perl interpreter,
        #   but perlPackages still depends on before-override perl
#        perlPackages = super.lib.recurseIntoAttrs self.perl538.pkgs;

        # builds!
#        libxcrypt = (super.libxcrypt.overrideAttrs (old:
#          {
#            # No idea why libxcrypt builds without this in nixpkgs
#            postConfigure = ''
#              patchShebangs build-aux/scripts/move-if-change
#            '';
#          })); #.override { stdenv = stdenv2nix-minimal; fetchurl = stdenv2nix-minimal.fetchurlBoot; };

        #gnum4 = super.gnum4.override { stdenv = stdenv2nix-minimal; };
        #m4 = self.gnum4;

#        help2man = (super.help2man.overrideAttrs (old:
#          {
#            # no idea why we need this (given help2man works in nixpkgs)
#            postConfigure = ''
#            patchShebangs build-aux/mkinstalldirs
#            patchShebangs build-aux/find-vpath
#            '';
#          }));

#        bison = (super.bison.overrideAttrs (old:
#          {
#            # no idea why we need this (given help2man works in nixpkgs)
#            postConfigure = ''
#            patchShebangs build-aux/move-if-change
#            '';
#          }));

        # builds! -- don't need anything
        #bash = super.bash.override { stdenv = stdenv2nix-minimal; };

#        gzip = (super.gzip.overrideAttrs (old:
#          {
#            # omit SHELL=/bin/sh
#            makeFlags = [
#              "GREP=grep"
#              "ZLESS_MAN=zless.1"
#              "ZLESS_PROG=zless"
#            ];
#
#            postConfigure = ''
#            patchShebangs build-aux/compile
#            '';
#          }));

        # builds!
        #texinfo = super.texinfo.override { stdenv = stdenv2nix-minimal; };

        # builds!
        #autoconf

        # builds!
#        automake = (super.automake.overrideAttrs (old:
#          {
#            postConfigure = ''
#            patchShebangs pre-inst-env
#            '';
#          }));

        # builds!
        # libtool = super.libtool;

        # builds!
        # autoreconfHook = super.autoreconfHook;

        # builds!
#        gawk = (super.gawk.overrideAttrs (old:
#          {
#            postConfigure = ''
#            patchShebangs build-aux/install-sh
#            '';
#          }));

        # builds!
#        gmp = (super.gmp.overrideAttrs (old:
#          {
#            postConfigure = ''
#            patchShebangs mpn/m4-ccas
#            '';
#          }));

        # attr builds!
        # acl builds!

        # coreutils builds!
        #coreutils = (super.coreutils.overrideAttrs (old:
        #  {
        #    # two tests fail {test-freadptr.sh, test-freadseek.sh} because of shebang stuff
        #    doCheck = false;
        #
        #    # see pkgs/build-support/setup-hooks/patch-shebangs.sh
        #    postConfigure = ''
        #    patchShebangs gnulib-tests/*.sh
        #    patchShebangs gnulib-tests/uniwidth/*.sh
        #    '';
        #  }));

        # jq TBD

      };  # end of overlay

  # nixpkgs anatomy
  #   nixpkgs/default.nix
  #   -> nixpkgs/pkgs/toplevel/impure.nix
  #   -> nixpkgs/pkgs/toplevel/default.nix
  #      -> nixpkgs/pkgs/toplevel/stage.nix    (uses stdenv, stdenvNoCC)
  #         -> nixpkgs/pkgs/toplevel/splice.nix
  #         -> nixpkgs/pkgs/toplevel/aliases.nix
  #      -> nixpkgs/pkgs/stdenv/booter.nix     (assembles stdenv)

  nixpkgs = import nixpkgspath {
    # evaluates!
    #   -> nixpkgs.stdenv is stdenv2nix-minimal.
    #   -> nixpkgs.stdenvNoCC is stdenv2nix-minimal with .cc=null
    #
    stdenvStages = {config,
                     lib,
                     localSystem,
                     crossSystem,
                     overlays,
                     crossOverlays
                   } :
                     let
                       # TODO: this is probably missing a bunch of important things.
                       # see linux/default.nix for details.
                       #
                       stage0 = {} : { config = config;
                                       overlays = overlays;
                                       stdenv = stdenv2nix-minimal; };
                     in
                       [ stage0 ];

    overlays = [ overlay ]; };
in
let

  gnu-config-nixpkgs2 = nixpkgs.gnu-config;
  # this will try to build, but still winds up requiring nixpkgs bootstrap
  #zlib-nixpkgs2 = nixpkgs.zlib.override { stdenv = stdenv2nix-minimal; };
  zlib-nixpkgs2 = nixpkgs.zlib;
  xz-nixpkgs2 = nixpkgs.xz;   # nixpgks/pkgs/tools/compression/xz

  patchelf-nixpkgs2 = nixpkgs.patchelf; # nixpkgs/pkgs/development/tools/misc/patchelf

#  bzip2-nixpkgs2 = nixpkgs.bzip2;

  # file-nixpkgs2: no good, attempts nixpkgs bootstrap
  file-nixpkgs2 = nixpkgs.file;

  which-nixpkgs2 = nixpkgs.which;  # working
  pkg-config-unwrapped-nixpkgs2 = nixpkgs.pkg-config-unwrapped;  # working
  pkg-config-nixpkgs2 = nixpkgs.pkg-config;

  updateAutotoolsGnuConfigScriptsHook-nixpkgs2 = nixpkgs.updateAutotoolsGnuConfigScriptsHook;

  ncurses-nixpkgs2 = nixpkgs.ncurses;

  # gzip-nixpkgs: not good, needs bash
  gzip-nixpkgs2 = nixpkgs.gzip; # needs bash
#  texinfo-nixpkgs2 = nixpkgs.texinfo;
  bash-nixpkgs2 = nixpkgs.bash;

  coreutils-nixpkgs2 = nixpkgs.coreutils;

  # builds!
  fetchurl-nixpkgs = callPackage (nixpkgspath + "/pkgs/build-support/fetchurl")
    { lib = nixpkgs.lib;
      curl = curl-3;
      stdenvNoCC = stdenv2nix-no-cc;
      cacert = nxfs-cacert;
    };

  # builds!
  gnu-config-nixpkgs = (callPackage (nixpkgspath + "/pkgs/development/libraries/gnu-config")
    {
      stdenv   = stdenv2nix-minimal;
      fetchurl = stdenv2nix-minimal.fetchurlBoot;
      lib      = nixpkgs.lib;
    });

  # Works, but relies on kitbashing nixpkgs trivial-builders.
  # See trivial-builders-0 above.
  #
  # Otherwise:
  #   Needs makeSetupHook from build-support/trivial-builders/default.nix
  #   Even though that's just a shell script thing, it resides in trivial-builders
  #   alongside peers that have more elaborate dependencies.
  #   Then trivial-builders is setup as an overlay.
  #   Full immediate dependency set:
  #     lib,config,runtimeShell,stdenv,stdenvNoCC,jq,shellcheck-minimal,lndir
  #
  updateAutotoolsGnuConfigScriptsHook-nixpkgs = nixpkgs.makeSetupHook {
    name = "update-autotools-gnu-config-scripts-hook";
    substitutions = { gnu_config = gnu-config-nixpkgs; };
  } (nixpkgspath + "/pkgs/build-support/setup-hooks/update-autotools-gnu-config-scripts.sh");

  # builds!
  zlib-nixpkgs = (callPackage (nixpkgspath + "/pkgs/development/libraries/zlib")
    {
      stdenv   = stdenv2nix-minimal;
      fetchurl = stdenv2nix-minimal.fetchurlBoot;
      lib      = nixpkgs.lib;

      # used for tests..
      testers  = false;
      minizip  = false;
    });

  # builds!
  #  looks like libiconf should get resolved to stdenv.cc.glibc --> hack that in.
  pkg-config-unwrapped-nixpkgs = (callPackage (nixpkgspath + "/pkgs/development/tools/misc/pkg-config")
    {
      stdenv = stdenv2nix-minimal;
      fetchurl = stdenv2nix-minimal.fetchurlBoot;
      lib = nixpkgs.lib;
      # TODO: overlay on nixpkgs shouldn't need this
      libiconv = stdenv2nix-minimal.cc.libc;
    });

in
let
  # builds!
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

  # builds!
  gettext-nixpkgs = (callPackage (nixpkgspath + "/pkgs/development/libraries/gettext")
    {
      stdenv = stdenv2nix-minimal;
      fetchurl = stdenv2nix-minimal.fetchurlBoot;
      lib = nixpkgs.lib;
      bash = bash-3;
      updateAutotoolsGnuConfigScriptsHook = nixpkgs.updateAutotoolsGnuConfigScriptsHook;
      # TODO: overlay on nixpkgs shouldn't need this
      libiconv = stdenv2nix-minimal.cc.libc;
    });

  # builds!
  help2man-nixpkgs = (callPackage (nixpkgspath + "/pkgs/development/tools/misc/help2man")
    {
      stdenv = stdenv2nix-minimal;
      fetchurl = stdenv2nix-minimal.fetchurlBoot;
      lib = nixpkgs.lib;
      perlPackages = nixpkgs.perlPackages;
      gettext = nixpkgs.gettext; #nixpkgs-nixpkgs;
      libintl = null;  # get this functionality from glibc anyways

    }).overrideAttrs(old: {
      postConfigure = ''
      patchShebangs build-aux/mkinstalldirs
      patchShebangs build-aux/find-vpath
      '';
    });

  # builds!
  pkg-config-nixpkgs = (callPackage (nixpkgspath + "/pkgs/build-support/pkg-config-wrapper")
    {
      stdenvNoCC = stdenv2nix-no-cc;
      pkg-config = pkg-config-unwrapped-nixpkgs;
      lib = nixpkgs.lib;
      buildPackages = stdenv2nix-minimal.buildPackages;
    });

  # builds!
  ncurses-nixpkgs = (callPackage (nixpkgspath + "/pkgs/development/libraries/ncurses")
    {
      stdenv = stdenv2nix-minimal;
      fetchurl = stdenv2nix-minimal.fetchurlBoot;
      lib = nixpkgs.lib;
      pkg-config = pkg-config-nixpkgs;  # or pkg-config-nixpkgs2;
      buildPackages = stdenv2nix-minimal.buildPackages;
      updateAutotoolsGnuConfigScriptsHook = nixpkgs.updateAutotoolsGnuConfigScriptsHook;
      ncurses = null;  # would be used if cross compiling
      mouseSupport = false; # 1. would be nice; 2. relies on pkgs/servers/gpm; 3. gpm needs a bunch of deps
      gpm = null;
      binlore = null; # some sort of dependency analyzer thing; only affects passthru.binlore. Too many deps

      # for tests
      testers = false;
    }).overrideAttrs(old: { passthru.binlore = null; });



  # NOT QUITE.  Needs runtimeShell =
  #
  gzip-nixpkgs = (callPackage (nixpkgspath + "/pkgs/tools/compression/gzip")
    {
      stdenv = stdenv2nix-minimal;
      fetchurl = stdenv2nix-minimal.fetchurlBoot;
      lib = nixpkgs.lib;
      updateAutotoolsGnuConfigScriptsHook = nixpkgs.updateAutotoolsGnuConfigScriptsHook;
      xz = xz-nixpkgs;
    });

in
let
  # builds!
  #
  # nixpkgs
  #
  # CAVEATS:
  # 1. does not support perl packages !!
  # 2. does not support libxcrypt
  # 3. broken for cross-compiling (no doubt in good company..)
  # 4. uses bootstrap coreutils
  #
  perl538-interpreter-nixpkgs = (callPackage (nixpkgspath + "/pkgs/development/interpreters/perl/interpreter.nix")
    {
      stdenv           = stdenv2nix-minimal;
      fetchurl         = stdenv2nix-minimal.fetchurlBoot;
      fetchFromGitHub  = null;  # only used when cross compiling, we can omit
      lib              = nixpkgs.lib;
      buildPackages    = stdenv2nix-minimal.buildPackages;

      # these seem to be used only for inscrutable-to-me passthru stuff
      pkgsBuildBuild   = nixpkgs;
      pkgsBuildHost    = nixpkgs;
      pkgsBuildTarget  = nixpkgs;
      pkgsHostHost     = nixpkgs;
      pkgsTargetTarget = nixpkgs;

      # passthruFn (in perl/default.nix) provides perlPackagesFun that does callPackage
      # targeting nixpkgs/pkgs/top-level/perl-packages.nix
      # try a stub version here.
      passthruFun      = attrs : { };

      # makeWrapper appears to be needed only if cross-compiling
      makeWrapper      = null;

      enableCrypt      = false;

      config           = stdenv2nix-config;
      coreutils        = coreutils-3;
      zlib             = zlib-nixpkgs2;

      # copied from developer/interpreters/perl/default.nix;
      self             = perl538-interpreter-nixpkgs;
      version          = "5.38.2";
      sha256           = "sha256-oKMVNEUet7g8fWWUpJdUOlTUiLyQygD140diV39AZV4=";
    }).overrideAttrs(old: { });

in
let
#  perl-nixpkgs = perl-interpreter-nixpkgs.perl538;
  bison-nixpkgs = (callPackage (nixpkgspath + "/pkgs/development/tools/parsing/bison")
    {
      stdenv = stdenv2nix-minimal;
      fetchurl = stdenv2nix-minimal.fetchurlBoot;
      lib = nixpkgs.lib;
      m4 = nixpkgs.m4;
      perl = nixpkgs.perl;
      help2man = nixpkgs.help2man;
    }).overrideAttrs(
      old: {
        postConfigure = ''
        patchShebangs build-aux/move-if-change
        '';
      });

  bash-nixpkgs-0 = (callPackage (nixpkgspath + "/pkgs/shells/bash/5.nix")
    {
      fetchurl = stdenv2nix-minimal.fetchurlBoot;
      bison = nixpkgs.bison;
      texinfo = null;
    });

  texinfo-nixpkgs = (nixpkgs.callPackages (nixpkgspath + "/pkgs/development/tools/misc/texinfo/packages.nix")
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
  stage2pkgs                                  = stage2pkgs;
  stage3pkgs                                  = stage3pkgs;

  nxfs-autotools                              = nxfs-autotools;

  nixpkgs                                     = nixpkgs;
  which-3                                     = which-3;
  diffutils-3                                 = diffutils-3;
  findutils-3                                 = findutils-3;
  gnused-3                                    = gnused-3;
  gnugrep-3                                   = gnugrep-3;
  gnutar-3                                    = gnutar-3;
  bash-3                                      = bash-3;
  popen-3                                     = popen-3;
  gawk-3                                      = gawk-3;
  gnumake-3                                   = gnumake-3;
  coreutils-3                                 = coreutils-3;
  pkgconf-3                                   = pkgconf-3;
  m4-3                                        = m4-3;
  file-3                                      = file-3;
  zlib-3                                      = zlib-3;
  patchelf-3                                  = patchelf-3;
  gperf-3                                     = gperf-3;
  patch-3                                     = patch-3;
  gzip-3                                      = gzip-3;
  libxcrypt-3                                 = libxcrypt-3;
  perl-3                                      = perl-3;
  binutils-3                                  = binutils-3;
  autoconf-3                                  = autoconf-3;
  automake-3                                  = automake-3;
  flex-3                                      = flex-3;
  gmp-3                                       = gmp-3;
  bison-3                                     = bison-3;
  texinfo-3                                   = texinfo-3;
  mpfr-3                                      = mpfr-3;
  mpc-3                                       = mpc-3;
  python-3                                    = python-3;
  glibc-x1-3                                  = glibc-x1-3;
  gcc-x0-wrapper-3                            = gcc-x0-wrapper-3;
  binutils-x0-wrapper-3                       = binutils-x0-wrapper-3;
  gcc-x1-3                                    = gcc-x1-3;
  gcc-x1-wrapper-3                            = gcc-x1-wrapper-3;
  libstdcxx-x2-3                              = libstdcxx-x2-3;
  gcc-x2-wrapper-3                            = gcc-x2-wrapper-3;
  gcc-x3-3                                    = gcc-x3-3;
  gcc-wrapper-3                               = gcc-wrapper-3;
  bzip2-3                                     = bzip2-3;
  xz-3                                        = xz-3;
  openssl-3                                   = openssl-3;
  curl-3                                      = curl-3;
  cacert-3                                    = cacert-3;
  test-fetch-3                                = test-fetch-3;

  nxfs-bash-0                                 = import ./bootstrap/nxfs-bash-0;
  nxfs-coreutils-0                            = import ./bootstrap/nxfs-coreutils-0;
  nxfs-gnumake-0                              = import ./bootstrap/nxfs-gnumake-0;

  nxfs-toolchain-0                            = import ./bootstrap/nxfs-toolchain-0;
  nxfs-sysroot-0                              = import ./bootstrap/nxfs-sysroot-0;

  # pills-example-1..nxfs-bootstrap-1 :: derivation
  pills-example-1                             = import ./nix-pills/example1;

  nxfs-bootstrap-1                            = import ./bootstrap-1;
  nxfs-bootstrap-1-demo                       = import ./bootstrap-1-demo;

  nxfs-bash-1                                 = import ./bootstrap-1/nxfs-bash-1;
  nxfs-toolchain-1                            = import ./bootstrap-1/nxfs-toolchain-1;
  nxfs-sysroot-1                              = import ./bootstrap-1/nxfs-sysroot-1;

  # nxfs-bootstrap-2-demo :: attrset

  # nxfs-gcc-2 :: derivation    gcc, wrapped
  nxfs-bootstrap-2                            = import ./bootstrap-2;

  nxfs-gcc-wrapper-2                          = import ./bootstrap-2/nxfs-gcc-wrapper-2;
  nxfs-gcc-stage2-2                           = import ./bootstrap-2/nxfs-gcc-stage2-2;
  nxfs-glibc-stage1-2                         = import ./bootstrap-2/nxfs-glibc-stage1-2;
  nxfs-bash-2                                 = import ./bootstrap-2/nxfs-bash-2;
  nxfs-binutils-2                             = import ./bootstrap-2/nxfs-binutils-2;
  nxfs-coreutils-2                            = import ./bootstrap-2/nxfs-coreutils-2;
  nxfs-bootstrap-2-demo                       = import ./bootstrap-2-demo;

  nxfs-defs                                   = import ./bootstrap-1/nxfs-defs.nix;

  # ================================================================
  # bridge to nixpkgs
  # ----------------------------------------------------------------

  mkDerivation-3                              = mkDerivation-3;

  stdenv-stages                               = stdenv-stages;
  stdenv-nxfs                                 = stdenv-nxfs;
  stdenv2nix-no-cc                            = stdenv2nix-no-cc;
  stdenv2nix-minimal                          = stdenv2nix-minimal;

  bintools-wrapper-nixpkgs                    = bintools-wrapper-nixpkgs;
  gcc-wrapper-nixpkgs                         = gcc-wrapper-nixpkgs;

  # fetchurl-nixpkgs :: { url :: string, urls :: list[string], ... } -> ... store-path?
  fetchurl-nixpkgs                            = fetchurl-nixpkgs;

  # ================================================================
  # trying this the hard way...
  # adopting nixpkgs packages one at a time.
  # ----------------------------------------------------------------

  dieHook-nixpkgs2                            = nixpkgs.dieHook;

  gnu-config-nixpkgs                          = gnu-config-nixpkgs;
  gnu-config-nixpkgs2                         = gnu-config-nixpkgs2;
  updateAutotoolsGnuConfigScriptsHook-nixpkgs = updateAutotoolsGnuConfigScriptsHook-nixpkgs;
  zlib-nixpkgs2                               = zlib-nixpkgs2;
  zlib-nixpkgs                                = zlib-nixpkgs;
  xz-nixpkgs2                                 = xz-nixpkgs2;
  xz-nixpkgs                                  = xz-nixpkgs;
  gnum4-nixpkgs2                              = nixpkgs.gnum4;
  help2man-nixpkgs                            = help2man-nixpkgs;
  pkg-config-unwrapped-nixpkgs2               = pkg-config-unwrapped-nixpkgs2;
  pkg-config-unwrapped-nixpkgs                = pkg-config-unwrapped-nixpkgs;
  pkg-config-nixpkgs2                         = pkg-config-nixpkgs2;
  pkg-config-nixpkgs                          = pkg-config-nixpkgs;
  gettext-nixpkgs2                            = nixpkgs.gettext;
  gettext-nixpkgs                             = gettext-nixpkgs;
  ncurses-nixpkgs2                            = ncurses-nixpkgs2;
  ncurses-nixpkgs                             = ncurses-nixpkgs;
  perl536-nixpkgs2                            = nixpkgs.perl536;
  perl538-interpreter-nixpkgs                 = perl538-interpreter-nixpkgs;
  perl538-nixpkgs2                            = nixpkgs.perl538;
  perl-nixpkgs2                               = nixpkgs.perl;
  libxcrypt-nixpkgs2                          = nixpkgs.libxcrypt;

  patchelf-nixpkgs2                           = patchelf-nixpkgs2;
  patchelf-nixpkgs                            = patchelf-nixpkgs;
#  bzip2-nixpkgs2                             = bzip2-nixpkgs2;
  file-nixpkgs2                               = file-nixpkgs2;
  which-nixpkgs2                              = which-nixpkgs2;
  gzip-nixpkgs2                               = gzip-nixpkgs2;
  gzip-nixpkgs                                = gzip-nixpkgs;
#  texinfo-nixpkgs2                           = texinfo-nixpkgs2;
  texinfo-nixpkgs                             = texinfo-nixpkgs;
  bash-nixpkgs2                               = bash-nixpkgs2;
#  coreutils-nixpkgs2                         = coreutils-nixpkgs2;
#  perl-nixpkgs                               = perl-nixpkgs;
  bison-nixpkgs                               = bison-nixpkgs;
  bash-nixpkgs                                = bash-nixpkgs;
  cmake-minimal-nixpkgs                       = cmake-minimal-nixpkgs;
}
