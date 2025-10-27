# Similar in spirit to nixpkgs/top-level/default.nix
# Intended to be composable and overrideable.
# See nxfspkgs/{default.nix, impure.nix, nxfspkgs.nix}
#
# Requires:
# 1. nixcpp built + installed. See nix-from-scratch/README)
# 2. stage0 packages built + imported. See nix-from-scratch/nxfspkgs/bootstrap/README
#
# Use:
#   $ nix-build path/to/nix-from/scratch/nxfspkgs -A stage2pkgs.diffutils-2
# or
#   $ export NIX_PATH=path/to/nix-from-scratch:${NIX_PATH}
#   $ nix-build '<nxfspkgs>' -A stage2pkgs.diffutils-2
#
# Major difference from nixpkgs.nix: w'ere carefully nesting
# nxfsenv attribute sets so that bootstrap process is more spelled out.
# See nxfsenv-2-0...
{
  # nxfspkgs: will be the contents of nxfspkgs/nxfspkgs.nix after composing
  # with config choices + overlays.
  # See nix-from-scratch/nxfspkgs/impure.nix
  #
  # The sole reason for pulling in <nxfspkgs> here is for nxfspkgs.stage2pkgs.
  # That refers to this nix function, after applying nxfspkgs configs + overlays.
  #
  # This choice allows user to customize/override stage2pkgs without (for example) cluttering NIX_PATH
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
  # nxfs-defs :: { system       :: string,
  #                target_tuple :: string }
  # e.g.
  #   nxfs-defs.system = "x86_64-linux"
  #   nxfs-defs.target_tuple = "x86_64-pc-linux-gnu"
  #
  nxfs-defs = import ../bootstrap-1/nxfs-defs.nix;

  # autotools eventually evaluates to derivation with defaults for:
  #   .builder .args .baseInputs .buildInputs .system
  # default builder requires pkgs.bash
  #
  # nxfs-autotools :: pkgs -> attrs -> derivation
  nxfs-autotools = import ../build-support/autotools;

  # possibly temporary? depends on whether it makes sense to push the stage2pkgs.nix patterns
  # down to stage1.  if so, may be able to retire this.  otherwise definitely keep.
  bootstrap-1 = import ./bootstrap-1;
in

let
  # stage1pkgs :: attrset -- all stage1 packages
  stage1pkgs = nxfspkgs.stage1pkgs;

  bash-1 = import ../bootstrap-1/nxfs-bash-1/default.nix;

  # TODO: use callPackage
  locale-archive-1 = import ../bootstrap-1/nxfs-locale-archive-1/default.nix;

  make-stdenv = (import ../build-support/make-stdenv/make-stdenv.nix { config = config; });

  # stdenv interface, except that patch is missing.
  # when patch becomes available below, will need to splice it in
  stagepkgs-1 = {
    cc        = stage1pkgs.nxfs-toolchain-wrapper-1;
    bintools  = stage1pkgs.nxfs-binutils-x0-wrapper-1;
    patchelf  = stage1pkgs.nxfs-patchelf-1;
    patch     = stage1pkgs.nxfs-empty-1;  # -- patch not available from stage1!
    shell     = stage1pkgs.nxfs-bash-1;
    coreutils = stage1pkgs.nxfs-coreutils-1;
    gzip      = stage1pkgs.nxfs-gzip-1;
    gnumake   = stage1pkgs.nxfs-gnumake-1;
    gawk      = stage1pkgs.nxfs-gawk-1;
    gnutar    = stage1pkgs.nxfs-tar-1;
    gnugrep   = stage1pkgs.nxfs-grep-1;
    gnused    = stage1pkgs.nxfs-sed-1;
    findutils = stage1pkgs.nxfs-findutils-1;
    diffutils = stage1pkgs.nxfs-diffutils-1;
  };

  stdenv-1 = make-stdenv { name = "stdenv-1";
                           stagepkgs = stagepkgs-1; };

  # initial bootstrap stdenv for stage-2.
  #
  # NOTE: In nixpkgs stdenv pattern is to have attrs
  #         stdenv.cc             : wrapped C,C++ compiler. ${stdenv.cc}/bin/cc, ${stdenv.cc}/bin/c++
  #         stdenv.cc.cc          : unwrapped C,C++ compiler. ${stdenv.cc.cc}/bin/cc, ${stdenv.cc.cc}/bin/c++
  #         stdenv.cc.bintools    : binutils. ${stdenv.cc.bintools}/bin/ld, ${stdenv.cc.bintools}/bin/ar
  #         stdenv.cc.libc        : libc implementation. ${stdenv.cc.libc}/lib
  #         stdenv.cc.libc.dev    : libc headers. ${stdenv.cc.libc.dev}/include/stdio.h
  #         stdenv.cc.libc.static : static libraries, if prepared
  #       Unwrapped compiler will need bespoke flags to set RUNPATH etc.
  #       Wrapped compiler takes care of flags.
  #
  #       In nxfspkgs we use toolchain instead,
  #       since imported toolchain has binutils + gcc + glibc in a single package.
  #
  #       We won't have separate {glibc, cc} until almost the end of stage2.
  #       Won't use the same naming as nixpkgs, since that would be misleading.
  #       Instead:
  #         nxfsenv.toolchain          : wrapped C,C++ compiler.  Provides {gcc, g++, nxfs-gcc, nxfs-g++}
  #         nxfsenv.toolchain.toolchain: unwrapped C,C++ compiler + bintools + glibc + headers
  #
  #       Nixpkgs stdenv does *not* have gnumake,gawk,gnutar,gnugrep,gnused,diffutils
  #       All are passed separately.  That said,
  #         stdenv.initialPath  : list(derivation)  will contain top-level gnused.
  #
  #       on linux, expect stdenv.initialPath:
  #         [ coreutils gnugrep gnused findutils diffutlis gawk gnutar gzip bzip2 gnumake bash patch xz]
  #         ++ [ patchelf binutils ].
  #
  #       If we want to follow the nixpkgs strategy here, need a makeNxfsenv,
  #       since we're progressively changing what would appear in stdenv.initialPath
  #
  nxfsenv-1 =
    let
      # missing (relative to nixpgks):
      #   bzip2
      #   xz    (need this if we want to use tar xzf ?)
      #   patch

      coreutils = import ../bootstrap-1/nxfs-coreutils-1/default.nix;
      gnumake   = import ../bootstrap-1/nxfs-gnumake-1/default.nix;
      gzip      = import ../bootstrap-1/nxfs-gzip-1/default.nix;
      gawk      = import ../bootstrap-1/nxfs-gawk-1/default.nix;
      gnutar    = import ../bootstrap-1/nxfs-tar-1/default.nix;
      gnugrep   = import ../bootstrap-1/nxfs-grep-1/default.nix;
      gnused    = import ../bootstrap-1/nxfs-sed-1/default.nix;
      findutils = import ../bootstrap-1/nxfs-findutils-1/default.nix;
      diffutils = import ../bootstrap-1/nxfs-diffutils-1/default.nix;
      toolchain = import ../bootstrap-1/nxfs-toolchain-wrapper-1/default.nix;
      shell     = bash-1;
    in
      {
        # TODO: eventually remove for consistency with nixpkgs style
        inherit toolchain;
        # TODO: eventually remove these for consistency with nixpkgs style
        inherit coreutils shell gnumake gzip gawk gnugrep gnutar gnused findutils diffutils;

        # mkDerivation :: attrs -> derivation
        mkDerivation = nxfs-autotools nxfsenv-1;

        # these automtically populate PATH :-> corresponding executables
        # are implicitly available to all nix derivations using this nxfsenv.
        #
        # initialPath :: [ derivation ]
        #
        initialPath = [ coreutils shell gnumake gzip gawk gnugrep gnused gnutar findutils diffutils toolchain ];

        inherit nxfs-defs;
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

  # minimal substitute for nixpkgs buildEnv.
  # (many features omitted in return for much simpler implementation)
  #
  # buildEnv :: {name, paths} -> derivation
  #
  buildEnv = import ../lib/buildEnv.nix;
in
let
  # nxfspkg.stage2pkgs is the attribute set returned by *this file*.
  # It contains packages we haven't defined yet,
  # so need to be careful not to create cycles.
  # Achieve this by refraining from any forward references.
  #
  callPackage = makeCallPackage nxfspkgs.stage2pkgs;
in
let
  # linux-headers-2 :: derivation
  linux-headers-2 = callPackage ../bootstrap-pkgs/linux-headers/package.nix { stdenv = stdenv-1; };
in
let
  which-2 = callPackage ../bootstrap-pkgs/which/package.nix { stdenv = stdenv-1;
                                                              stageid = "2";
                                                            };
in
let
  diffutils-2 = callPackage ../bootstrap-pkgs/diffutils/package.nix { stdenv = stdenv-1;
                                                                      stageid = "2";
                                                                    };
in
let
  findutils-2 = callPackage ../bootstrap-pkgs/findutils/package.nix { stdenv = stdenv-1;
                                                                      stageid = "2";
                                                                    };
  #findutils-2 = callPackage ./nxfs-findutils-2/package.nix { nxfsenv = nxfsenv-2-1; };
in
let
  gnused-2 = callPackage ../bootstrap-pkgs/gnused/package.nix { stdenv = stdenv-1;
                                                                stageid = "2";
                                                              };
  #gnused-2 = callPackage ./nxfs-sed-2/package.nix { nxfsenv = nxfsenv-2-2; };
in
let
  gnugrep-2 = callPackage ../bootstrap-pkgs/gnugrep/package.nix { stdenv = stdenv-1;
                                                                  stageid = "2"; };
in
let
  bzip2-2 = callPackage ../bootstrap-pkgs/bzip2/package.nix { stdenv = stdenv-1;
                                                              stageid = "2"; };


  gnutar-2 = callPackage ../bootstrap-pkgs/gnutar/package.nix { stdenv = stdenv-1;
                                                                bzip2 = bzip2-2;
                                                                stageid = "2";
                                                              };
in
let
  # do we actually need ncurses-2 ?
  # was not present in stage3 (although added it for consistency's sake)

  ncurses-2 = callPackage ../bootstrap-pkgs/ncurses/package.nix { stdenv = stdenv-1;
                                                                  stageid = "2"; };
in
let
  bash-2 = callPackage ../bootstrap-pkgs/bash/package.nix { stdenv = stdenv-1;
                                                            stageid = "2"; };
in
let
  # TODO: bootstrap-3 to use this form for popen-template.
  #       else must preserve nxfs-popen-template-2/default.nix
  popen-template-2 = callPackage ../bootstrap-pkgs/popen-template/package.nix { stdenv = stdenv-1;
                                                                                stageid = "2";
                                                                              };
in
let
  # don't need nxfsenv with popen-template member
  #nxfsenv-2-8 = nxfsenv-2-7 // { popen-template = popen-template-2; };
  popen-2 = callPackage ../bootstrap-pkgs/popen/package.nix { stdenv = stdenv-1;
                                                              popen-template = popen-template-2;
                                                              stageid = "2";
                                                            };
in
let
  stagepkgs-2-1 = stagepkgs-1 // { gnutar    = gnutar-2;
                                   shell     = bash-2;
                                   gnugrep   = gnugrep-2;
                                   gnused    = gnused-2;
                                   findutils = findutils-2;
                                   diffutils = diffutils-2;
                                 };
  stdenv-2-1 = make-stdenv { name = "stdenv-2-1";
                             stagepkgs = stagepkgs-2-1; };

  # gawk-2: this picks up bash-1 as runtime dep.  may want to freshen stdenv to include bash-2 here.
  #
  gawk-2 = callPackage ../bootstrap-pkgs/gawk/package.nix { stdenv = stdenv-2-1;
                                                            popen = popen-2;
                                                            stageid = "2";
                                                          };
in
let
  # gnumake-2: this picks up bash-1 as runtime dep.  may want to freshen stdenv to include bash-2 here
  #
  gnumake-2 = callPackage ../bootstrap-pkgs/gnumake/package.nix { stdenv = stdenv-2-1;
                                                                  stageid = "2";
                                                                };
in
let
  coreutils-2 = callPackage ../bootstrap-pkgs/coreutils/package.nix { stdenv = stdenv-2-1;
                                                                      stageid = "2";
                                                                    };
in
let
  # patch-2 :: derivation
  patch-2    = callPackage ../bootstrap-pkgs/patch/package.nix { stdenv = stdenv-2-1;
                                                                 stageid = "2";
                                                               };

  stagepkgs-2-2 = stagepkgs-2-1 // { patch     = patch-2;
                                     #shell     = bash-2;
                                     coreutils = coreutils-2;
                                     gnumake   = gnumake-2;
                                     gawk      = gawk-2;
                                     #gnutar    = gnutar-2;
                                     #gnugrep   = gnugrep-2;
                                     #gnused    = gnused-2;
                                     #findutils = findutils-2;
                                     #diffutils = diffutils-2;
                                   };

  stdenv-2-2 = make-stdenv { name = "stdenv-2-2";
                             stagepkgs = stagepkgs-2-2; };

  # pkgconf-2 :: derivation
  pkgconf-2  = callPackage ../bootstrap-pkgs/pkgconf/package.nix { stdenv = stdenv-2-2;
                                                                   stageid = "2"; };
  # m4-2 :: derivation
  m4-2       = callPackage ../bootstrap-pkgs/m4/package.nix { stdenv = stdenv-2-2;
                                                              stageid = "2"; };
  # file-2 :: derivation
  file-2     = callPackage ../bootstrap-pkgs/file/package.nix { stdenv = stdenv-2-2;
                                                                stageid = "2"; };
  # zlib-2 :: derivation
  zlib-2     = callPackage ../bootstrap-pkgs/zlib/package.nix { stdenv = stdenv-2-2;
                                                                stageid = "2"; };
  # patchelf-2 :: derivation
  patchelf-2 = callPackage ../bootstrap-pkgs/patchelf/package.nix { stdenv = stdenv-2-2;
                                                                    stageid = "2"; };
  # gzip-2 :: derivation
  gzip-2     = callPackage ../bootstrap-pkgs/gzip/package.nix { stdenv = stdenv-2-2;
                                                                stageid = "2"; };
  # gperf-2 :: derivation
  gperf-2    = callPackage ../bootstrap-pkgs/gperf/package.nix { stdenv = stdenv-2-2;
                                                                 stageid = "2"; };

  # note: stage2pkgs.nxfs-perl-1 doesn't actually exist
  #       + harder to provide than we might expect.
  #       If we decide we want to revisit, probably build stage0/stage1 without libcrypt
