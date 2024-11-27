#!/usr/bin/env bash

# runs in *source* directory

patch -Np1 -i ../coreutils-9.5-i18n-2.patch
echo "starting autoreconf, may take more than 10sec"
autoreconf
echo "autoreconf done"
