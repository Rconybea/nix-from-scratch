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
    # {cc, bintools, shell, coreutils} clear of early-bootstrap refs
    cc        = stage2pkgs.gcc-wrapper-2;
    bintools  = stage2pkgs.binutils-wrapper-2;
    shell     = stage2pkgs.bash-from-boot-2;
    coreutils = stage2pkgs.coreutils-from-boot-2;

    # {patchelf .. diffutils} have deps extending back to imported toolchain
    patchelf  = stage2pkgs.patchelf-2;
    patch     = stage2pkgs.patch-2;
    gzip      = stage2pkgs.gzip-2;
    xz        = stage2pkgs.xz-2;
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
  bzip2-3 = callPackage ../bootstrap-pkgs/bzip2/package.nix { stdenv = stdenv-2;
                                                              stageid = "3";
                                                            };
in
let
  # gnutar-3 :: derivation
  gnutar-3 = callPackage ../bootstrap-pkgs/gnutar/package.nix { stdenv = stdenv-2;
                                                                bzip2 = bzip2-3;
                                                                stageid = "3";
                                                              };
in
let
  # NOTE: not using ncurses-3 at present
  # ncurses-3 :: derivation
  ncurses-3 = callPackage ../bootstrap-pkgs/ncurses/package.nix { stdenv = stdenv-2;
                                                                  stageid = "3";
                                                                };
in
let
  # bash-3 :: derivation
  bash-3 = callPackage ../bootstrap-pkgs/bash/package.nix { stdenv = stdenv-2;
                                                            stageid = "3";
                                                          };
in
let
  # popen-template-3 :: derivation
  popen-template-3 = callPackage ../bootstrap-pkgs/popen-template/package.nix { stdenv = stdenv-2;
                                                                                stageid = "3";
                                                                              };
  # popen-3 :: derivation
  popen-3 = callPackage ../bootstrap-pkgs/popen/package.nix { stdenv = stdenv-2;
                                                              popen-template = popen-template-3;
                                                              stageid = "3";
                                                            };
in
let
  # gawk-3 :: derivation
  gawk-3 = callPackage ../bootstrap-pkgs/gawk/package.nix { stdenv = stdenv-2;
                                                            popen = popen-3;
                                                            stageid = "3";
                                                          };
in
let
  # gnumake-3   :: derivation
  gnumake-3 = callPackage
    ../bootstrap-pkgs/gnumake/package.nix { stdenv = stdenv-2;
                                            stageid = "3"; };
in
let
  # coreutils-3 :: derivation
  coreutils-3 = callPackage
    ../bootstrap-pkgs/coreutils/package.nix { stdenv = stdenv-2;
                                              stageid = "3"; };
in
let
  # patch-3 :: derivation
  patch-3      = callPackage
    ../bootstrap-pkgs/patch/package.nix { stdenv = stdenv-2;
                                          stageid = "3";
                                        };

  # pkgconf-3 :: derivation
  pkgconf-3    = callPackage
    ../bootstrap-pkgs/pkgconf/package.nix { stdenv = stdenv-2;
                                            stageid = "3"; };

  # m4-3 :: derivation
  m4-3         = callPackage
    ../bootstrap-pkgs/m4/package.nix { stdenv = stdenv-2;
                                       stageid = "3"; };

  # file-3 :: derivation
  file-3       = callPackage
    ../bootstrap-pkgs/file/package.nix { stdenv = stdenv-2;
                                         stageid = "3"; };
  # zlib-3 :: derivation
  zlib-3       = callPackage
    ../bootstrap-pkgs/zlib/package.nix { stdenv = stdenv-2;
                                         stageid = "3"; };
  # patchelf-3 :: derivation
  patchelf-3   = callPackage
    ../bootstrap-pkgs/patchelf/package.nix { stdenv = stdenv-2;
                                             stageid = "3"; };
  # gzip-3 :: derivation
  gzip-3       = callPackage
    ../bootstrap-pkgs/gzip/package.nix { stdenv = stdenv-2;
                                         stageid = "3"; };
  # xz-3 :: derivation
  xz-3 = callPackage
    ../bootstrap-pkgs/xz/package.nix { stdenv = stdenv-2;
                                       stageid = "3";
                                     };

  # gperf-3 :: derivation
  gperf-3      = callPackage
    ../bootstrap-pkgs/gperf/package.nix { stdenv = stdenv-2;
                                          stageid = "3"; };