#
#  # libxcrypt-2 :: derivation
#  libxcrypt-2 = callPackage ../bootstrap-pkgs/libxcrypt/package.nix { stdenv = stdenv-2-2;
#                                                                      perl = stage1pkgs.nxfs-perl-1;
#                                                                      pkgconf = pkgconf-2;
#                                                                      stageid = "2"; };

  # NOTE: stage3 perl gets pkgconf, libxcrypt.
  #       in stage2 we don't need it
  #
  # perl-2 :: derivation
  perl-2     = callPackage ../bootstrap-pkgs/perl/package.nix { stdenv = stdenv-2-2;
                                                                pkgconf = pkgconf-2;
                                                                with-xcrypt = false;
                                                                locale-archive = locale-archive-1;
                                                                stageid = "2"; };
in
let
  # binutils-2 :: derivation
  binutils-2 = callPackage ../bootstrap-pkgs/binutils/package.nix { stdenv = stdenv-2-2;
                                                                    perl = perl-2;
                                                                    stageid = "2"; };
  # autoconf-2 :: derivation
  autoconf-2 = callPackage ../bootstrap-pkgs/autoconf/package.nix { stdenv = stdenv-2-2;
                                                                    perl = perl-2;
                                                                    m4 = m4-2;
                                                                    stageid = "2"; };
