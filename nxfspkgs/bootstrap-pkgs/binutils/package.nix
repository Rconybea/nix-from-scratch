{
  # stdenv :: attrset+derivation
  stdenv,
  # perl :: derivation
  perl,
  # stageid :: string
  stageid,
} :

let
  version = "2.43.1";
in

stdenv.mkDerivation {
  name         = "nxfs-binutils-${stageid}";
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

    sed -i -e "s:/bin/sh:$shell:" $src2/mkinstalldirs

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$shell"

    CCFLAGS=
    LDFLAGS="-Wl,-enable-new-dtags"

    # -e: stop questions after config.sh
    # -s: silent mode
    #
    # removing -Dcpp=nxfs-gcc (why did we need this)
    #
    (cd $builddir && $shell $src2/configure --prefix=$out)

    (cd $builddir && make SHELL=$CONFIG_SHELL MAKEINFO=true)

    (cd $builddir && make install SHELL=$CONFIG_SHELL MAKEINFO=true)
    '';

  buildInputs = [ perl ];
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
