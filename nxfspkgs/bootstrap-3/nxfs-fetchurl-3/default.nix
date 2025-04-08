{
  nxfsenv-3
} :

let
  cacert = nxfsenv-3.cacert;
  curl = nxfsenv-3.curl;
in

nxfsenv-3.mkDerivation {
  name = "nxfs-fetchurl-3";

  buildPhase = ''

  '';

  buildInputs = [
    curl
    cacert
  ];
}
