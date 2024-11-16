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

# LFS uses DESTDIR=${prefix} here, because it's setting up chroot environment
make TIC_PATH=./progs/tic install
sed -e 's/^#if.*XOPEN.*$/#if 1/' -i ${prefix}/include/ncursesw/curses.h

(cd ${prefix}/lib && ln -sv libncursesw.so libncurses.so)
(cd ${prefix}/lib && ln -sfv libncurses.so libcurses.so)
#(cd ${prefix}/lib && ln -sfv libncurses.a libcurses.a)
