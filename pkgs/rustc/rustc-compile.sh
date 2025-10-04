#!/bin/bash

set -euo pipefail

export LIBSSH2_SYS_USE_PKG_CONFIG=1
export LIBSQLITE3_SYS_USE_PKG_CONFIG=1
export LDFLAGS="-L/home/roland/ext/lib, -Wl,-rpath,/home/roland/ext/lib"

python3 ../src/x.py build


