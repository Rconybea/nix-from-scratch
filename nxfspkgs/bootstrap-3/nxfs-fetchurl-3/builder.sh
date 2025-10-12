set -euo pipefail

source ${setupScript};

# Set up SSL certificates
export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
export CURL_CA_BUNDLE=${cacert}/etc/ssl/certs/ca-bundle.crt

echo "allCurlOpts=${allCurlOpts}"

header() {
  echo "====================================="
  echo "$1"
  echo "====================================="
}

tryDownload() {
  local url="$1"
  local out="$2"
  header "Downloading $url"

  set -x

  if curl \
    --fail \
    --location \
    --max-redirs 20 \
    --retry 3 \
    --disable-epsv \
    --cookie-jar $TMPDIR/cookies \
    --user-agent "Nix/custom-fetchurl" \
    --speed-limit 1000 \
    --speed-time 5 \
    ${allCurlOpts} \
    "$url" \
    -o "$out";
  then
      echo "curl -> 0"
      return 0
  else
      echo "curl -> non-zero"
      return 1
  fi
}

if $downloadToTemp; then
    tmpfile="${TMPDIR}/download"
else
    tmpfile="${out}"
fi

# Try each URL
success=false

echo "urls [${finalUrls}]"

for url in ${finalUrls}; do
    if [ "$success" != true ]; then
        echo "consider url [$url]"
        if tryDownload "${url}" "$tmpfile"; then
            success=true
        fi
    fi
done

if [ "$success" != true ]; then
    header "ERROR: All downloads failed"
    exit 1
fi

if ${downloadToTemp}; then
    mv "${tmpfile}" "${out}"
fi

${postFetch:-}

header "Download successful"
