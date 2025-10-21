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
  gawk-2 = callPackage ../bootstrap-pkgs/gawk/package.nix { stdenv = stdenv-1;
                                                            popen = popen-2;
                                                            stageid = "2";
                                                          };
in
let
  gnumake-2 = callPackage ../bootstrap-pkgs/gnumake/package.nix { stdenv = stdenv-1;
                                                                  stageid = "2";
                                                                };
in
let
  coreutils-2 = callPackage ../bootstrap-pkgs/coreutils/package.nix { stdenv = stdenv-1;
                                                                      stageid = "2";
                                                                    };
in
let
  # patch-2 :: derivation
  patch-2    = callPackage ../bootstrap-pkgs/patch/package.nix { stdenv = stdenv-1;
                                                                 stageid = "2";
                                                               };

  stagepkgs-2-1 = stagepkgs-1 // { patch     = patch-2;
                                   shell     = bash-2;
                                   coreutils = coreutils-2;
                                   gnumake   = gnumake-2;
                                   gawk      = gawk-2;
                                   gnutar    = gnutar-2;
                                   gnugrep   = gnugrep-2;
                                   gnused    = gnused-2;
                                   findutils = findutils-2;
                                   diffutils = diffutils-2;
                                 };

  stdenv-2-1 = make-stdenv { name = "stdenv-2-1";
                             stagepkgs = stagepkgs-2-1; };

  # pkgconf-2 :: derivation
  pkgconf-2  = callPackage ../bootstrap-pkgs/pkgconf/package.nix { stdenv = stdenv-2-1;
                                                                   stageid = "2";
                                                                 };

  nxfsenv-2-0a = nxfsenv-1;
  nxfsenv-2-0b = nxfsenv-2-0a;
  nxfsenv-2-0 = nxfsenv-2-0a // { which = which-2; };
  nxfsenv-2-1 = nxfsenv-2-0 // { diffutils = diffutils-2; };
  nxfsenv-2-2 = nxfsenv-2-1 // { findutils = findutils-2; };
  nxfsenv-2-3 = nxfsenv-2-2 // { gnused = gnused-2; };
  nxfsenv-2-4 = nxfsenv-2-3 // { gnugrep = gnugrep-2; };
  nxfsenv-2-5 = nxfsenv-2-4 // { gnutar = gnutar-2; };
  nxfsenv-2-6 = nxfsenv-2-5 // { ncurses = ncurses-2; };
  nxfsenv-2-7 = nxfsenv-2-6 // { shell = bash-2; };
  nxfsenv-2-8 = nxfsenv-2-7 // { gawk = gawk-2; };
  nxfsenv-2-9 = nxfsenv-2-8 // { gnumake = gnumake-2; };
  nxfsenv-2-10 = nxfsenv-2-9 // { coreutils = coreutils-2; };

  # m4-2 :: derivation
  m4-2       = callPackage ./nxfs-m4-2/package.nix { nxfsenv = nxfsenv-2-10; };
  # NOTE: stage3 perl gets pkgconf, libxcrypt
  # perl-2 :: derivation
  perl-2     = callPackage ./nxfs-perl-2/package.nix { nxfsenv = nxfsenv-2-10; };
  # file-2 :: derivation
  file-2     = callPackage ./nxfs-file-2/package.nix { nxfsenv = nxfsenv-2-10; };
  # zlib-2 :: derivation
  zlib-2     = callPackage ./nxfs-zlib-2/package.nix { nxfsenv = nxfsenv-2-10; };
  # patchelf-2 :: derivation
  patchelf-2 = callPackage ./nxfs-patchelf-2/package.nix { nxfsenv = nxfsenv-2-10; };
  # gperf-2 :: derivation
  gperf-2    = callPackage ./nxfs-gperf-2/package.nix { nxfsenv = nxfsenv-2-10; };
  # gzip-2 :: derivation
  gzip-2     = callPackage ./nxfs-gzip-2/package.nix { nxfsenv = nxfsenv-2-10; };
in
let
  nxfsenv-2-b13 = nxfsenv-2-10 // { m4 = m4-2;
                                    perl = perl-2; };

  # binutils-2 :: derivation
  binutils-2 = callPackage ./nxfs-binutils-2/package.nix { nxfsenv = nxfsenv-2-b13; };

  # autoconf-2 :: derivation
  autoconf-2 = callPackage ./nxfs-autoconf-2/package.nix { nxfsenv = nxfsenv-2-b13; };
