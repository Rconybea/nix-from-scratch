export CC=nxfs-gcc
export CXX=nxfs-g++
export LD=ld

# Add -I flags for headers
addCFlagsToNIXFlagsCompile() {
  export NIX_CFLAGS_COMPILE+=" -I$1/include"
}

# Add -L flags for libraries
addLDFlagsToNIXFlags() {
  export NIX_LDFLAGS+=" -L$1/lib"
}
