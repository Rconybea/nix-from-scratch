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
#    gperf        = import ./bootstrap-2/nxfs-gperf-2;
#    patchelf     = import ./bootstrap-2/nxfs-patchelf-2;
    perl         = import ./bootstrap-2/nxfs-perl-2;
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
  nxfsenv-3-4 = nxfsenv-3-3 // { gnugrep = gnugrep-3; };
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
  gcc-wrapper-3  = bootstrap-3.gcc-wrapper-3;
  glibc-stage1-3 = bootstrap-3.glibc-stage1-3;
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
  nxfsenv-3-d13 = nxfsenv-3-10 // { pkgconf = pkgconf-3;
                                    zlib = zlib-3; };
  # python-3 :: derivation
  python-3 = callPackage ./bootstrap-3/nxfs-python-3 { nxfsenv-3 = nxfsenv-3-d13;
                                                       popen = popen-3;
                                                     };
in
let
  nxfsenv-3-16 = nxfsenv-3-10 // { texinfo  = texinfo-3;
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
      mpc                  = mpc-3; #bootstrap-2.nxfs-mpc-2;
      mpfr                 = mpfr-3; #bootstrap-2.nxfs-mpfr-2;
      gmp                  = gmp-3; #bootstrap-2.nxfs-gmp-2;
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
      mpc                  = mpc-3; #bootstrap-2.nxfs-mpc-2;
      mpfr                 = mpfr-3; #bootstrap-2.nxfs-mpfr-2;
      gmp                  = gmp-3; #bootstrap-2.nxfs-gmp-2;
    };
in
let
  nxfsenv-3-99 = nxfsenv-3-98 // { libstdcxx = libstdcxx-x2-3; };
  # gcc-stage3-wrapper-3 :: derivation
  gcc-stage3-wrapper-3 = callPackage ./bootstrap-3/nxfs-gcc-stage3-wrapper-3
    { nxfsenv-3     = nxfsenv-3-99;
      gcc-unwrapped = gcc-x1-3;
      libstdcxx     = libstdcxx-x2-3;
      glibc         = glibc-stage1-3;
    };
in
let
  # gcc-stage2-3 :: derivation
  gcc-stage2-3 = callPackage ./bootstrap-3/nxfs-gcc-stage2-3
    { nxfsenv-3         = nxfsenv-3-99;
      nixify-gcc-source = bootstrap-2.nxfs-nixify-gcc-source;
      gcc-wrapper       = gcc-stage3-wrapper-3;
      binutils-wrapper  = bootstrap-2.nxfs-binutils-stage1-wrapper-2;
      mpc               = bootstrap-2.nxfs-mpc-2;
      mpfr              = bootstrap-2.nxfs-mpfr-2;
      gmp               = bootstrap-2.nxfs-gmp-2;
      glibc             = glibc-stage1-3;
      sysroot           = bootstrap-1.nxfs-sysroot-1;  # for linux headers
    };
in
let
  nxfsenv-3-100 = nxfsenv-3-99 // { gcc-stage2-3 = gcc-stage2-3; };

  # gcc-wrapper-3 :: derivation
  gcc-wrapper-3 = callPackage ./bootstrap-3/nxfs-gcc-wrapper-3
    { nxfsenv-3 = nxfsenv-3-100;
      gcc-unwrapped = gcc-stage2-3;
      glibc = glibc-stage1-3;
    };

in

let
  mkDerivation-3 = (nxfs-autotools (allPkgs // { nxfsenv = { bash = bash-3; }; }));

  # TODO: need {xz bzip2}
  #
  stdenv-nxfs = callPackage ./stdenv { gcc          = gcc-wrapper-3;
                                       glibc        = glibc-stage1-3;
                                       patchelf     = patchelf-3;
                                       patch        = patch-3;
                                       file         = file-3;
                                       gnumake      = gnumake-3;
                                       gzip         = gzip-3;
                                       gnutar       = gnutar-3;
                                       gawk         = gawk-3;
                                       gnugrep      = gnugrep-3;
                                       gnused       = gnused-3;
                                       coreutils    = coreutils-3;
                                       findutils    = findutils-3;
                                       diffutils    = diffutils-3;
                                       bash         = bash-3;
                                       which        = which-3;
                                       mkDerivation = mkDerivation-3; };
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
  gcc-stage3-wrapper-3 = gcc-stage3-wrapper-3;
  gcc-stage2-3         = gcc-stage2-3;
  gcc-wrapper-3        = gcc-wrapper-3;

  # pills-example-1..nxfs-bootstrap-1 :: derivation
  pills-example-1       = import ./nix-pills/example1;

  nxfs-bash-0           = import ./bootstrap/nxfs-bash-0;
  nxfs-coreutils-0      = import ./bootstrap/nxfs-coreutils-0;
  nxfs-gnumake-0        = import ./bootstrap/nxfs-gnumake-0;

  nxfs-toolchain-0      = import ./bootstrap/nxfs-toolchain-0;
  nxfs-sysroot-0        = import ./bootstrap/nxfs-sysroot-0;

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
  nxfs-bash-2           = import ./bootstrap-2/nxfs-bash-2;
  nxfs-binutils-2       = import ./bootstrap-2/nxfs-binutils-2;
  nxfs-coreutils-2      = import ./bootstrap-2/nxfs-coreutils-2;
  nxfs-bootstrap-2-demo = import ./bootstrap-2-demo;

  nxfs-defs             = import ./bootstrap-1/nxfs-defs.nix;

  stdenv-nxfs           = stdenv-nxfs;
}
