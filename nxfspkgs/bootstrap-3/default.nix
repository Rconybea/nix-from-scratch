# linux-x86 stdenv should have:
#   gcc, g++    (will be gcc wrapper, needs to know where binutils is)
#   gcc-unwrapped
#   binutils-unwrapped
#   glibc
#   diffutils
#   findutils
#   coreutils
#   gnused
#   gnugrep
#   gnuawk
#   gnutar
#   gzip        + bzip2 + xz
#   gnumake
#   bash
#   patch
#   patchelf
#   attr
#   acl
#   zlib
#   libidn2
#   libunistring
#   linuxHeaders
#   pkgconf          # idc if nixpkgs has this.  we want it
#   (something called fortify-headers)
#   gmp
#   ed
#   gnugrep.pcre2
#   gawk.libsigsegv
#   gettext
#   gnum4
#   bison
#   perl
#   texinfo
#
# Things I should therefore remove (and provide separately)
#   python
#   gperf
#   file
#   pkgconf
let
  # nxfspkgs :: attrset (kitchen sink, mostly derivations)
  nxfspkgs = import <nxfspkgs> {};

  bootstrap-1 = nxfspkgs.nxfs-bootstrap-1;
  bootstrap-2 = nxfspkgs.nxfs-bootstrap-2;

  nxfs-defs = import ./nxfs-defs.nix;
in

let
  # locale archive copied from toolchain.
  locale-archive-1 = bootstrap-1.nxfs-locale-archive-1;
  sysroot-1 = bootstrap-1.nxfs-sysroot-1;
  lc-all-sort-2 = bootstrap-2.nxfs-lc-all-sort-2;
  libstdcxx-2 = bootstrap-2.nxfs-libstdcxx-stage2-2;
  popen-template = bootstrap-2.nxfs-popen-template-2;
in

