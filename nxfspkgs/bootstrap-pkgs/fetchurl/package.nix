{
  # stdenv :: derivation+attrset
  stdenv,
  # curl :: derivation
  curl,

  cacert
}:

args @
{
  # note url ignored if urls present
  url ? ""
, urls ? []
# expected hash for fixed-output derivation
, hash ? ""
, sha256 ? ""
, sha512 ? ""
, sha1 ? ""
, md5 ? ""
, name ? null
# curlOpts, curlOptsList: additional argument(s) to curl
, curlOpts ? ""
, curlOptsList ? []
, postFetch ? ""
# false; derivation output is contents of url.
# true:  url contents in $TMPDIR/download;
#        then can use postFetch to post-process
, downloadToTemp ? false
# e.g. for proxy settings
, impureEnvVars ? []
, meta ? {}
, passthru ? {}
, preferLocalBuild ? true
, ...
}:

let
  #bash = nxfsenv-3.bash;

  # Determine URLs
  hasUrl = url != "";
  hasUrls = urls != [];

  finalUrls =
    if hasUrls then urls
    else if hasUrl then [ url ]
    else throw "fetchurl requires 'url' or 'urls'";

  # Determine output name
  finalName =
    if name != null then name
    else baseNameOf (builtins.head finalUrls);

  # Determine hash
  hashArgs =
    if hash != "" then {
      # SRI format is self-describing
      outputHash = hash;
      outputHashAlgo = "";
    }
    else if sha512 != "" then {
      outputHash = sha512;
      outputHashAlgo = "sha512";
    }
    else if sha256 != "" then {
      outputHash = sha256;
      outputHashAlgo = "sha256";
    }
    else if sha1 != "" then {
      outputHash = sha1;
      outputHashAlgo = "sha1";
    }
    else if md5 != "" then {
      outputHash = md5;
      outputHashAlgo = "md5";
    }
    else
      throw "fetchurl requires a hash (hash, sha256, sha512, sha1, or md5)";

  # Build curl options
  allCurlOpts = curlOpts + " " + (builtins.concatStringsSep " " curlOptsList);

in stdenv.mkDerivation ({
  name = finalName;

  #builder = "${stdenv.shell}";  # already matches default
  args = [ ./builder.sh ];

  # runtime dependencies
  nativeBuildInputs = [ curl ];
  outputHashMode = "flat";

  inherit (hashArgs) outputHash outputHashAlgo;

  SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  inherit preferLocalBuild cacert downloadToTemp finalUrls allCurlOpts;

  allowSubstitutes = false;

  impureEnvVars = [
    # Allow proxy settings
    "http_proxy"
    "https_proxy"
    "ftp_proxy"
    "all_proxy"
    "no_proxy"
  ] ++ impureEnvVars;

  buildInputs = [ curl ];
} // removeAttrs args [
  # Remove:
  # 1. fetchurl-specific arguments (url, curlOpts, etc.):
  #    mkDerivation doesn't have a use for these
  # 2. Arguments we already processed or explicitly set (name, meta, etc.)
  #
  "url"
  "urls"
  "hash"
  "sha256"
  "sha512"
  "sha1"
  "md5"
  "name"
  "curlOpts"
  "curlOptsList"
  "postFetch"
  "downloadToTemp"
  "impureEnvVars"
  "preferLocalBuild"
])
