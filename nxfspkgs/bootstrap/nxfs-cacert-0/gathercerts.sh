#!/bin/bash
#
# see bootstrap/README for context
#

set -euo pipefail

# ugh this is messy for ubuntu.
# cacerts in /etc/ssl/cert,  but contain symlinks to multiple
# locations in /usr/share
#

declare sslrootdir=${SSL_ROOT_DIR:-}
declare sslcertdir=${SSL_CERT_DIR:-}

if [[ -z "$sslcertdir" ]] && [[ -z "$sslcertdir" ]]; then
    sslrootdir=$(openssl version -d | sed -e 's|OPENSSLDIR: "\(.*\)"|\1|')

    if [[ -z $sslrootdir ]]; then
        >&2 echo "copy2nix: expected non-empty SSL_ROOT_DIR (could not get from openssl)"
        exit 1
    fi

    sslcertdir=${sslrootdir}/certs
fi

if [[ -z "$sslcertdir" ]]; then
    >&2 echo "copy2nix: expected non-empty SSL_CERT_DIR (could not infer from openssl)"
    exit 1
fi

if [[ -L "$sslcertdir" ]]; then
    sslcertdir=$(readlink -f "$sslcertdir")
fi

if [[ ! -d "$sslcertdir" ]]; then
    >&2 echo "copy2nix: expected directory SSL_CERT_DIR [$sslcertdir]"
fi

declare name=cacert

rm -rf ./${name}
mkdir -p ./${name}
rsync -a ${sslcertdir}/* ./${name}/

>&2 echo "copy2nix: copied"
>&2 echo "copy2nix: scanning for symlinks.."

for i in ./${name}/*; do
    #>&2 echo "copy2nix: consider [$i]"
    if [[ -L $i ]]; then
        declare dest=$(readlink $i)

        if [[ $(dirname $dest) != '.' ]]; then
            #>&2 echo "copy2nix: found: $dest"
            rm $i
            cp $dest $i
        fi
    fi
done

#tar cvf cert.tar ./${name}
