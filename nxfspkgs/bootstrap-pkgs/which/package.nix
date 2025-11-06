{
  # stdenv :: derivation+attrset
  stdenv,
  # stageid :: integer  -- bootstrap stage calling this package. '2' or '3'
  stageid,
} :

let
  version = "0.1";
in

# difference between stage2 and stage3 is the provenance of the tools
# backed into stdenv
#
stdenv.mkDerivation {
  name         = "nxfs-which-${stageid}";
  version      = version;

  src          = ./which.sh;

  unpackPhase = ":";

  buildPhase = ''
    set -e

    mkdir -p $out/bin

    tmp=$TMPDIR/$(basename $src)

    cp $src $tmp

    sed -i -e '1s:/bin/sh:'$shell':' $tmp
    chmod +x $tmp

    cp $tmp $out/bin/which

  '';
}
