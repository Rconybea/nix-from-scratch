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
  # stage2pkgs :: attrset -- all stage2 packages
  stage2pkgs = nxfspkgs.stage2pkgs;

  # nxfs-defs :: { target_tuple :: string }
  #   expect nxfs-defs.target_tuple="x86_64-pc-linux-gnu"
  #
  nxfs-defs = import ../bootstrap-1/nxfs-defs.nix;

#  # autotools eventually evaluates to derivation with defaults for:
#  #   .builder .args .baseInputs .buildInputs .system
#  # default builder requires pkgs.bash
#  #
#  # nxfs-autotools :: pkgs -> attrs -> derivation
#  nxfs-autotools = import ../build-support/autotools;

  linux-headers-2 = stage2pkgs.linux-headers-2;

  # TODO: use callPackage
  locale-archive-1 = import ../bootstrap-1/nxfs-locale-archive-1/default.nix;

  # make-stdenv :: attrset -> attrset+derivation
  make-stdenv = (import ../build-support/make-stdenv/make-stdenv.nix { config = config; });

  # stdenv interface
  stagepkgs-2 = {
    cc        = stage2pkgs.gcc-wrapper-2;
    bintools  = stage2pkgs.binutils-x0-wrapper-2;
    patchelf  = stage2pkgs.patchelf-2;
    patch     = stage2pkgs.patch-2;
    shell     = stage2pkgs.bash-2;
    coreutils = stage2pkgs.coreutils-2;
    gzip      = stage2pkgs.gzip-2;
    gnumake   = stage2pkgs.gnumake-2;
    gawk      = stage2pkgs.gawk-2;
    gnutar    = stage2pkgs.gnutar-2;
    gnugrep   = stage2pkgs.gnugrep-2;
    gnused    = stage2pkgs.gnused-2;
    findutils = stage2pkgs.findutils-2;
    diffutils = stage2pkgs.diffutils-2;
  };

  stdenv-2 = make-stdenv { name = "stdenv-2";
                           stagepkgs = stagepkgs-2; };

  # originally intended 'nxfsenv' to be a stdenv substitute.
  # instead it's grown into a kitchen sink.
  # try starting over as explicit stdenv, and we'll try to do better this time.
  #
  # We want to have:
  #   stdenv.cc
  #   stdenv.hasCC
  #   stdenv.cc.cc
  #   stdenv.cc.bintools
  #   stdenv.cc.libc
  #   stdenv.cc.libc.dev
  #   stdenv.cc.libc.static
  #
  #   stdenv.system + buildPlatform + hostPlatform + targetPlatform
  #
  #   stdenv.overrides
  #   stdenv.fetchurlBoot
  #   stdenv.initialPath
  #   stdenv.defaultBuildInputs + defaultNativeBuildInputs
  #

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

  # minimal substitute for nixpkgs buildEnv.
  # (many features omitted in return for much simpler implementation)
  #
  # buildEnv :: {name, paths, pathsToLink, coreutils} -> derivation
  #
  buildEnv = import ../lib/buildEnv.nix;
in
let
  callPackage = makeCallPackage nxfspkgs.stage3pkgs;
in
let
  # which-3 :: derivation
  which-3 = callPackage ../bootstrap-pkgs/which/package.nix { stdenv = stdenv-2;
                                                              stageid = "3";
                                                            };
  # diffutils-3 :: derivation
  diffutils-3 = callPackage ../bootstrap-pkgs/diffutils/package.nix { stdenv = stdenv-2;
                                                                      stageid = "3";
                                                                    };
in
let
  # findutils-3 :: derivation
  findutils-3 = callPackage ../bootstrap-pkgs/findutils/package.nix { stdenv = stdenv-2;
                                                                    stageid = "3"; };
in
let
  # gnused-3 :: derivation
  gnused-3 = callPackage ../bootstrap-pkgs/gnused/package.nix { stdenv = stdenv-2;
                                                                stageid = "3";
                                                              };
in
let
  # gnugrep-3 :: derivation
  gnugrep-3 = callPackage ../bootstrap-pkgs/gnugrep/package.nix { stdenv = stdenv-2;
                                                                  stageid = "3";
                                                                };
in
let
  # bzip2-3 :: derivation
  bzip2-3 = callPackage ./nxfs-bzip2-3/package.nix { stdenv = stdenv-2; };
in
let
  # gnutar-3    :: derivation
  gnutar-3 = callPackage ./nxfs-tar-3/package.nix { stdenv = stdenv-2;
                                                    bzip2 = bzip2-3;
                                                  };
