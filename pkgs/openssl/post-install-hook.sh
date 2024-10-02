#!/bin/bash
#

self_name=$(basename ${0})

usage() {
    echo "$self_name: --name=NAME --prefix=PREFIX"
}

name=
prefix=

while [[ $# > 0 ]]; do
    case "$1" in
        --name=*)
            name=${1#*=}
            ;;
        --prefix=*)
            prefix=${1#*=}
            ;;
        *)
            usage
            exit 1
            ;;
    esac

    shift
done

if [[ -z ${name} ]]; then
    2>&1 echo "error: $self_name}: expected non-empty NAME"
    exit 1
fi

if [[ -z ${prefix} ]]; then
    2>&1 echo "error: ${self_name}: expected non-empty PREFIX"
    exit 1
fi

# move docs to consistent place
if [[ -d ${prefix}/share/doc/openssl ]]; then
    rm -rf ${prefix}/share/doc/${name}
    mv -v ${prefix}/share/doc/openssl ${prefix}/share/doc/${name}
fi