in
let
  nxfsenv-2-b14 = nxfsenv-2-b13 // { autoconf = autoconf-2; };

  # automake-2 :: derivation
  automake-2 = callPackage ./nxfs-automake-2/package.nix { nxfsenv = nxfsenv-2-b14; };
in
let
  nxfsenv-2-c13 = nxfsenv-2-b13 // { file = file-2; };

  # flex-2 :: derivation
  flex-2 = callPackage ./nxfs-flex-2/package.nix { nxfsenv = nxfsenv-2-c13; };

  # gmp-2 :: derivation
  gmp-2 = callPackage ./nxfs-gmp-2/package.nix { nxfsenv = nxfsenv-2-c13; };
in
let
  nxfsenv-2-c14 = nxfsenv-2-c13 // { flex = flex-2; };
  # bison-2 :: derivation
  bison-2 = callPackage ./nxfs-bison-2/package.nix { nxfsenv = nxfsenv-2-c14; };
in
let
  nxfsenv-2-b15 = nxfsenv-2-b14 // nxfsenv-2-c14 // { bison = bison-2; };
  # texinfo-2 :: derivation
  texinfo-2 = callPackage ./nxfs-texinfo-2/package.nix { nxfsenv = nxfsenv-2-b15; };
in
let
  # mpr-2 :: derivation
  mpfr-2 = callPackage ./nxfs-mpfr-2/package.nix { nxfsenv = nxfsenv-2-c13;
                                                   gmp = gmp-2; };
in
let
  # mpc-2 :: derivation
  mpc-2  = callPackage ./nxfs-mpc-2/package.nix { nxfsenv = nxfsenv-2-c13;
                                                  mpfr = mpfr-2;
                                                  gmp = gmp-2;
                                                };
in
let
  # TODO: pkgconf, for consistency with stage3
  nxfsenv-2-d13 = nxfsenv-2-10 // { pkgconf = pkgconf-2;
                                    zlib = zlib-2;
                                  };

  # python-2 :: derivation
  python-2 = callPackage ./nxfs-python-2/package.nix { nxfsenv = nxfsenv-2-d13;
                                                       popen = popen-2;
                                                     };
in
let
  # wrapper for sort -- invokes coreutils.sort with LC_ALL env var set to C
  lc-all-sort-2 = callPackage ./nxfs-lc-all-sort-2/package.nix { nxfsenv = nxfsenv-2-10; };

  nxfsenv-2-16 = nxfsenv-2-10 // { binutils = binutils-2;
                                   perl     = perl-2;
                                   texinfo  = texinfo-2;
                                   bison    = bison-2;
                                   flex     = flex-2;
                                   file     = file-2;
                                   pkgconf  = pkgconf-2;
                                   m4       = m4-2;
                                   python   = python-2;
                                   zlib     = zlib-2;
                                   gperf    = gperf-2;
                                   patch    = patch-2;
                                   gzip     = gzip-2;
                                   patchelf = patchelf-2;
                                   which    = which-2;
                                 };
in
let
  nxfsenv-2-94 = nxfsenv-2-16 // { texinfo = texinfo-2; };

  # glibc-2 :: derivation   # glibc-x1-3 in stage3
  glibc-2 = callPackage ./nxfs-glibc-stage1-2/package.nix { nxfsenv = nxfsenv-2-94;
                                                            lc-all-sort = lc-all-sort-2;
                                                            locale-archive = locale-archive-1;
                                                            linux-headers = linux-headers-2;
                                                          };
in
let
  nxfsenv-2-95 = nxfsenv-2-94 // { glibc = glibc-2; };

  binutils-x0-wrapper-2 = callPackage ./nxfs-binutils-stage1-wrapper-2/package.nix { nxfsenv = nxfsenv-2-95;
                                                                                   };

  gcc-x0-wrapper-2 = callPackage ./nxfs-gcc-stage1-wrapper-2/package.nix { nxfsenv = nxfsenv-2-95; };
in
let
  # maybe need binutils wrapper ?
  nxfsenv-2-96 = nxfsenv-2-95 // { gcc = gcc-x0-wrapper-2; };  # or 2-95a

  # TODO: rename subdir to follow nxfs-gcc-x1-3 in stage3
  gcc-x1-2 = callPackage ./nxfs-gcc-stage1-2/package.nix { nxfsenv = nxfsenv-2-96;
                                                           mpc = mpc-2;
                                                           mpfr = mpfr-2;
                                                           gmp = gmp-2;
                                                         };