in
let
  # bash-3 :: derivation
  bash-3 = callPackage ./nxfs-bash-3/package.nix { stdenv = stdenv-2; };
in
let
  # popen-template-3
  popen-template-3 = callPackage ../bootstrap-pkgs/popen-template/package.nix { stdenv = stdenv-2; };
  # popen-3     :: derivation
  popen-3 = callPackage ../bootstrap-pkgs/popen/package.nix { stdenv = stdenv-2;
                                                              popen-template = popen-template-3; };
in
let
  # gawk-3 :: derivation
  gawk-3 = callPackage ./nxfs-gawk-3/package.nix { stdenv = stdenv-2;
                                                   popen = popen-3;
                                                 };
in
let
  # gnumake-3   :: derivation
  gnumake-3 = callPackage ./nxfs-gnumake-3/package.nix { stdenv = stdenv-2; };
in
let
  # coreutils-3 :: derivation
  coreutils-3 = callPackage ./nxfs-coreutils-3/package.nix { stdenv = stdenv-2; };
in
let
  stagepkgs-3-1 = stagepkgs-2 // { shell     = bash-3;
                                   coreutils = coreutils-3;
                                   gnumake   = gnumake-3;
                                   gawk      = gawk-3;
                                   gnutar    = gnutar-3;
                                   gnugrep   = gnugrep-3;
                                   gnused    = gnused-3;
                                   findutils = findutils-3;
                                   diffutils = diffutils-3;
                                 };

  stdenv-3-1 = make-stdenv { name = "stdenv-3-1";
                             stagepkgs = stagepkgs-3-1; };

  # pkgconf-3 :: derivation
  pkgconf-3    = callPackage ./nxfs-pkgconf-3/package.nix { stdenv = stdenv-3-1; };
  # m4-3 :: derivation
  m4-3         = callPackage ./nxfs-m4-3/package.nix { stdenv = stdenv-3-1; };
  # file-3 :: derivation
  file-3       = callPackage ./nxfs-file-3/package.nix { stdenv = stdenv-3-1; };
  # zlib-3 :: derivation
  zlib-3       = callPackage ./nxfs-zlib-3/package.nix { stdenv = stdenv-3-1; };
  # gzip-3 :: derivation
  gzip-3       = callPackage ./nxfs-gzip-3/package.nix { stdenv = stdenv-3-1; };
  # patch-3 :: derivation
  patch-3      = callPackage ./nxfs-patch-3/package.nix { stdenv = stdenv-3-1; };
  # gperf-3 :: derivation
  gperf-3      = callPackage ./nxfs-gperf-3/package.nix { stdenv = stdenv-3-1; };
  # patchelf-3 :: derivation
  patchelf-3   = callPackage ./nxfs-patchelf-3/package.nix { stdenv = stdenv-3-1; };
in
let
  # libxcrypt-3 :: derivation
  libxcrypt-3  = callPackage ./nxfs-libxcrypt-3/package.nix { stdenv = stdenv-3-1;
                                                              perl = stage2pkgs.perl-2;
                                                              pkgconf = pkgconf-3;
                                                            };
in
let
  # perl-3 :: derivation
  perl-3 = callPackage ./nxfs-perl-3/package.nix { stdenv = stdenv-3-1;
                                                   libxcrypt = libxcrypt-3;
                                                   pkgconf = pkgconf-3;
                                                 };
in
let
  # binutils-3 :: derivation
  binutils-3 = callPackage ./nxfs-binutils-3/package.nix { stdenv = stdenv-3-1;
                                                           perl = perl-3; };

  # autoconf-3 :: derivation
  autoconf-3 = callPackage ./nxfs-autoconf-3/package.nix { stdenv = stdenv-3-1;
                                                           perl = perl-3;
                                                           m4 = m4-3;
                                                         };

in
let
  # autoconf-3 :: derivation
  automake-3 = callPackage ./nxfs-automake-3/package.nix { stdenv = stdenv-3-1;
                                                           autoconf = autoconf-3;
                                                           perl = perl-3;
                                                         };