in
let
  # stdenv interface
  # no stagepkgs-3-1 members have any pre-bootstrap runtime deps.
  #
  # It follows that going forward, remaining packages have no runtime *or build-time*
  # pre-bootstrap deps.
  #
  stagepkgs-3-1 = stagepkgs-2 // { patchelf  = patchelf-3;
                                   patch     = patch-3;
                                   gzip      = gzip-3;
                                   xz        = xz-3;
                                   shell     = bash-3;
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

in
let
  # libxcrypt-3 :: derivation
  libxcrypt-3  = callPackage ../bootstrap-pkgs/libxcrypt/package.nix { stdenv = stdenv-3-1;
                                                                       perl = stage2pkgs.perl-2;
                                                                       pkgconf = pkgconf-3;
                                                                       stageid = "3"; };
in
let
  # perl-3 :: derivation
  perl-3 = callPackage ../bootstrap-pkgs/perl/package.nix { stdenv = stdenv-3-1;
                                                            libxcrypt = libxcrypt-3;
                                                            pkgconf = pkgconf-3;
                                                            locale-archive = locale-archive-1;
                                                            stageid = "3"; };
in
let
  # load-bearing for fetchurl
  #
  # openssl :: derivation
  openssl-3 = callPackage
    ../bootstrap-pkgs/openssl/package.nix { stdenv = stdenv-3-1;
                                            perl = perl-3;
                                            zlib = zlib-3;
                                            stageid = "3";
    };

  # curl-3 :: derivation
  curl-3 = callPackage
    ../bootstrap-pkgs/curl/package.nix { stdenv = stdenv-3-1;
                                         perl = perl-3;
                                         openssl = openssl-3;
                                         stageid = "3"; };

  # TODO: promote this as far upstream as we can go.
  #
  # Ultimately: get nix fetchurl working in bootstrap-2 (or maybe bootstrap-1)
  #
  # cacert-3 :: derivation
  cacert-3 = callPackage
    ../bootstrap-pkgs/cacert/package.nix { stdenv = stdenv-3-1;
                                           stageid = "3";
                                         };

  # fetchurl-3 :: (url | urls,
  #                hash | sha256 | sha512 | sha1 | md5,
  #                name,
  #                curlOpts | curlOptsList,
  #                postFetch,
  #                downloadToTemp) -> derivation
  #
  fetchurl-3 = callPackage
    ../bootstrap-pkgs/fetchurl/package.nix { stdenv = stdenv-3-1;
                                             curl = curl-3;
                                             cacert = cacert-3;
                                           };

  # will be the tarball itself.
  # test-fetch-3 :: derivation
  test-fetch-3 = fetchurl-3 {
    name = "test-fetch-3-zlib-v1.3.1.tar.gz";
    url = "https://github.com/madler/zlib/archive/v1.3.1.tar.gz";
    sha256 = "sha256-F+iIY/NgBnKrSRgvIXKBtvxNPHYr3jYZNeQ2qVIU0Fw=";
  };

  # binutils-3 :: derivation
  binutils-3 = callPackage ../bootstrap-pkgs/binutils/package.nix { stdenv = stdenv-3-1;
                                                                    fetchurl = fetchurl-3;
                                                                    perl = perl-3;
                                                                    stageid = "3";
                                                                  };

  # autoconf-3 :: derivation
  autoconf-3 = callPackage ../bootstrap-pkgs/autoconf/package.nix { stdenv = stdenv-3-1;
                                                                    fetchurl = fetchurl-3;
                                                                    perl = perl-3;
                                                                    m4 = m4-3;
                                                                    stageid = "3";
                                                                  };