let
  # allPkgs :: attrset
  allPkgs = nxfspkgs // envpkgs;

  # like a nixpkgs stdenv, but for nix-from-scratch bootstrap stage 2
  nxfsenv = {
    # mkDerivation  :: attrs -> derivation
    mkDerivation = nxfspkgs.nxfs-autotools allPkgs;
    # gcc .. glibc :: derivation
    gcc-wrapper  = bootstrap-2.nxfs-gcc-wrapper-2;
    gcc_wrapper  = bootstrap-2.nxfs-gcc-wrapper-2;
    gcc          = bootstrap-2.nxfs-gcc-stage2-2;
    libstdcxx    = bootstrap-2.nxfs-libstdcxx-stage2-2;
    gcc-stage1   = bootstrap-2.nxfs-gcc-stage1-2;
    glibc-stage1 = bootstrap-2.nxfs-glibc-stage1-2;
    binutils     = bootstrap-2.nxfs-binutils-2;
    bison        = bootstrap-2.nxfs-bison-2;
    flex         = bootstrap-2.nxfs-flex-2;
    texinfo      = bootstrap-2.nxfs-texinfo-2;
    m4           = bootstrap-2.nxfs-m4-2;
    python       = bootstrap-2.nxfs-python-2;
    perl         = bootstrap-2.nxfs-perl-2;
    gperf        = bootstrap-2.nxfs-gperf-2;
    patch        = bootstrap-2.nxfs-patch-2;
    patchelf     = bootstrap-2.nxfs-patchelf-2;
    gzip         = bootstrap-2.nxfs-gzip-2;
    bash         = bootstrap-2.nxfs-bash-2;
    gawk         = bootstrap-2.nxfs-gawk-2;
    gnumake      = bootstrap-2.nxfs-gnumake-2;
    gnugrep      = bootstrap-2.nxfs-grep-2;
    gnutar       = bootstrap-2.nxfs-tar-2;
    gnused       = bootstrap-2.nxfs-sed-2;
    coreutils    = bootstrap-2.nxfs-coreutils-2;
    file         = bootstrap-2.nxfs-file-2;
    findutils    = bootstrap-2.nxfs-findutils-2;
    diffutils    = bootstrap-2.nxfs-diffutils-2;
    glibc        = bootstrap-2.nxfs-glibc-stage1-2;
    # nxfs-defs    :: { target_tuple :: string }
    nxfs-defs    = nxfs-defs;
  };

  # envpkgs :: attrset
  envpkgs = {
    # using this to attach 'nxfsenv' as top-level attribute of <nxfspkgs>,
    # to supply corresponding nxfsenv argument in each bootstrap-3/*.nix
    #
    nxfsenv = nxfsenv;
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

in

let
  nxfsenv-3-0 = { nxfs-defs = nxfs-defs; };

  # which-3 :: derivation
  which-3 = callPackage ./nxfs-which-3 {};

  # diffutils-3 :: derivation
  diffutils-3 = callPackage ./nxfs-diffutils-3 {};
in

let
  nxfsenv-3-1 = nxfsenv-3-0 // { diffutils = diffutils-3; };

  # findutils-3 :: derivation
  findutils-3 = callPackage ./nxfs-findutils-3 { nxfsenv-3 = nxfsenv-3-1; };
in

let
  nxfsenv-3-2 = nxfsenv-3-1 // { findutils = findutils-3; };

  # gnused-3    :: derivation
  gnused-3 = callPackage ./nxfs-sed-3 { nxfsenv-3 = nxfsenv-3-2; };
in

let
  nxfsenv-3-3 = nxfsenv-3-2 // { gnused = gnused-3; };

  # gnugrep-3   :: derivation
  gnugrep-3 = callPackage ./nxfs-grep-3 { nxfsenv-3 = nxfsenv-3-3; };
in

let
  nxfsenv-3-4 = nxfsenv-3-3 // { gnugrep = gnugrep-3; };

  # gnutar-3    :: derivation
  gnutar-3 = callPackage ./nxfs-tar-3 { nxfsenv-3 = nxfsenv-3-4; };
in

let
  nxfsenv-3-5 = nxfsenv-3-4 // { gnutar = gnutar-3; };

  # gnubash-3   :: derivation
  bash-3 = callPackage ./nxfs-bash-3 { nxfsenv-3 = nxfsenv-3-5; };
in

let
  nxfsenv-3-6 = nxfsenv-3-5 // { bash = bash-3; };

  # popen-3     :: derivation
  popen-3 = callPackage ./nxfs-popen-3 { nxfsenv-3 = nxfsenv-3-6;
                                         popen-template = popen-template; };
in

let
  # (reminder: popen doesn't belong in stdenv)
  nxfsenv-3-7 = nxfsenv-3-6;

  # gawk-3      :: derivation
  gawk-3 = callPackage ./nxfs-gawk-3 { nxfsenv-3 = nxfsenv-3-6;
                                       popen = popen-3;
                                     };
in

let
  nxfsenv-3-8 = nxfsenv-3-7 // { gawk = gawk-3; };

  # gnumake-3   :: derivation
  gnumake-3 = callPackage ./nxfs-gnumake-3 { nxfsenv-3 = nxfsenv-3-8; };
in

let
  nxfsenv-3-9 = nxfsenv-3-8 // { gnumake = gnumake-3; };

  # coreutils-3 :: derivation
  coreutils-3 = callPackage ./nxfs-coreutils-3 { nxfsenv-3 = nxfsenv-3-9; };
in

let
  nxfsenv-3-10 = nxfsenv-3-9 // { coreutils = coreutils-3; };

  # pkgconf-3 :: derivation
  pkgconf-3    = callPackage ./nxfs-pkgconf-3  { nxfsenv-3 = nxfsenv-3-10; };
  # m4-3 :: derivation
  m4-3         = callPackage ./nxfs-m4-3       { nxfsenv-3 = nxfsenv-3-10; };
  # file-3 :: derivation
  file-3       = callPackage ./nxfs-file-3     { nxfsenv-3 = nxfsenv-3-10; };
  # zlib-3 :: derivation
  zlib-3       = callPackage ./nxfs-zlib-3     { nxfsenv-3 = nxfsenv-3-10; };
  # patchelf-3 :: derivation
  patchelf-3   = callPackage ./nxfs-patchelf-3 { nxfsenv-3 = nxfsenv-3-10; };
  # gperf-3 :: derivation
  gperf-3      = callPackage ./nxfs-gperf-3    { nxfsenv-3 = nxfsenv-3-10; };
  # patch-3 :: derivation
  patch-3      = callPackage ./nxfs-patch-3    { nxfsenv-3 = nxfsenv-3-10; };
  # gzip-3 :: derivation
  gzip-3       = callPackage ./nxfs-gzip-3     { nxfsenv-3 = nxfsenv-3-10; };
in

let
  nxfsenv-3-a11 = nxfsenv-3-10 // { pkgconf = pkgconf-3; };

  # libxcrypt-3 :: derivation
  libxcrypt-3 = callPackage ./nxfs-libxcrypt-3 { nxfsenv-3 = nxfsenv-3-a11; };
in

let
  # (reminder: libxcrypt doesn't belong in stdenv)
  nxfsenv-3-a12 = nxfsenv-3-a11;

  # perl-3 :: derivation
  perl-3 = callPackage ./nxfs-perl-3 { nxfsenv-3 = nxfsenv-3-a12;
                                       libxcrypt = libxcrypt-3; };
in

let
  nxfsenv-3-b13 = nxfsenv-3-a12 // { m4 = m4-3;
                                     perl = perl-3; };

  # binutils-3 :: derivation
  binutils-3 = callPackage ./nxfs-binutils-3 { nxfsenv-3 = nxfsenv-3-b13;
                                               libxcrypt = libxcrypt-3; };
  # autoconf-3 :: derivation
  autoconf-3 = callPackage ./nxfs-autoconf-3 { nxfsenv-3 = nxfsenv-3-b13; };