in
let
  # flex-3 :: derivation
  flex-3 = callPackage ./nxfs-flex-3/package.nix { stdenv = stdenv-3-1;
                                                   m4 = m4-3;
                                                 };
  # gmp-3 :: derivation
  gmp-3 = callPackage ./nxfs-gmp-3/package.nix { stdenv = stdenv-3-1;
                                                 m4 = m4-3; };
  # mpfr-3 :: derivation
  mpfr-3 = callPackage ./nxfs-mpfr-3/package.nix { stdenv = stdenv-3-1;
                                                   gmp = gmp-3;
                                                 };
  # mpc-3 :: derivation
  mpc-3 = callPackage ./nxfs-mpc-3/package.nix { stdenv = stdenv-3-1;
                                                 gmp = gmp-3;
                                                 mpfr = mpfr-3; };

  # isl-3 :: derivation
  isl-3 = callPackage ./nxfs-isl-3/package.nix { stdenv = stdenv-3-1;
                                                 gmp = gmp-3;
                                               };

in
let
  # bison-3 :: derivation
  bison-3 = callPackage ./nxfs-bison-3/package.nix { stdenv = stdenv-3-1;
                                                     perl = perl-3;
                                                     flex = flex-3;
                                                     m4 = m4-3;
                                                   };
in
let
  # texinfo-3 :: derivation
  texinfo-3 = callPackage ./nxfs-texinfo-3/package.nix { stdenv = stdenv-3-1;
                                                         perl = perl-3;
                                                       };
in
let
  # python-3 :: derivation
  python-3 = callPackage ./nxfs-python-3/package.nix { stdenv = stdenv-3-1;
                                                       popen = popen-3;
                                                       zlib = zlib-3;
                                                     };
in
let
  # TODO: nxfs-nixify-glibc-source/package.nix
  #
  # nixify-glibc-source-3 :: (attrset -> derivation)
  #
  nixified-glibc-source-3 =
    callPackage ../bootstrap-2/nxfs-nixify-glibc-source/default.nix
      { python = python-3;
        coreutils = coreutils-3;
        findutils = findutils-3;
        bash = bash-3;
        grep = gnugrep-3;
        tar = gnutar-3;
        sed = gnused-3;
        locale-archive = locale-archive-1;
        nxfs-defs = nxfs-defs;
      };

  # glibc-targeted wrapper for sort -- invokes coreutils.sort with LC_ALL env var set to C.
  # Makes it convenient to kitbash glibc build to replace hardwired /bin/sort assumption
  #
  # lc-all-sort-3 :: derivation
  lc-all-sort-3 = callPackage ../bootstrap-pkgs/lc-all-sort/package.nix { stdenv = stdenv-3-1;
                                                                          coreutils = coreutils-3; };

  # glibc-x1-3 :: derivation
  glibc-x1-3 = callPackage ./nxfs-glibc-x1-3/package.nix { stdenv                = stdenv-3-1;
                                                           nixified-glibc-source = nixified-glibc-source-3;
                                                           lc-all-sort           = lc-all-sort-3;
                                                           locale-archive        = locale-archive-1;
                                                           linux-headers         = linux-headers-2;
                                                           python                = python-3;
                                                           bison                 = bison-3;
                                                           texinfo               = texinfo-3;
                                                           which                 = which-3;
                                                         };
in
let
  # TODO:: want stdenv.cc.cc here.
  #        Should be same as stage2pkgs.gcc-x3-2 = stage2pkgs.gcc-wrapper-2.cc
  #
  # gcc-x0-wrapper-3 :: derivation
  gcc-x0-wrapper-3 = callPackage ./nxfs-gcc-x0-wrapper-3/package.nix { stdenv = stdenv-3-1;
                                                                       gcc-unwrapped = stage2pkgs.gcc-x3-2;
                                                                       glibc = glibc-x1-3;
                                                                       nxfs-defs = nxfs-defs;
                                                                     };

  # binutils-x0-wrapper-3 :: derivation
  binutils-x0-wrapper-3 = callPackage ./nxfs-binutils-x0-wrapper-3/package.nix { stdenv = stdenv-3-1;
                                                                                 binutils = binutils-3;
                                                                                 glibc = glibc-x1-3;
                                                                               };

