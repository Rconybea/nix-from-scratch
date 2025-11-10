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
  lib = {
    #buildEnv = import ./lib/makeEnv.nix;
    makeCallPackage = import ./lib/makeCallPackage.nix;
    optionalAttrs = import ./lib/optionalAttrs.nix;
  };

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

  # placeholder for new version of stage1 bootstrap.  intend to replace bootstrap-1
  stage1pkgs = bootstrap-1;
  # new version of stage2 bootstrap.  intend to replace bootstrap-2
  stage2pkgs = (import ./bootstrap-2/stage2pkgs.nix) args;
  stage3pkgs = (import ./bootstrap-3/stage3pkgs.nix) args;
in

let
  # envpkgs :: attrset
  envpkgs = {
    # would like to drop this.
    # need autotools/default.nix to take nxfsenv instead of pkgs
#    nxfsenv = nxfsenv-2;
  };

  # allPkgs :: attrset
  allPkgs = nxfspkgs // envpkgs;

in
let
  # which-3, diffutils-3 :: derivation
  inherit (stage3pkgs)
    which-3 diffutils-3 findutils-3 gnused-3 gnugrep-3 bzip2-3 gnutar-3
    bash-3 popen-3 gawk-3 gnumake-3 coreutils-3 pkgconf-3 m4-3 file-3
    zlib-3 gzip-3 patch-3 gperf-3 patchelf-3 libxcrypt-3 perl-3
    openssl-3 xz-3 curl-3 cacert-3 fetchurl-3 test-fetch-3
    binutils-3 autoconf-3 automake-3 flex-3 bison-3 gmp-3 mpfr-3 mpc-3 texinfo-3
    python-3 lc-all-sort-3 glibc-x1-3 gcc-x0-wrapper-3 binutils-x0-wrapper-3
    gcc-x1-3 gcc-x1-wrapper-3 libstdcxx-x2-3 gcc-x2-wrapper-3 gcc-x3-3
    gcc-wrapper-3;
in
let
  # callPackage :: path -> attrset -> result,
  # where path is a nix expression that evalutes to :: result
  #
  callPackage = lib.makeCallPackage allPkgs;
  #
in
let
  nixpkgspath = <nixpkgs>;
  nixpkgs = import nixpkgspath {  };
in
let
  # <nixpkgs>.lib
  lib-nixpkgs = nixpkgs.lib;
