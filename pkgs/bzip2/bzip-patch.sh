#!/usr/bin/env bash

# runs in *source* directory

patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch
sed -i 's:\(ln -s -f \)$(PREFIX)/bin/:\1:' Makefile
sed -i 's:(PREFIX)/man:(PREFIX)/share/man:g' Makefile
