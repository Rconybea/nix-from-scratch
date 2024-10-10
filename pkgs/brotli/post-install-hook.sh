#!/usr/bin/env bash

self_name=$(basename ${0})

usage() {
    echo "$self_name: --prefix=PREFIX"
}

prefix=

while [[ $# > 0 ]]; do
    case "$1" in
        --prefix=*)
            prefix=${1#*=}
            ;;
        *)
            2>&1 echo "${self_name}: unexpected argument ${1}"
            usage
            exit 1
            ;;
    esac

    shift
done

if [[ -z ${prefix} ]]; then
    2>&1 echo "error: ${self_name}: expected non-empty PREFIX"
    exit 1
fi

# we are in package directory

patchelf --add-rpath ${prefix}/lib ${prefix}/bin/brotli
patchelf --add-rpath ${prefix}/lib ${prefix}/lib/libbrotlicommon.so
patchelf --add-rpath ${prefix}/lib ${prefix}/lib/libbrotlidec.so
patchelf --add-rpath ${prefix}/lib ${prefix}/lib/libbrotlienc.so

