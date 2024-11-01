#!/usr/bin/env bash

# runs in src/ directory

self_name=$(basename ${0})

usage() {
    echo "${self_name}:"
}

set -e

patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch

# remove $(PREFIX)/bin/ prefixes so symlinks are installed as relative paths
sed -i 's:\(ln -s -f \)$(PREFIX)/bin/:\1:' Makefile

# fix man page install location
sed -i 's:(PREFIX)/man:(PREFIX)/share/man:g' Makefile
