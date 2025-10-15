{
  # nxfsenv :: attrset
  nxfsenv,

  # gcc-unwrapped :: derivation
  gcc-unwrapped
} :

let
  gcc = gcc-unwrapped;
  glibc = nxfsenv.glibc;

  #  nxfs-glibc-stage1-2 = nxfsenv.glibc-stage1;
  gnused              = nxfsenv.gnused;
  coreutils           = nxfsenv.coreutils;
  bash                = nxfsenv.shell;
  nxfs-defs           = nxfsenv.nxfs-defs;
in

nxfsenv.mkDerivation {
  name = "gcc-x1-wrapper-3";
  version = gcc.version;
  system = builtins.currentSystem;

  glibc = glibc;

  bash = bash;

  gcc_wrapper_script = ./gcc-wrapper.sh;
  gxx_wrapper_script = ./gxx-wrapper.sh;

  gcc = gcc;

  target_tuple = nxfs-defs.target_tuple;

  buildPhase = ''
    # script to
    # intercept calls to $gcc,
    # inject additional arguments (to point to custom glibc)
    #

    builddir=$TMPDIR

    bash_program=$bash/bin/bash

    unwrapped_gcc=$gcc/bin/gcc
    unwrapped_gxx=$gcc/bin/g++

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
    sed -i -e s:@bash@:$bash_program: $tmp
    sed -i -e s:@unwrapped_gcc@:$unwrapped_gcc: $tmp
    sed -i -e s:@glibc@:$glibc: $tmp
    chmod +x $tmp
    cp $tmp $out/bin
    cp $tmp $out/bin/nxfs-gcc

    # prepare gxx-wrapper script from template
    tmp=$builddir/bin/$gxx_basename
    cp $gxx_wrapper_script $tmp
    sed -i -e s:@bash@:$bash_program: $tmp
    sed -i -e s:@unwrapped_gxx@:$unwrapped_gxx: $tmp
    sed -i -e s:@glibc@:$glibc: $tmp
    chmod +x $tmp
    cp $tmp $out/bin
    cp $tmp $out/bin/nxfs-g++
  '';

  buildInputs = [ gcc glibc gnused coreutils bash ];
}
