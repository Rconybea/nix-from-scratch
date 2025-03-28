{
  # nxfsenv :: { mkDerivation :: attrs -> derivation,
  #              gcc-wrapper :: derivation,  (also as gcc_wrapper)
  #              binutils    :: derivation,
  #              gawk        :: derivation,
  #              gnumake     :: derivation,
  #              gnugrep     :: derivation,
  #              gnutar      :: derivation,
  #              gnused      :: derivation,
  #              coreutils   :: derivation,
  #              bash        :: derivation,
  #              glibc       :: derivation,
  #              nxfs-defs   :: { target_tuple :: string }
  #            }
  nxfsenv,
} :

let
  version = "0.1";
in

nxfsenv.mkDerivation {
  name         = "nxfs-which-3";
  version      = version;

  src          = ./which.sh;

  buildPhase = ''
    set -e

    bash_program=$bash/bin/bash

    mkdir -p $out/bin

    tmp=$TMPDIR/$(basename $src)

    cp $src $tmp

    sed -i -e '1s:/bin/sh:'$bash_program':' $tmp

    cp $tmp $out/bin/which
  '';

  buildInputs = [
    nxfsenv.gnused
    nxfsenv.coreutils
    nxfsenv.bash
  ];
}
