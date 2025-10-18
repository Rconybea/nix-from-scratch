{
  # stdenv :: derivation+attrset
  stdenv
} :

let
  version = "0.1";
in

stdenv.mkDerivation {
  name         = "nxfs-which-3";
  version      = version;

  src          = ./which.sh;

  buildPhase = ''
    set -e

    mkdir -p $out/bin

    tmp=$TMPDIR/$(basename $src)

    cp $src $tmp

    sed -i -e '1s:/bin/sh:'$shell':' $tmp

    cp $tmp $out/bin/which
  '';
}
