#/bin/bash

# runs in toolchain/src directory

(cd ./gcc && patch -Np1 -i ../../fix-libstdcxx-v3-tzdb-mutex.patch)