in
let
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
  # editor bait: binutils-wrapper
  #
  bintools-wrapper-nxfs2nix = callPackage (nixpkgspath + "/pkgs/build-support/bintools-wrapper")
    { name                   = "bintools-wrapper-nxfs2nix";
      lib                    = nixpkgs.lib;
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
  # gcc-wrapper-nxfs2nix :: derivation
  gcc-wrapper-nxfs2nix = callPackage (nixpkgspath + "/pkgs/build-support/cc-wrapper")
    {
      name                   = "gcc-wrapper-nxfs2nix";
      lib                    = nixpkgs.lib;
      stdenvNoCC             = stdenv2nix-no-cc;
      runtimeShell           = bash-3;
      cc                     = gcc-x3-3;
      libc                   = glibc-x1-3;
      bintools               = bintools-wrapper-nxfs2nix;
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
      # gcc, binutils are special here.
      #
      # ----------------------------------------------------------------
      # WARNING: to be used in stdenv, attrs added below must also add to
      #          stdenv-to-nix argsStdenv.initialPath
      # ----------------------------------------------------------------
      #
      nxfs-bootstrap-pkgs = {
        system    = nxfs-defs.system;
        gcc       = gcc-wrapper-nxfs2nix;
        binutils  = bintools-wrapper-nxfs2nix;
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
  #   > builtins.attrNames patchelf-nxfs2nix
  #   > patchelf-nxfs2nix.stdenv.cc --> nxfs-gcc-wrapper-14.2.0.drv
  #   > patchelf-nxfs2nix.stdenv.cc.cc --> nxfs-gcc-x3-3.drv
  #
  patchelf-nxfs2nix = (callPackage (nixpkgspath + "/pkgs/development/tools/misc/patchelf")
    {
      stdenv   = stdenv2nix-minimal;
      fetchurl = stdenv2nix-minimal.fetchurlBoot;
      lib      = nixpkgs.lib;
    });
in
let
  ################################################################
  # Try building up curl deps..
  # Look at nixpkgs/pkgs/top-level/all-packages.nix as

  testers-nxfs2nix = callPackage (nixpkgspath + "/pkgs/build-support/testers") { };

  curl-nxfs2nix = callPackage (nixpkgspath + "/pkgs/tools/networking/curl")
    {
      stdenv = stdenv2nix-minimal;
      fetchurl = stdenv2nix-minimal.fetchurlBoot;
      lib = nixpkgs.lib;
    };

in
let
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
        # --------------------------------
        # stdenv: this assignment isn't immediate effective.  Triggers bootstrap asserts:
        # (1) isFromBootstrapFiles (prevStage).binutils.bintools
        #stdenv = stdenv2nix-minimal;
        # --------------------------------

        # nixpkgs doesn't care about this
        stage3pkgs = stage3pkgs;

        # glibc, glibcLocales: otherwise nixpkgs will look too closely at our
        # bespoke stdenv (+ get infinite regress)
        glibc = self.stdenv.cc.libc;
        glibcLocales = self.stdenv.cc.libc.locales;

        # why did we think we needed this?  It works for many packages,
        # but not zstd
        #
        #fetchurl = stdenv2nix-minimal.fetchurlBoot;
        fetchurl = super.fetchurl.override {
          curl = curl-3;
          cacert = cacert-3;
        };

        fetchpatch = super.fetchpatch.override {
          # skipping version from __splicedPackages
          patchutils = self.patchutils_0_3_3 or self.patchutils;
        };

        expect = super.expect.overrideAttrs (old: {
          NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "")
                               + " -Wno-error=incompatible-pointer-types";
        });

        # tests fail in sandbox; complains about running out of PTYs
        libffi = super.libffi.overrideAttrs (old: {
          doCheck = false;
        });

#        # our nixcpp 2.24.9 has abug involving sandbox stdout,
#        # affects subprocesses that dup stdout.
#        # on 2nd loop -- looks like this was apparmor interference
#        # from ubuntu 24.04. boo!
#
#        pcre2 = super.pcre2.overrideAttrs (old: {
#          preConfigure = ''
#            ${old.preConfigure or ""}
#            # workaround for nixcpp 2.24.89 sandbox bug
#            # nuke heredoc cat to stdout (knowing that we're silencing
#            # heredoc-based error output too)
#            #
#            sed -i 's/^cat <<EOF$/: <<EOF/' configure
#          '';
#        });
      };

  # nixpkgs anatomy
  #   nixpkgs/default.nix
  #   -> nixpkgs/pkgs/toplevel/impure.nix
  #   -> nixpkgs/pkgs/toplevel/default.nix
  #      -> nixpkgs/pkgs/toplevel/stage.nix    (uses stdenv, stdenvNoCC)
  #         -> nixpkgs/pkgs/toplevel/splice.nix
  #         -> nixpkgs/pkgs/toplevel/aliases.nix
  #      -> nixpkgs/pkgs/stdenv/booter.nix     (assembles stdenv)

  # This is nixpkgs collection, but with overlay  that uses nxfs tools at
  # beginning of bootstrap
  #
  nxfs2nix = import nixpkgspath {
    config = { allowAliases = true;
               allowUnsupportedSystem = false;
               allowBroken = false;
               checkMeta = false;
               configurePlatformsByDefault = true;
               enableParallelBuildingByDefault = false;
               strictDepsByDefault = false;
             };

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

    overlays = [ overlay ];
  };
in
let

  gnu-config-nixpkgs2 = nixpkgs.gnu-config;

  # file-nixpkgs2: no good, attempts nixpkgs bootstrap
  file-nixpkgs2 = nixpkgs.file;

  pkg-config-unwrapped-nixpkgs2 = nixpkgs.pkg-config-unwrapped;  # working

  updateAutotoolsGnuConfigScriptsHook-nixpkgs2 = nixpkgs.updateAutotoolsGnuConfigScriptsHook;

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
#  cmake-minimal-nixpkgs = (callPackage (nixpkgspath + "/pkgs/by-name/cm/cmake/package.nix")
#    {
#      stdenv = stdenv2nix-minimal;
#      fetchurl = stdenv2nix-minimal.fetchurlBoot;
#      lib = nixpkgs.lib;
#      zlib = zlib-nixpkgs;
#      isMinimalBuild = true;
#
#      testers = false;
#      minizip = false;
#      writeScript = nixpkgs.lib.writeScript;
#    });
in
let
  # runCommandWith needs lib.optionalAttrs, but nothing else from lib
  #
  runCommandWith = import ./build-support/run-command-with/run-command-with.nix
    {
      inherit lib;
      stdenv = stage3pkgs.stdenv;
    };
  lib' = lib;
in
let
  lib = lib' // { inherit runCommandWith; };

  runCommand = import ./build-support/run-command/run-command.nix
    {
      inherit lib;
      stdenv = stage3pkgs.stdenv;
    };
in
let
  pkgs = {
    # lib :: { makeCallPackage, optionalAttrs, runCommandWith }
    inherit lib;

    # nixpkgs has similar infinite regress here,
    # and nix-shell relies on .pkgs
    #
    inherit pkgs;

    # nxfs2nix: contents of <nixpkgs>, but with overlay substituting nxfs toolchain
    # Things that work (6nov2025)
    #  $ nxfs-build -A nxfs2nix.patchelf
    #  $ nxfs-build -A nxfs2nix.pkgconf
    #  $ nxfs-build -A nxfs2nix.gnum4
    #  $ nxfs-build -A nxfs2nix.perl
    #  $ nxfs-build -A nxfs2nix.xz
    #  $ nxfs-build -A nxfs2nix.bison
    #  $ nxfs-build -A nxfs2nix.texinfo
    #  $ nxfs-build -A nxfs2nix.gzip
    #  $ nxfs-build -A nxfs2nix.gnugrep
    #
    nxfs2nix                                    = nxfs2nix;

    stage1pkgs                                  = stage1pkgs;
    stage2pkgs                                  = stage2pkgs;
    stage3pkgs                                  = stage3pkgs;

    ################################################################

    curl-nxfs2nix                               = curl-nxfs2nix;

    ################################################################
    # nix-shell support

    # load-bearing for nxfs-shell.
    # runCommand :: name -> env -> buildcommand -> derivation
    inherit runCommand;

    # load-bearing for nxfs-shell
    bashInteractive                             = stage3pkgs.bash-3;

    ################################################################

    # deprecated
    nxfs-autotools                              = nxfs-autotools;

    ################################################################

    # these all accessible via stage3pkgs.which-3 etc.
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

    nxfs-defs                                   = import ./bootstrap-1/nxfs-defs.nix;

    # ================================================================
    # bridge to nixpkgs
    # ----------------------------------------------------------------

    stdenv-stages                               = stdenv-stages;
    stdenv2nix-no-cc                            = stdenv2nix-no-cc;
    stdenv2nix-minimal                          = stdenv2nix-minimal;

    bintools-wrapper-nxfs2nix                    = bintools-wrapper-nxfs2nix;
    gcc-wrapper-nxfs2nix                         = gcc-wrapper-nxfs2nix;

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
    #xz-nixpkgs                                  = xz-nixpkgs;
    pkg-config-unwrapped-nixpkgs2               = pkg-config-unwrapped-nixpkgs2;
    pkg-config-unwrapped-nixpkgs                = pkg-config-unwrapped-nixpkgs;

    patchelf-nxfs2nix                            = patchelf-nxfs2nix;
    #  bzip2-nixpkgs2                             = bzip2-nixpkgs2;
    file-nixpkgs2                               = file-nixpkgs2;
    #  coreutils-nixpkgs2                         = coreutils-nixpkgs2;
    #cmake-minimal-nixpkgs                       = cmake-minimal-nixpkgs;
  };
in
pkgs