in

let
  nxfsenv-3-b14 = nxfsenv-3-b13 // { autoconf = autoconf-3; };

  # automake-3 :: derivation
  automake-3 = callPackage ./nxfs-automake-3 { nxfsenv-3 = nxfsenv-3-b14; };
in

let
  nxfsenv-3-c13 = nxfsenv-3-b13 // { file = file-3; };

  # flex-3 :: derivation
  flex-3 = callPackage ./nxfs-flex-3 { nxfsenv-3 = nxfsenv-3-c13; };

  # gmp-3 :: derivation
  gmp-3 = callPackage ./nxfs-gmp-3 { nxfsenv-3 = nxfsenv-3-c13; };
in

let
  nxfsenv-3-c14 = nxfsenv-3-c13 // { flex = flex-3; };

  # bison-3 :: derivation
  bison-3 = callPackage ./nxfs-bison-3 { nxfsenv-3 = nxfsenv-3-c14; };
in

let
  nxfsenv-3-b15 = nxfsenv-3-b14 // nxfsenv-3-c14 // { bison = bison-3; };

  # texinfo-3 :: derivation
  texinfo-3 = callPackage ./nxfs-texinfo-3 { nxfsenv-3 = nxfsenv-3-b15; };
in

let
  # (reminder: gmp not exposed in stdenv)

  # mpfr-3 :: derivation
  mpfr-3 = callPackage ./nxfs-mpfr-3 { nxfsenv-3 = nxfsenv-3-b13;
                                       gmp = gmp-3;
                                     };

in

let
  # (reminder: mpfr not exposed in stdenv)

  # mpc-3 :: derivation
  mpc-3 = callPackage ./nxfs-mpc-3 { nxfsenv-3 = nxfsenv-3-c13;
                                     gmp = gmp-3;
                                     mpfr = mpfr-3; };

in

let
  nxfsenv-3-d13 = nxfsenv-3-10 // { pkgconf = pkgconf-3;
                                    zlib = zlib-3; };

  # python-3 :: derivation
  python-3 = callPackage ./nxfs-python-3 { nxfsenv-3 = nxfsenv-3-d13;
                                           popen = popen-3;
                                         };

in

