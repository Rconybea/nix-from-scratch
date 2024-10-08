#!/bin/bash

self_name=$(basename ${0})

usage() {
    echo "$self_name: [--prefix=PREFIX]"
}

prefix=

while [[ $# > 0 ]]; do
    case "$1" in
        --prefix=*)
            prefix="${1#*=}"
            ;;
        *)
            usage
            exit 1
            ;;
    esac

    shift
done

if [[ -n ${prefix} ]]; then
    sed -i -e "s|^PREFIX:=.*$|PREFIX:=${prefix}|" mk/prefix.mk
fi