in
let
  # TODO: name = gcc-unwrapped instead of gcc-x1

  # nxfsenv-2-97 :: attrset
  nxfsenv-2-97 = nxfsenv-2-96 // { gcc-x1 = gcc-x1-2; };

  # gcc-x1-wrapper-2 :: derivation
  gcc-x1-wrapper-2 = callPackage ./nxfs-gcc-stage2-wrapper-2/package.nix { nxfsenv = nxfsenv-2-97; };
in
let
  # nxfsenv-2-98 :: attrset
  nxfsenv-2-98 = nxfsenv-2-97 // { gcc = gcc-x1-wrapper-2; };

  # libstdcxx-x2-2 :: derivation
  libstdcxx-x2-2 = callPackage ./nxfs-libstdcxx-stage2-2/package.nix { nxfsenv = nxfsenv-2-98;
                                                                       mpc = mpc-2;
                                                                       mpfr = mpfr-2;
                                                                       gmp = gmp-2;
                                                                       glibc = glibc-2;
                                                                     };
in
let
  # gcc-x2-wrapper-2 :: derivation
  gcc-x2-wrapper-2 = callPackage ./nxfs-gcc-stage3-wrapper-2/package.nix { nxfsenv = nxfsenv-2-98;
                                                                           gcc-unwrapped = gcc-x1-2;
                                                                           libstdcxx = libstdcxx-x2-2;
                                                                         };
in
let
  # TODO: omitting nxfsenv.libstdcxx (maybe rename to nxfsenv.cc.libstdcxx ?)

  # nxfsenv-2-99a :: attrset
  nxfsenv-2-99a = nxfsenv-2-98 // { gcc = gcc-x2-wrapper-2; };

  # nixifed-gcc-source-2 :: derivation
  nixified-gcc-source-2 = callPackage ./nxfs-nixify-gcc-source { bash = nxfsenv-2-99a.shell;
                                                                 file = nxfsenv-2-99a.file;
                                                                 coreutils = nxfsenv-2-99a.coreutils;
                                                                 findutils = nxfsenv-2-99a.findutils;
                                                                 grep = nxfsenv-2-99a.gnugrep;
                                                                 tar = nxfsenv-2-99a.gnutar;
                                                                 sed = nxfsenv-2-99a.gnused;
                                                                 nxfs-defs = nxfsenv-2-99a.nxfs-defs;
                                                               };

  # combined-glibc-linux-headers-2 :: derivation
  combined-glibc-linux-headers-2 = callPackage ../bootstrap-pkgs/combine-glibc-linux-headers/package.nix
    {
      nxfsenv = nxfsenv-2-99a;
      glibc = glibc-2;
      linux-headers = linux-headers-2;
    };

  # gcc-x3-2 :: derivation
  gcc-x3-2 = callPackage ./nxfs-gcc-stage2-2/package.nix  { nxfsenv = nxfsenv-2-99a;
                                                            nixified-gcc-source = nixified-gcc-source-2;
                                                            mpc = mpc-2;
                                                            mpfr = mpfr-2;
                                                            gmp = gmp-2;
                                                            binutils-wrapper = binutils-x0-wrapper-2;
                                                            glibc = glibc-2;
                                                          };
in
let
  # nxfsenv-2-100 :: attrset
  nxfsenv-2-100 = nxfsenv-2-99a // { gcc-unwrapped = gcc-x3-2; };

  # gcc-wrapper-2 :: derivation
  gcc-wrapper-2 = callPackage ./nxfs-gcc-wrapper-2/package.nix { nxfsenv = nxfsenv-2-100;
                                                                 bintools = binutils-x0-wrapper-2;
                                                                 glibc = glibc-2;
                                                               };
in
let
  stage2env = buildEnv { name = "stage2env";
                         paths = [ gcc-wrapper-2
                                   gcc-x3-2
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
                                   file-2
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
  inherit gcc-x3-2;
  inherit nixified-gcc-source-2;
  inherit gcc-x2-wrapper-2;
  inherit libstdcxx-x2-2;
  inherit gcc-x1-wrapper-2;
  inherit gcc-x1-2;
  inherit binutils-x0-wrapper-2;
  inherit gcc-x0-wrapper-2;
  inherit glibc-2;
  inherit python-2;
  inherit mpc-2;
  inherit mpfr-2;
  inherit gmp-2;
  inherit texinfo-2;
  inherit bison-2;
  inherit flex-2;
  inherit automake-2;
  inherit autoconf-2;
  inherit binutils-2;
  inherit perl-2;
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
  inherit combined-glibc-linux-headers-2;
  inherit linux-headers-2;
}
