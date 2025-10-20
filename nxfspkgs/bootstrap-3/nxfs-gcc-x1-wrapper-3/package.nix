{
  # stdenv :: attrset+derivation
  stdenv,
  # gcc-unwrapped :: derivation
  gcc-unwrapped,
  # glibc :: derivation
  glibc,
  # nxfs-defs :: derivation
  nxfs-defs,
} :

stdenv.mkDerivation {
  name = "gcc-x1-wrapper-3";
  version = gcc-unwrapped.version;
  system = builtins.currentSystem;

  inherit glibc;

  gcc_wrapper_script = ./gcc-wrapper.sh;
  gxx_wrapper_script = ./gxx-wrapper.sh;

  # cc: derivation for unwrapped gcc
  cc = gcc-unwrapped;

  target_tuple = nxfs-defs.target_tuple;

  buildPhase = ''
    # script to
    # intercept calls to $cc,
    # inject additional arguments (to point to custom glibc)
    #

    builddir=$TMPDIR

    unwrapped_gcc=$cc/bin/gcc
    unwrapped_gxx=$cc/bin/g++

    mkdir -p $builddir/bin

    gcc_basename=gcc
    gxx_basename=g++

    mkdir -p $out/bin

    # also provide secondary names
    #   nxfs-gcc
    #   nxfs-g++
    #
    # Might be helpful when diagnosing certain problems during bootstrap,
    # to use a name that's distinct from the destination binary's name,
    # so we can know which one's being invoked.

    # prepare gcc-wrapper script from template
    tmp=$builddir/bin/$gcc_basename
    cp $gcc_wrapper_script $tmp
    sed -i -e s:@bash@:$shell: $tmp
    sed -i -e s:@unwrapped_gcc@:$gcc_basename: $tmp
    sed -i -e s:@gcc@:$cc: $tmp
    sed -i -e s:@glibc@:$glibc: $tmp
    chmod +x $tmp
    cp $tmp $out/bin
    cp $tmp $out/bin/nxfs-gcc

    # prepare gxx-wrapper script from template
    tmp=$builddir/bin/$gxx_basename
    cp $gxx_wrapper_script $tmp
    sed -i -e s:@bash@:$shell: $tmp
    sed -i -e s:@unwrapped_gxx@:$gxx_basename: $tmp
    sed -i -e s:@gcc@:$cc: $tmp
    sed -i -e s:@glibc@:$glibc: $tmp
    chmod +x $tmp
    cp $tmp $out/bin
    cp $tmp $out/bin/nxfs-g++
  '';

  buildInputs = [ ];
}