in
let
  # automake-2 :: derivation
  automake-2 = callPackage ../bootstrap-pkgs/automake/package.nix { stdenv = stdenv-2-2;
                                                                    autoconf = autoconf-2;
                                                                    perl = perl-2;
                                                                    stageid = "2"; };
in
let
  # flex-2 :: derivation
  flex-2 = callPackage ../bootstrap-pkgs/flex/package.nix { stdenv = stdenv-2-2;
                                                            m4 = m4-2;
                                                            stageid = "2"; };
  # gmp-2 :: derivation
  gmp-2 = callPackage ../bootstrap-pkgs/gmp/package.nix { stdenv = stdenv-2-2;
                                                          m4 = m4-2;
                                                          stageid = "2";
                                                        };
in
let
  # bison-2 :: derivation
  bison-2 = callPackage ../bootstrap-pkgs/bison/package.nix { stdenv = stdenv-2-2;
                                                              perl = perl-2;
                                                              flex = flex-2;
                                                              m4 = m4-2;
                                                              stageid = "2"; };
in
let
  # texinfo-2 :: derivation
  texinfo-2 = callPackage ../bootstrap-pkgs/texinfo/package.nix { stdenv = stdenv-2-2;
                                                                  perl = perl-2;
                                                                  stageid = "2";
                                                                };
