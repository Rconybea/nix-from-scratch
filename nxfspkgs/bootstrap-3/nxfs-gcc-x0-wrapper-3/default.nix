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
  nxfs-glibc-stage1-2 = nxfsenv.glibc-stage1;
  gnused              = nxfsenv-3.gnused;
  nxfs-toolchain-1    = bootstrap-1.nxfs-toolchain-1;
  nxfs-coreutils-1    = bootstrap-1.nxfs-coreutils-1;
  bash                = nxfsenv-3.bash;
  nxfs-defs           = nxfsenv-3.nxfs-defs;
in

let
  target_tuple        = nxfs-defs.target_tuple;
in

nxfsenv.mkDerivation {
  name               = "gcc-x0-wrapper-3";
  version            = nxfsenv.gcc_wrapper.gcc.version;
  system             = builtins.currentSystem;

  glibc              = glibc;

  bash               = bash;
  gnused             = gnused;
  toolchain          = bootstrap-1.nxfs-toolchain-1;
  coreutils          = bootstrap-1.nxfs-coreutils-1;

  gcc_wrapper_script = ./gcc-wrapper.sh;
  gxx_wrapper_script = ./gxx-wrapper.sh;

  # works with toolchain gcc,
  # but we want to use stage2 wrapper
  #   gcc = "${bootstrap-1.nxfs-toolchain-1}/bin/${target_tuple}-gcc";
  #   gxx = "${bootstrap-1.nxfs-toolchain-1}/bin/${target_tuple}-g++";

  # unwrapped gcc,gxx
  gcc                = "${nxfsenv.gcc_wrapper.gcc}/bin/gcc";
  gxx                = "${nxfsenv.gcc_wrapper.gcc}/bin/g++";

  target_tuple       = target_tuple;

  buildPhase = ''
    # script to intercept calls to $gcc,
    # and inject additional arguments
    #

    builddir=$TMPDIR

    export PATH="$toolchain/bin:$gnused/bin:$coreutils/bin:$bash/bin"

    unwrapped_gcc=$gcc
    unwrapped_gxx=$gxx

    mkdir -p $builddir/bin

    gcc_basename=$(basename $gcc)
    gxx_basename=$(basename $gxx)

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
