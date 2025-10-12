{
  #  nxfsenv :: { mkDerivation, ... }
  nxfsenv,
  #  nxfsenv-3 :: { coreutils, ... }
  nxfsenv-3,
} :

let
  gcc-unwrapped       = nxfsenv-3.gcc-unwrapped;
  glibc               = nxfsenv-3.glibc;

  gnused              = nxfsenv-3.gnused;
  coreutils           = nxfsenv-3.coreutils;
  bash                = nxfsenv-3.bash;
  which               = nxfsenv-3.which;
  nxfs-defs           = nxfsenv-3.nxfs-defs;
in

nxfsenv.mkDerivation {
  name               = "gcc-wrapper-3";
  version            = gcc-unwrapped.version;
  system             = builtins.currentSystem;

  gcc_wrapper_script = ./gcc-wrapper.sh;
  gxx_wrapper_script = ./gxx-wrapper.sh;

  gcc                = gcc-unwrapped;
  glibc              = glibc;

  target_tuple       = nxfs-defs.target_tuple;

  # This will be visible to nixpkgs via
  #   nxfspkgs.stdenv2nix-minimal,
  # as
  #   stdenv.cc.targetPrefix
  #
  targetPrefix = "";

  buildPhase = ''
    # script to intercept calls to $gcc,
    # and inject additional arguments

    set -e

    builddir=$TMPDIR
    unwrapped_gcc=$(which gcc)
    unwrapped_gxx=$(which g++)

    mkdir -p $builddir/bin
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
    sed -i -e s:@gcc@:$gcc: $tmp
    sed -i -e s:@glibc@:$glibc: $tmp
    chmod +x $tmp
    cp $tmp $out/bin/
    cp $tmp $out/bin/nxfs-gcc

    # prepare gxx-wrapper script from template
    tmp=$builddir/bin/g++
    cp $gxx_wrapper_script $tmp
    sed -i -e s:@bash@:$bash/bin/bash: $tmp
    sed -i -e s:@unwrapped_gxx@:$unwrapped_gxx: $tmp
    sed -i -e s:@gcc@:$gcc: $tmp
    sed -i -e s:@glibc@:$glibc: $tmp
    sed -i -e s:@target_tuple@:$target_tuple: $tmp
    sed -i -e s:@cxx_version@:$version: $tmp
    chmod +x $tmp
    cp $tmp $out/bin/
    cp $tmp $out/bin/nxfs-g++
    '';

  buildInputs = [ gcc-unwrapped glibc gnused coreutils bash which ];
}