in
let
  # mpr-2 :: derivation
  mpfr-2 = callPackage ../bootstrap-pkgs/mpfr/package.nix { stdenv = stdenv-2-2;
                                                            gmp = gmp-2;
                                                            stageid = "2"; };
  # isl-2 :: derivation
  isl-2 = callPackage ../bootstrap-pkgs/isl/package.nix { stdenv = stdenv-2-2;
                                                          gmp = gmp-2;
                                                          stageid = "2"; };
in
let
  # mpc-2 :: derivation
  mpc-2  = callPackage ../bootstrap-pkgs/mpc/package.nix { stdenv = stdenv-2-2;
                                                           mpfr = mpfr-2;
                                                           gmp = gmp-2;
                                                           stageid = "2"; };
in
let
  # python-2 :: derivation
  python-2 = callPackage
    ../bootstrap-pkgs/python/package.nix { stdenv = stdenv-2-2;
                                           popen = popen-2;
                                           zlib = zlib-2;
                                           stageid = "2"; };
in
let
  nixified-glibc-source-2 = callPackage
    ../bootstrap-pkgs/nixify-glibc-source/package.nix
    { stdenv = stdenv-2-2;
      python = python-2;
      coreutils = coreutils-2;
      which = which-2;
      locale-archive = locale-archive-1;
      stageid = "2"; };

  # wrapper for sort -- invokes coreutils.sort with LC_ALL env var set to C
  lc-all-sort-2 = callPackage
    ../bootstrap-pkgs/lc-all-sort/package.nix { stdenv = stdenv-2-2;
                                                coreutils = coreutils-2;
                                                stageid = "2"; };

