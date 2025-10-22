{
  # stdenv :: attrset+derivation
  stdenv,
  # binutils :: derivation  -- unwrapped binutils
  binutils,
  # glibc :: derivation
  glibc,
} :

stdenv.mkDerivation {
  name    = "binutils-x0-wrapper-3";
  version = binutils.version;
  system  = builtins.currentSystem;

  src = ./src;

  inherit binutils;
  inherit glibc;

  buildPhase = ''
    builddir=$TMPDIR

    mkdir -p $builddir/bin
    mkdir -p $out/bin

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

  '';

  buildInputs = [ binutils ];
}
