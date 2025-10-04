#!/bin/bash

set -euo pipefail

declare prefix
# /opt/rustc-1.80
prefix=

while [[ $# > 0 ]]; do
    case "$1" in
        --prefix=*)
            prefix=${1#*=}
            ;;
    esac

    shift
done

if [[ -z ${prefix} ]]; then
    echo "error: expected non-empty PREFIX (use --prefix=PREFIX)"
    exit 1
fi

cmake \
    -B . \
    -S ../src \
    -DCMAKE_INSTALL_PREFIX=${prefix} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_RPATH=${prefix}/lib \
    -DLLVM_ENABLE_FFI=ON \
    -DLLVM_BUILD_LLVM_DYLIB=ON \
    -DLLVM_LINK_LLVM_DYLIB=ON \
    -DLLVM_ENABLE_RTTI=ON \
    -DLLVM_TARGETS_TO_BUILD='host;AMDGPU' \
    -DLLVM_BINUTILS_INCDIR=${prefix}/include \
    -DLLVM_INCLUDE_BENCHMARKS=OFF \
    -DCLANG_DEFAULT_PIE_ON_LINUX=ON \
    -DCLANG_CONFIG_FILE_SYSTEM_DIR=${prefix}/etc/clang \
    -Wno-dev \
    -DCMAKE_CXX_FLAGS="-I${prefix}/include" \
    -DCMAKE_SHARED_LINKER_FLAGS="-L${prefix}/lib -Wl,-rpath,${prefix}/lib" 

#     CFLAGS="-I${prefix}/include" LDFLAGS="-L${prefix}/lib -Wl,-rpath,${prefix}/lib"


