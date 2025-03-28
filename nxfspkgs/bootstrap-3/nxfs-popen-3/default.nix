{
  # nxfsenv   :: { mkDerivation :: attrs -> derivation,
  #                gcc-wrapper :: derivation  (also as gcc_wrapper)
  #                binutils    :: derivation
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
  #                bash        :: derivation
  #                gnutar      :: derivation
  #                gnugrep     :: derivation
  #                gnused      :: derivation
  #                findutils   :: derivation
  #                diffutils   :: derivation
  #              }
  nxfsenv-3,
  # popen-template :: derivation
  popen-template
} :

let
  # move to 3rd argument.
  nxfs-popen-template-2 = import ../../bootstrap-2/nxfs-popen-template-2/default.nix;
in

nxfsenv.mkDerivation {
  name = "nxfs-popen-3";

  popen_template = nxfs-popen-template-2;

  buildPhase = ''
    echo "popen_template=$popen_template"

    set -e

    bash_program=$bash/bin/bash

    mkdir -p $out/src

    cp $popen_template/src/nxfs_system.c $out/src/nxfs_system.c
    cp $popen_template/src/nxfs_popen.c $out/src/nxfs_popen.c

    sed -i -e '/^#define SHELL_PATH/s:@bash_path@:'$bash_program':' $out/src/nxfs_system.c
    sed -i -e '/^#define SHELL_PATH/s:@bash_path@:'$bash_program':' $out/src/nxfs_popen.c
  '';

  buildInputs = [
    nxfsenv.coreutils
    nxfsenv-3.gnused
    nxfsenv-3.bash
  ];
}