in
let
  # TODO: nxfs-nixify-gcc-source/package.nix
  #
  nixified-gcc-source-3 =
    callPackage ../bootstrap-2/nxfs-nixify-gcc-source/default.nix
      {
        bash      = bash-3;
        file      = file-3;
        findutils = findutils-3;
        sed       = gnused-3;
        grep      = gnugrep-3;
        tar       = gnutar-3;
        coreutils = coreutils-3;
        nxfs-defs = nxfs-defs;
      };

  # gcc-x1-3 :: derivation
  gcc-x1-3 = callPackage ./nxfs-gcc-x1-3/package.nix
    {
      stdenv               = stdenv-3-1;
      nixified-gcc-source  = nixified-gcc-source-3;
      binutils-wrapper     = binutils-x0-wrapper-3;
      mpc                  = mpc-3;
      mpfr                 = mpfr-3;
      gmp                  = gmp-3;
      isl                  = isl-3;
      bison                = bison-3;
      flex                 = flex-3;
      texinfo              = texinfo-3;
      m4                   = m4-3;
      glibc                = glibc-x1-3;
      nxfs-defs            = nxfs-defs;
    };

  # gcc-stage2-wrapper-3 :: derivation
  gcc-x1-wrapper-3 = callPackage ./nxfs-gcc-x1-wrapper-3/package.nix { stdenv = stdenv-3-1;
                                                                       gcc-unwrapped = gcc-x1-3;
                                                                       glibc = glibc-x1-3;
                                                                       nxfs-defs = nxfs-defs;
                                                                     };
in
let
  # libstdcxx-x2-3 :: derivation
  libstdcxx-x2-3 = callPackage ./nxfs-libstdcxx-x2-3/package.nix
    {
      stdenv               = stdenv-3-1;
      gcc-wrapper          = gcc-x1-wrapper-3;
      binutils-wrapper     = binutils-x0-wrapper-3;
      glibc                = glibc-x1-3;
      nixified-gcc-source  = nixified-gcc-source-3;
      nxfs-defs            = nxfs-defs;
    };
in
let
  # gcc-stage3-wrapper-3 :: derivation
  gcc-x2-wrapper-3 = callPackage ./nxfs-gcc-x2-wrapper-3/package.nix
    {
      stdenv        = stdenv-3-1;
      gcc-unwrapped = gcc-x1-3;
      libstdcxx     = libstdcxx-x2-3;
      glibc         = glibc-x1-3;
      nxfs-defs     = nxfs-defs;
    };
in
let

  # gcc-x3-3 :: derivation
  gcc-x3-3 = callPackage ./nxfs-gcc-x3-3/package.nix
    { stdenv              = stdenv-3-1;
      nixified-gcc-source = nixified-gcc-source-3;
      gcc-wrapper         = gcc-x2-wrapper-3;
      binutils-wrapper    = binutils-x0-wrapper-3;
      mpc                 = mpc-3;
      mpfr                = mpfr-3;
      gmp                 = gmp-3;
      bison               = bison-3;
      flex                = flex-3;
      texinfo             = texinfo-3;
      m4                  = m4-3;
      glibc               = glibc-x1-3;
      nxfs-defs           = nxfs-defs;
    };
in
let
  # gcc-wrapper-3 :: derivation
  gcc-wrapper-3 = callPackage ./nxfs-gcc-wrapper-3/package.nix { stdenv = stdenv-3-1;
                                                                 bintools = binutils-x0-wrapper-3;
                                                                 gcc-unwrapped = gcc-x3-3;
                                                                 glibc = glibc-x1-3;
                                                                 nxfs-defs = nxfs-defs;
                                                                 };
in
let
  stage3env = buildEnv {
    name = "stage3env";
    paths = [ gcc-wrapper-3
              gcc-x3-3
              binutils-x0-wrapper-3
              python-3
              texinfo-3
              isl-3
              mpc-3
              mpfr-3
              gmp-3
              bison-3
              flex-3
              automake-3
              autoconf-3
              binutils-3
              perl-3
              libxcrypt-3
              patchelf-3
              gperf-3
              patch-3
              gzip-3
              zlib-3
              file-3
              m4-3
              pkgconf-3
              coreutils-3
              gnumake-3
              gawk-3
              popen-3
              bash-3
              gnutar-3
              bzip2-3
              gnugrep-3
              gnused-3
              findutils-3
              diffutils-3
              which-3
            ];
      coreutils = coreutils-3;
    };
in
  {
    inherit stage3env;
    inherit gcc-wrapper-3;
    inherit gcc-x3-3;
    inherit gcc-x2-wrapper-3;
    inherit libstdcxx-x2-3;
    inherit gcc-x1-wrapper-3;
    inherit gcc-x1-3;
    inherit binutils-x0-wrapper-3;
    inherit gcc-x0-wrapper-3;
    inherit glibc-x1-3;
    inherit lc-all-sort-3;
    inherit python-3;
    inherit texinfo-3;
    inherit isl-3;
    inherit mpc-3;
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