in
let
  # autoconf-3 :: derivation
  automake-3 = callPackage ../bootstrap-pkgs/automake/package.nix { stdenv = stdenv-3-1;
                                                                    fetchurl = fetchurl-3;
                                                                    autoconf = autoconf-3;
                                                                    perl = perl-3;
                                                                    stageid = "3";
                                                                  };
in
let
  # flex-3 :: derivation
  flex-3 = callPackage ../bootstrap-pkgs/flex/package.nix { stdenv = stdenv-3-1;
                                                            fetchurl = fetchurl-3;
                                                            m4 = m4-3;
                                                            stageid = "3";
                                                          };
  # gmp-3 :: derivation
  gmp-3 = callPackage ../bootstrap-pkgs/gmp/package.nix { stdenv = stdenv-3-1;
                                                          fetchurl = fetchurl-3;
                                                          m4 = m4-3;
                                                          stageid = "3";
                                                        };
  # mpfr-3 :: derivation
  mpfr-3 = callPackage ../bootstrap-pkgs/mpfr/package.nix { stdenv = stdenv-3-1;
                                                            fetchurl = fetchurl-3;
                                                            gmp = gmp-3;
                                                            stageid = "3"; };
  # mpc-3 :: derivation
  mpc-3 = callPackage ../bootstrap-pkgs/mpc/package.nix { stdenv = stdenv-3-1;
                                                          fetchurl = fetchurl-3;
                                                          gmp = gmp-3;
                                                          mpfr = mpfr-3;
                                                          stageid = "3"; };
  # isl-3 :: derivation
  isl-3 = callPackage ../bootstrap-pkgs/isl/package.nix { stdenv = stdenv-3-1;
                                                          fetchurl = fetchurl-3;
                                                          gmp = gmp-3;
                                                          stageid = "3";
                                                        };

in
let
  # bison-3 :: derivation
  bison-3 = callPackage ../bootstrap-pkgs/bison/package.nix { stdenv = stdenv-3-1;
                                                              fetchurl = fetchurl-3;
                                                              perl = perl-3;
                                                              flex = flex-3;
                                                              m4 = m4-3;
                                                              stageid = "3";
                                                            };
in
let
  # texinfo-3 :: derivation
  texinfo-3 = callPackage ../bootstrap-pkgs/texinfo/package.nix { stdenv = stdenv-3-1;
                                                                  fetchurl = fetchurl-3;
                                                                  perl = perl-3;
                                                                  stageid = "3";
                                                                };
in
let
  # python-3 :: derivation
  python-3 = callPackage ../bootstrap-pkgs/python/package.nix { stdenv = stdenv-3-1;
                                                                fetchurl = fetchurl-3;
                                                                popen = popen-3;
                                                                zlib = zlib-3;
                                                                stageid = "3"; };
in
let
  # TODO: nxfs-nixify-glibc-source/package.nix
  #
  # nixify-glibc-source-3 :: (attrset -> derivation)
  #
  nixified-glibc-source-3 =
    callPackage ../bootstrap-pkgs/nixify-glibc-source/package.nix
      { stdenv = stdenv-3-1;
        fetchurl = fetchurl-3;
        python = python-3;
        coreutils = coreutils-3;
        which = which-3;
        locale-archive = locale-archive-1;
        stageid = "3";
      };

  # glibc-targeted wrapper for sort -- invokes coreutils.sort with LC_ALL env var set to C.
  # Makes it convenient to kitbash glibc build to replace hardwired /bin/sort assumption
  #
  # lc-all-sort-3 :: derivation
  lc-all-sort-3 = callPackage ../bootstrap-pkgs/lc-all-sort/package.nix { stdenv = stdenv-3-1;
                                                                          coreutils = coreutils-3;
                                                                          stageid = "3"; };

  # glibc-x1-3 :: derivation
  glibc-x1-3 = callPackage ../bootstrap-pkgs/glibc/package.nix { stdenv                = stdenv-3-1;
                                                                 nixified-glibc-source = nixified-glibc-source-3;
                                                                 lc-all-sort           = lc-all-sort-3;
                                                                 locale-archive        = locale-archive-1;
                                                                 linux-headers         = linux-headers-2;
                                                                 python                = python-3;
                                                                 bison                 = bison-3;
                                                                 texinfo               = texinfo-3;
                                                                 which                 = which-3;
                                                                 stageid               = "3";
                                                               };
