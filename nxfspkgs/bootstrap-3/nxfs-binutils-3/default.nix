{
  # nxfsenv   :: { mkDerivation :: attrs -> derivation,
  #                gcc-wrapper :: derivation  (also as gcc_wrapper)
  #                binutils    :: derivation
  #                perl        :: derivation
  #                gawk        :: derivation
  #                gnumake     :: derivation
  #                gnugrep     :: derivation
  #                gnutar      :: derivation
  #                gnused      :: derivation
  #                coreutils   :: derivation
  #                bash        :: derivation
  #                glibc       :: derivation
  #                nxfs-defs   :: { target_tuple :: string }
  #              }
  nxfsenv,
  # nxfsenv-3 :: {
  #                m4          :: derivation
  #                perl        :: derivation
  #                pkgconf     :: derivation
  #                coreutils   :: derivation
  #                gnumake     :: derivation
  #                gawk        :: derivation
  #                bash        :: derivation
  #                gnutar      :: derivation
  #                gnugrep     :: derivation
  #                gnused      :: derivation
  #                findutils   :: derivation
  #                diffutils   :: derivation
  #              }
  nxfsenv-3,
  # libxcrypt :: derivation
  libxcrypt
} :

let
  version = "2.43.1";
in

nxfsenv.mkDerivation {
  name         = "nxfs-binutils-3";
  version      = version;

  src          = builtins.fetchTarball { name = "binutils-${version}-source";
                                         url = "https://sourceware.org/pub/binutils/releases/binutils-${version}.tar.xz";
                                         sha256 = "1z0lq9ia19rw1qk09i3im495s5zll7xivdslabydxl9zlp3wy570"; };

  buildPhase = ''
    set -e

    src2=$TMPDIR/src2
    #builddir=$src2
    builddir=$TMPDIR/build

    mkdir -p $src2
    mkdir -p $builddir

    # 1. copy source tree to temporary directory,
    #
    (cd $src && (tar cf - . | tar xf - -C $src2))

    # 2. since we're modifying source tree,
    #    will need to be able to write there
    #
    chmod -R +w $src2

    bash_program=$bash/bin/bash

    sed -i -e "s:/bin/sh:$bash_program:" $src2/mkinstalldirs

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$bash_program"

    CCFLAGS=
    LDFLAGS="-Wl,-enable-new-dtags"

    # -e: stop questions after config.sh
    # -s: silent mode
    #
    # removing -Dcpp=nxfs-gcc (why did we need this)
    #
    (cd $builddir && $bash_program $src2/configure --prefix=$out)

    (cd $builddir && make SHELL=$CONFIG_SHELL MAKEINFO=true)

    (cd $builddir && make install SHELL=$CONFIG_SHELL MAKEINFO=true)
    '';

  buildInputs = [ libxcrypt
                  nxfsenv.gcc_wrapper
                  nxfsenv.binutils
                  nxfsenv-3.perl
                  nxfsenv-3.pkgconf
                  nxfsenv-3.gnumake
                  nxfsenv-3.gawk
                  nxfsenv-3.gnutar
                  nxfsenv-3.gnugrep
                  nxfsenv-3.gnused
                  nxfsenv-3.findutils
                  nxfsenv-3.diffutils
                  nxfsenv-3.coreutils
                  nxfsenv-3.bash
                ];
} // {
  # experiment  - for nxfs bridge-to-nixpkgs.
  # ----------
  # 1. Goal is to construct a stdenv that satisfies nixpkgs from within nix-from-scratch.
  # 2. Have partial success by
  #    a. constructing a set of packages  (see nxfs-bootstrap-pgks in [nix-from-scratch/nxfspkgs/nxfspkgs.nix])
  #    b. invoking nixpkgs/stdenv/generic/default.nix (see [nix-from-scratch/nxfspkgs/stdenv-to-nix/default.nix])
  #       hoping to fill in a bunch of nixpkgs-specific details.
  #    Result:
  #    c. allows us to build assorted nixpkgs packages, but
  #    d. requires us to override stdenv separately for each package
  #       e.g. overlay:
  #         self: super: { ... foo = super.foo.override { stdenv = stdenv2nix-minimal; }; }
  #    e. Observe that overriding stdenv this way bypasses nixpkgs stdenv tower
  #       [nixpkgs/pkgs/stdenv/booter.nix] -> [nixpkgs/pkgs/stdenv/linux/default.nix]
  #
  # 3. Trying to replace nixpkgs.stdenv:
  #      self: super: { stdenv = stdenv2nix-minimal; }
  #    fails assert in nixpkgs/pkgs/stdenv/booter.nix -> nixpkgs/pkgs/stdenv/linux/default.nix:
  #      assert isFromBootstrapFiles prevStage.binutils.bintools
  #    This implies the role of nixpkgs.stdenv is not the same as stdenv given as package override,
  #    since nixpkgs insists on 'booting it'.
  #
  # 4. We already introduced
  #      passthru.isFromBootstrapFiles = true
  #    for gcc-x3-3 (see nix-from-scratch/nxfspkgs/bootstrap-3/nxfs-gcc-x3-3/default.nix,
  #    try the same here.
  #
  passthru.isFromBootstrapFiles = true;
}
