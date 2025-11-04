{
  # stdenv :: attrset+derivation
  stdenv,
} :

let
  version = "roly-1";
in

stdenv.mkDerivation {
  name = "nxfs-cacert-3";

  # Bootstrap from builtins.fetchurl
  src = builtins.fetchurl {
    url = "https://curl.se/ca/cacert.pem";
    sha256 = "1vwxww2rzpf4vcmbyvzqwd1zis4njw1b5lkq81mil59y7pfhpi4a";
  };

  buildPhase = ''
    mkdir -p $out/etc/ssl/certs
    cp $src $out/etc/ssl/certs/ca-bundle.crt

    # maybe want convenience symlink? defer for now
    #ln -s ca-bundle.crt $out/etc/ssl/certs/ca-certificates.crt
  '';
}
