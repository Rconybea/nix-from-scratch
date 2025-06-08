#!/usr/bin/env bash

# runs in *source* directory

sed '/LLVM_COMMON_CMAKE_UTILS/s:../cmake:llvm-cmake-18.src:' -i CMakeLists.txt
sed '/LLVM_THIRD_PARTY_DIR/s:../third-party:llvm-third-party-18.src:' -i cmake/modules/HandleLLVMOptions.cmake

grep -rl '#!.*python' | xargs --replace=xx sed -i '1s:python$:python3:' xx

# ensure we install FileCheck

sed 's:utility:tool:' -i utils/FileCheck/CMakeLists.txt
