{
  # stdenv :: attrset+derivation
  stdenv,
  # bintools :: derivation -- not wrapped
  bintools,
  # libc :: derivation
  libc,
  # stageid :: string -- "2" for stage2 etc.
  stageid,
} :

stdenv.mkDerivation {
  name = "binutils-x0-wrapper-${stageid}";
  version = bintools.version;
  system = builtins.currentSystem;

  src = ./src;

  inherit bintools libc;

  # TODO: support bintools_bin

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
            -e s:@binutils@:$bintools: \
            -e s:@glibc@:$libc: \
            $tmp
        chmod +x $tmp
        cp $tmp $out/bin
    }

    # bespoke wrappers
    prepare_wrapper ar $src/ar-wrapper.sh
    prepare_wrapper ld $src/ld-wrapper.sh
    prepare_wrapper strip $src/strip-wrapper.sh

    # TODO: objcopy needs more care than we take here.
    #       Need to preserve the same sections that
    #       we keep in strip for example

    ln -s $bintools/bin/addr2line $out/bin
    ln -s $bintools/bin/as $out/bin
    ln -s $bintools/bin/c++filt $out/bin
    ln -s $bintools/bin/elfedit $out/bin
    ln -s $bintools/bin/gprof $out/bin
    ln -s $bintools/bin/nm $out/bin
    ln -s $bintools/bin/objcopy $out/bin
    ln -s $bintools/bin/objdump $out/bin
    ln -s $bintools/bin/ranlib $out/bin
    ln -s $bintools/bin/readelf $out/bin
    ln -s $bintools/bin/size $out/bin
    ln -s $bintools/bin/strings $out/bin

    # omit ld.bfd,  that's deliberately excluded
  '';

  buildInputs = [ ];
}