#############################################################################################3
# gcc stack below ignores the stage-3 stuff above and rehearses the
# stage-2 glibc->gcc(1)->libstdcxx->gcc(2) pipeline.
#
# This because "something awry" with previous attempts,  so retrying more deliberately.
#############################################################################################3

let
  nxfsenv-3-16 = nxfsenv-3-10 // { texinfo  = texinfo-3;
                                   bison    = bison-3;
                                   flex     = flex-3;
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

  glibc-x1-3 = callPackage ./nxfs-glibc-x1-3 { nxfsenv-3         = nxfsenv-3-94;
                                               nixify-glibc-source = bootstrap-2.nxfs-nixify-glibc-source;
                                               lc-all-sort       = bootstrap-2.nxfs-lc-all-sort-2;
                                               locale-archive    = bootstrap-1.nxfs-locale-archive-1;
                                               toolchain-wrapper = bootstrap-1.nxfs-toolchain-wrapper-1;
                                               toolchain         = bootstrap-1.nxfs-toolchain-1;
                                               sysroot           = bootstrap-1.nxfs-sysroot-1;
                                             };
in

let
  nxfsenv-3-95 = nxfsenv-3-94 // { glibc-stage1 = glibc-x1-3; };

  # wraps bootstrap-1.nxfs-toolchain-1.gcc + bootstrap-2.glibc-stage1
  # TODO: switch glibc to nxfsenv-3.glibc-stage1, but also will need to touch libstdcxx-stage2-3 dep
  gcc-stage1-wrapper-3 = callPackage ./nxfs-gcc-stage1-wrapper-3 { nxfsenv-3 = nxfsenv-3-95;
                                                                   glibc = glibc-x1-3;
                                                                   bootstrap-1 = bootstrap-1;
                                                                 };

in

let
  nxfsenv-3-96 = nxfsenv-3-95 // { };

  # gcc-stage1-3 :: derivation
  gcc-stage1-3 = callPackage ./nxfs-gcc-stage1-3 { nxfsenv-3            = nxfsenv-3-96;
                                                   gcc-stage1-wrapper-3 = gcc-stage1-wrapper-3;
                                                   mpc                  = bootstrap-2.nxfs-mpc-2;
                                                   mpfr                 = bootstrap-2.nxfs-mpfr-2;
                                                   gmp                  = bootstrap-2.nxfs-gmp-2;
                                                   nixify-gcc-source    = bootstrap-2.nxfs-nixify-gcc-source;
                                                   glibc                = glibc-x1-3;
                                                   toolchain            = bootstrap-1.nxfs-toolchain-1;
                                                   sysroot              = bootstrap-1.nxfs-sysroot-1;
                                                 };
in

let
  nxfsenv-3-97 = nxfsenv-3-96 // { gcc-stage1 = gcc-stage1-3;
                                 };

  # gcc-stage2-wrapper-3 :: derivation
  gcc-stage2-wrapper-3 = callPackage ./nxfs-gcc-stage2-wrapper-3 { nxfsenv-3 = nxfsenv-3-97;
                                                                   glibc = glibc-x1-3;
                                                                   bootstrap-1 = bootstrap-1;
                                                                 };
in

let
  nxfsenv-3-98 = nxfsenv-3-97 // { };

  # libstdcxx-stage2-3 :: derivation
  libstdcxx-stage2-3 = callPackage ./nxfs-libstdcxx-stage2-3 { nxfsenv-3            = nxfsenv-3-98;
                                                               gcc-stage2-wrapper-3 = gcc-stage2-wrapper-3;
                                                               nixify-gcc-source    = bootstrap-2.nxfs-nixify-gcc-source;
                                                               glibc                = glibc-x1-3;
                                                               mpc                  = bootstrap-2.nxfs-mpc-2;
                                                               mpfr                 = bootstrap-2.nxfs-mpfr-2;
                                                               gmp                  = bootstrap-2.nxfs-gmp-2;
                                                             };
in

