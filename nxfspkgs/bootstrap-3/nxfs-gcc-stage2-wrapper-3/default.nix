{
  # everything in nxfsenv is from bootstrap-2/
  #  nxfsenv :: { mkDerivation, ... }
  nxfsenv,
  #  nxfsenv-3 :: { coreutils, ... }
  nxfsenv-3,
  # glibc :: derivation
  glibc,
  # bootstrap-1 :: { ... }
  bootstrap-1
} :

let
  gcc = nxfsenv-3.gcc-stage1;

  nxfs-glibc-stage1-2 = nxfsenv.glibc-stage1;
  nxfs-sed-1          = bootstrap-1.nxfs-sed-1;
  nxfs-coreutils-1    = bootstrap-1.nxfs-coreutils-1;
  nxfs-bash-1         = bootstrap-1.nxfs-bash-1;
  nxfs-defs           = nxfsenv.nxfs-defs;
in

nxfsenv.mkDerivation {
  name = "gcc-stage2-wrapper-3";
  system = builtins.currentSystem;

  glibc = glibc;

  bash = nxfs-bash-1;
  sed = nxfs-sed-1;
  coreutils = nxfs-coreutils-1;
  gnused = nxfs-sed-1;

  gcc_wrapper_script = ./gcc-wrapper.sh;
  gxx_wrapper_script = ./gxx-wrapper.sh;

  gcc = gcc;

  target_tuple = nxfs-defs.target_tuple;

  buildPhase = ''
    # script to intercept calls to $gcc,
    # and inject additional arguments
    #

    echo "sed=$sed"
    echo "coreutils=$coreutils"
    echo "glibc=$glibc"
    echo "bash=$bash"

    echo "gcc_wrapper_script=$gcc_wrapper_script"
    echo "gxx_wrapper_script=$gxx_wrapper_script"

    echo "gcc=$gcc";

    builddir=$TMPDIR

    export PATH="$gcc/bin:$glibc/bin:$sed/bin:$coreutils/bin:$bash/bin"

    unwrapped_gcc=$gcc/bin/gcc
    unwrapped_gxx=$gcc/bin/g++

    mkdir -p $builddir/bin

    # x86_64-pc-linux-gnu-gcc
    gcc_basename=gcc
    # x86_64-pc-linux-gnu-gxx
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
    sed -i -e s:@bash@:$bash/bin/bash: $tmp
    sed -i -e s:@unwrapped_gcc@:$unwrapped_gcc: $tmp
    sed -i -e s:@glibc@:$glibc: $tmp
    chmod +x $tmp
    cp $tmp $out/bin
    cp $tmp $out/bin/nxfs-gcc

    # prepare gxx-wrapper script from template
    tmp=$builddir/bin/$gxx_basename
    cp $gxx_wrapper_script $tmp
    sed -i -e s:@bash@:$bash/bin/bash: $tmp
    sed -i -e s:@unwrapped_gxx@:$unwrapped_gxx: $tmp
    sed -i -e s:@glibc@:$glibc: $tmp
    chmod +x $tmp
    cp $tmp $out/bin
    cp $tmp $out/bin/nxfs-g++
  '';

  buildInputs = [ ];
}
