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
            2>&1 echo "error: $self_name: unexpected argument [$1]"
            usage
            exit 1
            ;;
    esac
    shift
done

if [[ -z ${prefix} ]]; then
    2>&1 echo "error: ${self_name}: expected non-empty PREFIX (set with --prefix=PREFIX)"
    exit 1
fi

set -x
set -e

echo "$self_name: prefix=${prefix}"

# e.g. cd /home/roland/ext/lib && ln -sf /home/roland/ext2
(cd ${prefix}/lib && ln -sfv libncurses.so libcurses.so)
(cd ${prefix}/lib && ln -sfv libncurses.a libcurses.a)


