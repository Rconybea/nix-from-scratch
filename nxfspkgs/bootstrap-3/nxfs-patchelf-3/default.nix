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

#  target_tuple = nxfs-defs.target_tuple;

  buildPhase = ''
    set -e

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
                  nxfsenv-3.gnumake
                  nxfsenv-3.gawk
                  nxfsenv-3.gnutar
                  nxfsenv-3.gnugrep
                  nxfsenv-3.gnused
                  nxfsenv-3.findutils
                  nxfsenv-3.diffutils
                  nxfsenv-3.coreutils
                  nxfsenv-3.bash ];

} // {
  # experiment.
  # Encountered problem with nixpkgs builds-on-top-of-nxfs, where
  # it (specifically stdenv/generic/default.nix, invoked from stdenv2nix-minimal)
  # complains if nixpkgs.patchelf does not set this passthru.
  #
  passthru.isFromBootstrapFiles = true;
}