in
let
  # binutils-x0-wrapper-3 :: derivation
  binutils-x0-wrapper-3 = callPackage ../bootstrap-pkgs/binutils-x0-wrapper/package.nix { stdenv = stdenv-3-1;
                                                                                          bintools = binutils-3;
                                                                                          libc = glibc-x1-3;
                                                                                          stageid = "3";
                                                                                        };
in
let
  # gcc-x0-wrapper-3: new wrapper for stage2 C compiler,
  # instead of gcc-wrapper-2:
  #
  # - using stage3 bintools
  # - using stage3 libc
  #
  # TODO:: want spelling to be stdenv.cc.cc here instead of stage2pkgs.gcc-x3-2
  #        Should be same as stage2pkgs.gcc-x3-2 = stage2pkgs.gcc-wrapper-2.cc
  #
  # gcc-x0-wrapper-3 :: derivation
  gcc-x0-wrapper-3 = callPackage ../bootstrap-pkgs/gcc-vanilla-wrapper/package.nix { stdenv = stdenv-3-1;
                                                                                     cc = stage2pkgs.gcc-wrapper-2.cc;
                                                                                     #bintools = binutils-x0-wrapper-3;
                                                                                     libc = glibc-x1-3;
                                                                                     nxfs-defs = nxfs-defs;
                                                                                     stageid = "x0-3";
                                                                                   };


in
let
  # nixified-gcc-source-3 :: derivation
  nixified-gcc-source-3 =
    callPackage ../bootstrap-pkgs/nixify-gcc-source/package.nix
      {
        stdenv    = stdenv-3-1;
        fetchurl  = fetchurl-3;
        file      = file-3;
        which     = which-3;
        stageid = "3";
      };

  # gcc-x1-3 :: derivation
  #
  # note: bootstrap-pkgs/gcc-x3 builds gcc that fails on libstdcxx.
  #       suspect this is because it enables threads, but get stuck due to gcc
  #       config bug in tzdb.cc
  #
  gcc-x1-3 = callPackage
    ../bootstrap-pkgs/gcc-x1/package.nix { stdenv               = stdenv-3-1;
                                           nixified-gcc-source  = nixified-gcc-source-3;
                                           #gcc-wrapper          = gcc-x0-wrapper-3;
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
                                           stageid              = "3";

                                         };

  # gcc-stage2-wrapper-3 :: derivation
  gcc-x1-wrapper-3 = callPackage
    ../bootstrap-pkgs/gcc-x1-wrapper/package.nix { stdenv = stdenv-3-1;
                                                   cc = gcc-x1-3;
                                                   libc = glibc-x1-3;
                                                   nxfs-defs = nxfs-defs;
                                                   stageid = "3";
                                                 };
in
let
  # note: for some reason need to build with gcc that has threads disabled;
  #       otherwise problem with tzdb.cc
  #
  # libstdcxx-x2-3 :: derivation
  libstdcxx-x2-3 = callPackage
    ../bootstrap-pkgs/libstdcxx/package.nix { stdenv               = stdenv-3-1;
                                              gcc-wrapper          = gcc-x1-wrapper-3;
                                              binutils-wrapper     = binutils-x0-wrapper-3;
                                              glibc                = glibc-x1-3;
                                              nixified-gcc-source  = nixified-gcc-source-3;
                                              nxfs-defs            = nxfs-defs;
                                              stageid              = "3";
                                            };
in
let
  # gcc-stage3-wrapper-3 :: derivation
  gcc-x2-wrapper-3 = callPackage
    ../bootstrap-pkgs/gcc-x2-wrapper/package.nix { stdenv        = stdenv-3-1;
                                                   cc            = gcc-x1-3;
                                                   libstdcxx     = libstdcxx-x2-3;
                                                   libc          = glibc-x1-3;
                                                   nxfs-defs     = nxfs-defs;
                                                   stageid       = "3";
                                                 };