let
  nxfsenv-3-99 = nxfsenv-3-98 // { libstdcxx = libstdcxx-stage2-3; };

  # gcc-stage3-wrapper-3 :: derivation
  gcc-stage3-wrapper-3 = callPackage ./nxfs-gcc-stage3-wrapper-3 { nxfsenv-3     = nxfsenv-3-99;
                                                                   gcc-unwrapped = gcc-stage1-3; # was nxfsenv.gcc-stage1;
                                                                   libstdcxx     = libstdcxx-stage2-3;
                                                                   glibc         = glibc-x1-3;
                                                                 };
in

let
  # gcc-stage2-3 :: derivation
  gcc-stage2-3 = callPackage ./nxfs-gcc-stage2-3 { nxfsenv-3         = nxfsenv-3-99;
                                                   nixify-gcc-source = bootstrap-2.nxfs-nixify-gcc-source;
                                                   gcc-wrapper       = gcc-stage3-wrapper-3;
                                                   binutils-wrapper  = bootstrap-2.nxfs-binutils-stage1-wrapper-2;
                                                   mpc               = bootstrap-2.nxfs-mpc-2;
                                                   mpfr              = bootstrap-2.nxfs-mpfr-2;
                                                   gmp               = bootstrap-2.nxfs-gmp-2;
                                                   glibc             = glibc-x1-3;
                                                   #toolchain         = bootstrap-1.nxfs-toolchain-1;
                                                   sysroot           = bootstrap-1.nxfs-sysroot-1;  # for linux headers
                                                 };
in

let
  nxfsenv-3-100 = nxfsenv-3-99 // { gcc-stage2-3 = gcc-stage2-3; };

  # gcc-wrapper-3 :: derivation
  gcc-wrapper-3 = callPackage ./nxfs-gcc-wrapper-3 { nxfsenv-3 = nxfsenv-3-100;
                                                     gcc-unwrapped = gcc-stage2-3;
                                                     glibc = glibc-x1-3;
                                                   };

in

{
  nxfsenv-3 = nxfsenv-3-100 // { gcc-wrapper-3 = gcc-wrapper-3; };

  gcc-wrapper-3 = gcc-wrapper-3;
  gcc-stage2-3 = gcc-stage2-3;
  gcc-stage3-wrapper-3 = gcc-stage3-wrapper-3;
  libstdcxx-stage2-3 = libstdcxx-stage2-3;
  gcc-stage2-wrapper-3 = gcc-stage2-wrapper-3;
  gcc-stage1-3 = gcc-stage1-3;
  gcc-stage1-wrapper-3 = gcc-stage1-wrapper-3;
  glibc-x1-3 = glibc-x1-3;

#  libstdcxx-s2-3        = libstdcxx-s2-3;
#  gcc-s1-wrapper-3      = gcc-s1-wrapper-3;
#  gcc-s1-3              = gcc-s1-3;
#  binutils-s1-wrapper-3 = binutils-s1-wrapper-3;
#  glibc-3               = glibc-3;

  binutils-3            = binutils-3;

  texinfo-3             = texinfo-3;

  automake-3            = automake-3;
  autoconf-3            = autoconf-3;

  bison-3               = bison-3;
  flex-3                = flex-3;

  m4-3                  = m4-3;
  perl-3                = perl-3;
  libxcrypt-3           = libxcrypt-3;
  pkgconf-3             = pkgconf-3;

  mpc-3                 = mpc-3;
  mpfr-3                = mpfr-3;
  gmp-3                 = gmp-3;

  python-3              = python-3;

  zlib-3                = zlib-3;
  file-3                = file-3;
  gzip-3                = gzip-3;
  patch-3               = patch-3;
  gperf-3               = gperf-3;
  patchelf-3            = patchelf-3;

  coreutils-3           = coreutils-3;
  gnumake-3             = gnumake-3;
  gawk-3                = gawk-3;
  popen-3               = popen-3;
  bash-3                = bash-3;
  gnutar-3              = gnutar-3;
  gnugrep-3             = gnugrep-3;
  gnused-3              = gnused-3;
  findutils-3           = findutils-3;
  diffutils-3           = diffutils-3;
  which-3               = which-3;
}