in
let
  # glibc-2 :: derivation   # glibc-x1-3 in stage3
  glibc-2 = callPackage
    ../bootstrap-pkgs/glibc/package.nix { stdenv = stdenv-2-2;
                                          python = python-2;
                                          texinfo = texinfo-2;
                                          bison = bison-2;
                                          which = which-2;
                                          nixified-glibc-source = nixified-glibc-source-2;
                                          lc-all-sort = lc-all-sort-2;
                                          locale-archive = locale-archive-1;
                                          linux-headers = linux-headers-2;
                                          stageid = "2";
                                        };
in
let
  binutils-x0-wrapper-2 = callPackage ../bootstrap-pkgs/binutils-x0-wrapper/package.nix { stdenv = stdenv-2-2;
                                                                                          bintools = binutils-2;
                                                                                          libc = glibc-2;
                                                                                          stageid = "2";
                                                                                        };

  # gcc-x0-wrapper-2 :: derivation
  gcc-x0-wrapper-2 = callPackage ../bootstrap-pkgs/gcc-x0-wrapper/package.nix { stdenv = stdenv-2-2;
                                                                                cc = stage1pkgs.nxfs-toolchain-1;
                                                                                libc = glibc-2;
                                                                                nxfs-defs = nxfs-defs;
                                                                                stageid = "2";
                                                                              };
in
let

  # nixified-gcc-source-2 :: derivation
  nixified-gcc-source-2 = callPackage
    ../bootstrap-pkgs/nixify-gcc-source/package.nix { stdenv = stdenv-2-2;
                                                      file = file-2;
                                                      which = which-2;
                                                      stageid = "2"; };

  # this version
  gcc-x1-2 = callPackage ../bootstrap-pkgs/gcc-x1/package.nix { stdenv = stdenv-2-2;
                                                                nixified-gcc-source = nixified-gcc-source-2;
                                                                binutils-wrapper = binutils-x0-wrapper-2;
                                                                mpc = mpc-2;
                                                                mpfr = mpfr-2;
                                                                gmp = gmp-2;
                                                                isl = isl-2;
                                                                bison = bison-2;
                                                                flex = flex-2;
                                                                texinfo = texinfo-2;
                                                                m4 = m4-2;
                                                                glibc = glibc-2;
                                                                nxfs-defs = nxfs-defs;
                                                                stageid = "2"; };
in
let
  # gcc-x1-wrapper-2 :: derivation
  gcc-x1-wrapper-2 = callPackage ../bootstrap-pkgs/gcc-x1-wrapper/package.nix { stdenv = stdenv-2-2;
                                                                                cc = gcc-x1-2;
                                                                                libc = glibc-2;
                                                                                nxfs-defs = nxfs-defs;
                                                                                stageid = "2";
                                                                              };
in
let
  # libstdcxx-x2-2 :: derivation
  libstdcxx-x2-2 = callPackage
    ../bootstrap-pkgs/libstdcxx/package.nix { stdenv              = stdenv-2-2;
                                              gcc-wrapper         = gcc-x1-wrapper-2;
                                              binutils-wrapper    = binutils-x0-wrapper-2;
                                              glibc               = glibc-2;
                                              nixified-gcc-source = nixified-gcc-source-2;
                                              nxfs-defs           = nxfs-defs;
                                              stageid             = "2";
                                            };
