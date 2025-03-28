{
  # everything in nxfsenv is from bootstrap-2/
  #  nxfsenv :: { mkDerivation, ... }
  nxfsenv,
  #  nxfsenv-3 :: { coreutils, ... }
  nxfsenv-3,
  # gcc-unwrapped :: bootstrap
  gcc-unwrapped,
  # libstdcxx :: bootstrap
  libstdcxx,
  # glibc :: bootstrap
  glibc,
} :

let
  gnused    = nxfsenv-3.gnused;
  coreutils = nxfsenv-3.coreutils;
  bash      = nxfsenv-3.bash;
  which     = nxfsenv-3.which;

  nxfs-defs = nxfsenv.nxfs-defs;
in

let
  version = nxfsenv.gcc-stage1.version;
in

nxfsenv.mkDerivation {
  name               = "gcc-stage3-wrapper-3";
  version            = version;
  system             = builtins.currentSystem;

  libstdcxx          = libstdcxx;
  glibc              = glibc;

  gcc_wrapper_script = ./gcc-wrapper.sh;
  gxx_wrapper_script = ./gxx-wrapper.sh;

  target_tuple       = nxfs-defs.target_tuple;

  buildPhase = ''
    # script to intercept calls to $gcc,
    # and inject additional arguments
    #

    echo "gcc_wrapper_script=$gcc_wrapper_script"
    echo "gxx_wrapper_script=$gxx_wrapper_script"

    builddir=$TMPDIR

    unwrapped_gcc=$(which gcc)
    unwrapped_gxx=$(which g++)

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
    tmp=$builddir/bin/gcc
    cp $gcc_wrapper_script $tmp
    sed -i -e s:@bash@:$bash/bin/bash: $tmp
    sed -i -e s:@unwrapped_gcc@:$unwrapped_gcc: $tmp
    sed -i -e s:@glibc@:$glibc: $tmp
    chmod +x $tmp
    cp $tmp $out/bin
    cp $tmp $out/bin/nxfs-gcc

    # prepare gxx-wrapper script from template
    tmp=$builddir/bin/g++
    cp $gxx_wrapper_script $tmp
    sed -i -e s:@bash@:$bash/bin/bash: $tmp
    sed -i -e s:@unwrapped_gxx@:$unwrapped_gxx: $tmp
    sed -i -e s:@glibc@:$glibc: $tmp
    sed -i -e s:@libstdcxx@:$libstdcxx: $tmp
    sed -i -e s:@target_tuple@:$target_tuple: $tmp
    sed -i -e s:@cxx_version@:$version: $tmp
    chmod +x $tmp

    cp $tmp $out/bin
    cp $tmp $out/bin/nxfs-g++
    '';

  buildInputs = [ gcc-unwrapped glibc bash gnused coreutils which ];
}
