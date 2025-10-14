{
  # nxfsenv :: attrset
  nxfsenv,
} :

let
  version = "0.18.0";
in

nxfsenv.mkDerivation {
  name         = "nxfs-patchelf-3";
  version      = version;

  src          = builtins.fetchTarball { name = "patchelf-${version}-source";
                                         url = "https://github.com/NixOS/patchelf/releases/download/${version}/patchelf-0.18.0.tar.gz";
                                         sha256 = "0s328cmgrbhsc344q323dhg70h8lf8532ywjf8jwjirxq6a5h06w"; };

  buildPhase = ''
    set -euo pipefail

    src2=$src
    #src2=$TMPDIR/src2
    builddir=$TMPDIR/build

    mkdir -p $src2
    mkdir -p $builddir

    bash_program=$bash/bin/bash

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$bash_program"

    (cd $builddir && $bash_program $src2/configure --prefix=$out CC=nxfs-gcc CFLAGS= LDFLAGS="-Wl,-enable-new-dtags")

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)
'';

  buildInputs = [ nxfsenv.gcc_wrapper
                  nxfsenv.binutils
                  nxfsenv.gnumake
                  nxfsenv.gawk
                  nxfsenv.gnutar
                  nxfsenv.gnugrep
                  nxfsenv.gnused
                  nxfsenv.findutils
                  nxfsenv.diffutils
                  nxfsenv.coreutils
                  nxfsenv.shell ];

} // {
  # experiment.
  # Encountered problem with nixpkgs builds-on-top-of-nxfs, where
  # it (specifically stdenv/generic/default.nix, invoked from stdenv2nix-minimal)
  # complains if nixpkgs.patchelf does not set this passthru.
  #
  passthru.isFromBootstrapFiles = true;
}