in
let
  # gcc-x2-wrapper-2 :: derivation
  gcc-x2-wrapper-2 = callPackage
    ../bootstrap-pkgs/gcc-x2-wrapper/package.nix { stdenv    = stdenv-2-2;
                                                   cc        = gcc-x1-2;  # unwrapped cc
                                                   libstdcxx = libstdcxx-x2-2;
                                                   libc      = glibc-2;
                                                   nxfs-defs = nxfs-defs;
                                                   stageid   = "2";
                                                 };
in
let
  # Full gcc build
  #
  # gcc-x3-2 :: derivation
  gcc-x3-2 = callPackage
    ../bootstrap-pkgs/gcc-x3/package.nix { stdenv              = stdenv-2-2;
                                           nixified-gcc-source = nixified-gcc-source-2;
                                           gcc-wrapper         = gcc-x2-wrapper-2;
                                           binutils-wrapper    = binutils-x0-wrapper-2;
                                           mpc                 = mpc-2;
                                           mpfr                = mpfr-2;
                                           gmp                 = gmp-2;
                                           isl                 = isl-2;
                                           bison               = bison-2;
                                           flex                = flex-2;
                                           texinfo             = texinfo-2;
                                           m4                  = m4-2;
                                           libstdcxx           = libstdcxx-x2-2;
                                           glibc               = glibc-2;
                                           nxfs-defs           = nxfs-defs;
                                           # paths from this derivation wind up embedded in $out/lib64/libcc1.so;
                                           # will be updating them in place (!!)
                                           #bootstrap-toolchain  = stage1pkgs.nxfs-toolchain-1;
                                           stageid             = "x3-2";
                                         };

  gcc-x3-wrapper-2 = callPackage
    ../bootstrap-pkgs/gcc-x3-wrapper/package.nix { stdenv = stdenv-2-2;
                                                   cc = gcc-x3-2;
                                                   # libstdcxx,
                                                   libc = glibc-2;
                                                   nxfs-defs = nxfs-defs;
                                                   stageid = "2";
                                                 };

  stagepkgs-x3-2 = stagepkgs-2-2 // { cc = gcc-x3-wrapper-2; bintools = binutils-x0-wrapper-2; };
  # to remove all doubt about bootstrap gcc provenance when we attempt gcc-x4-2
  stdenv-x3-2 = make-stdenv { name = "stdenv-x3-2"; stagepkgs = stagepkgs-x3-2; };

  # ----------------------------------------------------------------
  # stage 2a starts here.
  #
  # TODO: gcc-x3-wrapper setup hook
  #
  # gcc-x5-2: clean bootstrapped gcc (no gcc bootstrap refs)
  #           but still refers to bootstrap via glibc
  # ----------------------------------------------------------------

  # Full gcc build
  #
  # gcc-x3-2 compiler still contains bootstrap gcc references.
  # baked in to libcc1plugin.so
  # Next task is to rebuild gcc to scrub these references.
  #
  gcc-x4-2 = callPackage
    ../bootstrap-pkgs/gcc-x3/package.nix { stdenv = stdenv-x3-2;
                                           nixified-gcc-source = nixified-gcc-source-2;
                                           gcc-wrapper = gcc-x3-wrapper-2;
                                           binutils-wrapper = binutils-x0-wrapper-2;
                                           mpc = mpc-2;
                                           mpfr = mpfr-2;
                                           gmp = gmp-2;
                                           isl = isl-2;
                                           bison = bison-2;
                                           flex = flex-2;
                                           texinfo = texinfo-2;
                                           m4 = m4-2;
                                           libstdcxx = libstdcxx-x2-2;  # not actually used here
                                           glibc = glibc-2;
                                           nxfs-defs = nxfs-defs;
                                           stageid = "x4-2";
    };

  gcc-x4-wrapper-2 = callPackage
    ../bootstrap-pkgs/gcc-x3-wrapper/package.nix { stdenv = stdenv-x3-2;
                                                   cc = gcc-x4-2;
                                                   libc = glibc-2;
                                                   nxfs-defs = nxfs-defs;
                                                   stageid = "2"; };

  stagepkgs-x4-2 = stagepkgs-x3-2 // { cc = gcc-x4-wrapper-2; bintools = binutils-x0-wrapper-2; };
  stdenv-x4-2 = make-stdenv { name = "stdenv-x4-2"; stagepkgs = stagepkgs-x4-2; };

  # ----------------------------------------------------------------
  # stage 2a: rebuild coreutils->bash->glibc using gcc-x4-2

  coreutils-x4-2 = callPackage ../bootstrap-pkgs/coreutils/package.nix { stdenv = stdenv-x4-2;
                                                                         stageid = "2"; };

  stagepkgs-x5-2 = stagepkgs-x4-2 // { coreutils = coreutils-x4-2; };
  stdenv-x5-2 = make-stdenv { name = "stdenv-x5-2"; stagepkgs = stagepkgs-x5-2; };

  bash-x5-2 = callPackage ../bootstrap-pkgs/bash/package.nix { stdenv = stdenv-x5-2;
                                                               stageid = "2"; };

  stagepkgs-x6-2 = stagepkgs-x5-2 // { shell = bash-x5-2; };
  stdenv-x6-2 = make-stdenv { name = "stdenv-x6-2"; stagepkgs = stagepkgs-x6-2; };

  glibc-x6-2 = callPackage
    ../bootstrap-pkgs/glibc/package.nix { stdenv = stdenv-x6-2;
                                          python = python-2;
                                          texinfo = texinfo-2;
                                          bison = bison-2;
                                          which = which-2;
                                          nixified-glibc-source = nixified-glibc-source-2;
                                          lc-all-sort = lc-all-sort-2;
                                          locale-archive = locale-archive-1;
                                          linux-headers = linux-headers-2;
                                          stageid = "2";  # to keep same size of name for now
                                        };

  file-x6-2 = callPackage
    ../bootstrap-pkgs/file/package.nix { stdenv = stdenv-x6-2;
                                         stageid = "2"; };

  nixified-gcc-source-x6-2 = callPackage
    ../bootstrap-pkgs/nixify-gcc-source/package.nix { stdenv = stdenv-x6-2;
                                                      file = file-x6-2;
                                                      which = which-2;
                                                      stageid = "2"; };

  m4-x6-2 = callPackage
    ../bootstrap-pkgs/m4/package.nix { stdenv = stdenv-x6-2;
                                       stageid = "2"; };

  flex-x6-2 = callPackage
    ../bootstrap-pkgs/flex/package.nix { stdenv = stdenv-x6-2;
                                         m4 = m4-x6-2;
                                         stageid = "2"; };

  gmp-x6-2 = callPackage
    ../bootstrap-pkgs/gmp/package.nix { stdenv = stdenv-x6-2;
                                        m4 = m4-x6-2;
                                        stageid = "2"; };

  isl-x6-2 = callPackage
    ../bootstrap-pkgs/isl/package.nix { stdenv = stdenv-x6-2;
                                        gmp = gmp-x6-2;
                                        stageid = "2"; };

  mpfr-x6-2 = callPackage
    ../bootstrap-pkgs/mpfr/package.nix { stdenv = stdenv-x6-2;
                                         gmp = gmp-x6-2;
                                         stageid = "2"; };

  mpc-x6-2 = callPackage
    ../bootstrap-pkgs/mpc/package.nix { stdenv = stdenv-x6-2;
                                        mpfr = mpfr-x6-2;
                                        gmp = gmp-x6-2;
                                        stageid = "2"; };

  # ----------------------------------------------------------------
  # stage 2b: now redirect bootstrap references to
  #             {bash, coreutils, glibc, gcc}
  #           to refer to
  #             {bash-x7-2, coreutils-x7-2, glibc-x7-2, gcc-x7-2}
  #           respectively

  # boot-x5-2:
  # 1. contains a working native toolchain,
  #    comprising {gcc, glibc} + recursive completion of gcc *runtime*
  #    dependencies
  # 2. has no bootstrap dependencies.
  #    This is achieved by redirecting nix-store hashes of
  #    upstream bootstrap packages so that they refer to this package.
  # 3. all dependencies so promoted were built from source
  #    using pinned versions; we exepct boot-x5-2
  #    to be a reasonable candidate fixpoint.
  #
  # next step is to extract boot-x5-2 components as individual packages
  # remaining stdenv ingredients {gnumake, gnused, gnugrep, ..}
  #
  boot-x5-2 = callPackage
    ../bootstrap-pkgs/redirect/package.nix { stdenv = stdenv-x6-2;
                                             gcc-p1 = gcc-x4-2;
                                             gcc-p2 = gcc-x3-2;
                                             nixify-gcc-source-p1 = nixified-gcc-source-x6-2;
                                             nixify-gcc-source-p2 = nixified-gcc-source-2;
                                             mpc-p1 = mpc-x6-2;
                                             mpc-p2 = mpc-2;
                                             mpfr-p1 = mpfr-x6-2;
                                             mpfr-p2 = mpfr-2;
                                             isl-p1 = isl-x6-2;
                                             isl-p2 = isl-2;
                                             gmp-p1 = gmp-x6-2;
                                             gmp-p2 = gmp-2;
                                             flex-p1 = flex-x6-2;
                                             flex-p2 = flex-2;
                                             m4-p1 = m4-x6-2;
                                             m4-p2 = m4-2;
                                             file-p1 = file-x6-2;
                                             file-p2 = file-2;
                                             glibc-p1 = glibc-x6-2;
                                             glibc-p2 = glibc-2;
                                             coreutils-p1 = coreutils-x4-2;
                                             coreutils-p2 = coreutils-2;
                                             bash-p1 = bash-x5-2;
                                             bash-p2 = bash-2;
                                             perl = perl-2;
                                             stageid = "2";
                                           };

  hello-x5-2 = callPackage
    ../bootstrap-2-demo/hello-cxx-2 { stdenv = stdenv-x4-2; };
  string-x5-2 = callPackage
    ../bootstrap-2-demo/string-cxx-2 { stdenv = stdenv-x4-2; };
