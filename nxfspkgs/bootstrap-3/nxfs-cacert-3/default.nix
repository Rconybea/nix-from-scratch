{
  # nxfs-env-3 :: derivation-set
  nxfsenv-3,
} :

let
  version = "roly-1";
in

nxfsenv-3.mkDerivation {
  name = "nxfs-cacert-3";

  # Bootstrap from builtins.fetchurl
  src = builtins.fetchurl {
    url = "https://curl.se/ca/cacert.pem";
    sha256 = "0x8rpf36ny11jacszs18grq809v5f3fyp8sc88hl2jlhmynfd47j";
  };

  buildPhase = ''
    mkdir -p $out/etc/ssl/certs
    cp $src $out/etc/ssl/certs/ca-bundle.crt

    # maybe want convenience symlink? defer for now
    #ln -s ca-bundle.crt $out/etc/ssl/certs/ca-certificates.crt
  '';
}
