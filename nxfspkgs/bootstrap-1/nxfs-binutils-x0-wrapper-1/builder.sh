# similar to buildPhase from bootstrap-3/nxfs-binutils-x0-wrapper-3/package.nix

set -euo pipefail

shell=${bash}/bin/bash
PATH=${coreutils}/bin:${bash}/bin:${gnused}/bin

unwrapped_ld=${binutils}/bin/ld

builddir=$TMPDIR

mkdir -p $builddir/bin
mkdir -p $out/bin
mkdir -p $out/nix-support

prepare_wrapper() {
    name=$1
    template=$2

    tmp=$builddir/bin/$name
    cp $template $tmp
    sed -i \
        -e s:@prog@:$name: \
        -e s:@bash@:$shell: \
        -e s:@shell@:$shell: \
        -e s:@binutils@:$binutils: \
        -e s:@glibc@:$glibc: \
        $tmp
    chmod +x $tmp
    cp $tmp $out/bin
}

# bespoke wrappers
prepare_wrapper ar $src/ar-wrapper.sh
prepare_wrapper ld $src/ld-wrapper.sh
prepare_wrapper strip $src/strip-wrapper.sh

# TODO: perhaps objcopy needs more care than we take here?
#       Would want to preserve the same sections that
#       we keep in strip for example

ln -s $binutils/bin/addr2line $out/bin
ln -s $binutils/bin/as $out/bin
ln -s $binutils/bin/c++filt $out/bin
ln -s $binutils/bin/elfedit $out/bin
ln -s $binutils/bin/gprof $out/bin
ln -s $binutils/bin/nm $out/bin
ln -s $binutils/bin/objcopy $out/bin
ln -s $binutils/bin/objdump $out/bin
ln -s $binutils/bin/ranlib $out/bin
ln -s $binutils/bin/readelf $out/bin
ln -s $binutils/bin/size $out/bin
ln -s $binutils/bin/strings $out/bin

# setup hook cooperates with stdenv
# see make-stdenv/setup.sh
#
cp $setup_hook $out/nix-support/setup-hook