in
let
  # gcc-wrapper-2 :: derivation
#  gcc-wrapper-2 = callPackage ./nxfs-gcc-wrapper-2/package.nix { nxfsenv = nxfsenv-2-100;
#                                                                 bintools = binutils-x0-wrapper-2;
#                                                                 glibc = glibc-2;
  #                                                               };
  gcc-wrapper-2 = gcc-x4-wrapper-2;
in
let
  stage2env = buildEnv { name = "stage2env";
                         paths = [ boot-x5-2
                                   gcc-wrapper-2
                                   glibc-x6-2
                                   #gcc-x5-2
                                   gcc-x4-2
                                   #gcc-x3-wrapper-2
                                   #gcc-x3-2
                                   binutils-x0-wrapper-2
                                   python-2
                                   mpc-2
                                   mpfr-2
                                   gmp-2
                                   texinfo-2
                                   bison-2
                                   flex-2
                                   automake-2
                                   autoconf-2
                                   binutils-2
                                   perl-2
                                   m4-2
                                   pkgconf-2
                                   file-x6-2
                                   gzip-2
                                   patch-2
                                   gperf-2
                                   patchelf-2
                                   zlib-2
                                   coreutils-2
                                   gnumake-2
                                   gawk-2
                                   bash-2
                                   ncurses-2
                                   gnutar-2
                                   gnugrep-2
                                   gnused-2
                                   findutils-2
                                   diffutils-2
                                   which-2
                                 ];
                         coreutils = coreutils-2;
                       };