in
let
  # gcc with sufficient features to compile itself.
  # will use along with libstdcxx-x2-3 and glibc-x1-3
  #
  # gcc-x3-3 :: derivation
  gcc-x3-3 = callPackage
    ../bootstrap-pkgs/gcc-x3/package.nix { stdenv              = stdenv-3-1;
                                           nixified-gcc-source = nixified-gcc-source-3;
                                           gcc-wrapper         = gcc-x2-wrapper-3;
                                           binutils-wrapper    = binutils-x0-wrapper-3;
                                           mpc                 = mpc-3;
                                           mpfr                = mpfr-3;
                                           gmp                 = gmp-3;
                                           isl                 = isl-3;
                                           bison               = bison-3;
                                           flex                = flex-3;
                                           texinfo             = texinfo-3;
                                           m4                  = m4-3;
                                           libstdcxx           = libstdcxx-x2-3;  # not used here
                                           glibc               = glibc-x1-3;
                                           nxfs-defs           = nxfs-defs;
                                           stageid             = "3";
                                         };
in
let
  # gcc-wrapper-3 :: derivation
  gcc-wrapper-x3-3 = callPackage
    ../bootstrap-pkgs/gcc-vanilla-wrapper/package.nix { stdenv = stdenv-3-1;
                                                        cc = gcc-x3-3;
                                                        libc = glibc-x1-3;
                                                        #gcc-unwrapped = gcc-x3-3;
                                                        #bintools = binutils-x0-wrapper-3;
                                                        #glibc = glibc-x1-3;
                                                        nxfs-defs = nxfs-defs;
                                                        stageid = "x3-3";
                                                      };

  stagepkgs-x3-3 = stagepkgs-3-1 // { cc = gcc-wrapper-x3-3;
                                      bintools = binutils-x0-wrapper-3; };
  # to remove all doubt about bootstrap gcc provenance when we attempt gcc-x4-2
  stdenv-x3-3 = make-stdenv { name = "stdenv-x3-3"; stagepkgs = stagepkgs-x3-3; };

  # Full gcc build
  #
  # gcc-x3-2 compiler still contains bootstrap gcc references.
  # baked in to libcc1plugin.so
  # Next task is to rebuild gcc to scrub these references.
  #
  gcc-x4-3 = callPackage
    ../bootstrap-pkgs/gcc-x3/package.nix { stdenv = stdenv-x3-3;
                                           nixified-gcc-source = nixified-gcc-source-3;
                                           gcc-wrapper = gcc-wrapper-x3-3;
                                           binutils-wrapper = binutils-x0-wrapper-3;
                                           mpc = mpc-3;
                                           mpfr = mpfr-3;
                                           gmp = gmp-3;
                                           isl = isl-3;
                                           bison = bison-3;
                                           flex = flex-3;
                                           texinfo = texinfo-3;
                                           m4 = m4-3;
                                           libstdcxx = libstdcxx-x2-3;  # not actually used here
                                           glibc = glibc-x1-3;
                                           nxfs-defs = nxfs-defs;
                                           stageid = "x4-3";
    };

  gcc-wrapper-3 = callPackage
    ../bootstrap-pkgs/gcc-vanilla-wrapper/package.nix { stdenv = stdenv-x3-3;
                                                        cc = gcc-x4-3;
                                                        libc = glibc-x1-3;
                                                        nxfs-defs = nxfs-defs;
                                                        stageid = "2";
                                                      };
in
let
  stage3env = buildEnv {
    name = "stage3env";
    paths = [ gcc-wrapper-3
              gcc-x4-3
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
              curl-3
              xz-3
              openssl-3
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
  # members this attrset accessible from toplevel as stage3pkgs.gcc-wrapper-3 etc.
  {
    stdenv = stdenv-x3-3;  # final stage3 stdenv

    inherit stage3env;
    inherit gcc-wrapper-3;
    inherit gcc-x4-3;
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

    #inherit fetchurl-3;
    inherit test-fetch-3;
    inherit cacert-3;
    inherit curl-3;
    inherit xz-3;
    inherit openssl-3;

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