in
{
  # listed in top-down topological order

  inherit stage2env;
  inherit gcc-wrapper-2;

  inherit string-x5-2;
  inherit hello-x5-2;

  inherit nixified-gcc-source-x6-2;
  inherit file-x6-2;
  inherit glibc-x6-2;
  inherit boot-x5-2;
  #inherit gcc-x5-2;
  inherit bash-x5-2;
  inherit coreutils-x4-2;
  inherit gcc-x4-wrapper-2;
  inherit gcc-x4-2;
  inherit gcc-x3-wrapper-2;
  inherit gcc-x3-2;
  inherit nixified-gcc-source-2;
  inherit gcc-x2-wrapper-2;
  inherit libstdcxx-x2-2;
  inherit gcc-x1-wrapper-2;
  inherit gcc-x1-2;
  inherit binutils-x0-wrapper-2;
  inherit gcc-x0-wrapper-2;
  inherit glibc-2;
  inherit nixified-glibc-source-2;
  inherit python-2;
  inherit mpc-2;
  inherit mpfr-2;
  inherit isl-2;
  inherit gmp-2;
  inherit texinfo-2;
  inherit bison-2;
  inherit flex-2;
  inherit automake-2;
  inherit autoconf-2;
  inherit binutils-2;
  inherit perl-2;
#  inherit libxcrypt-2;
  inherit m4-2;
  inherit pkgconf-2;
  inherit file-2;
  inherit gzip-2;
  inherit patch-2;
  inherit gperf-2;
  inherit patchelf-2;
  inherit zlib-2;
  inherit coreutils-2;
  inherit gnumake-2;
  inherit gawk-2;
  inherit popen-2;
  inherit popen-template-2;
  inherit bash-2;
  inherit ncurses-2;
  inherit gnutar-2;
  inherit bzip2-2;
  inherit gnugrep-2;
  inherit gnused-2;
  inherit findutils-2;
  inherit diffutils-2;
  inherit which-2;
#  inherit combined-glibc-linux-headers-2;
  inherit linux-headers-2;
}
