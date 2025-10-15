{
  #  nxfsenv :: { mkDerivation, ... }
  nxfsenv,
} :

let
  glibc               = nxfsenv.glibc;
  gnused              = nxfsenv.gnused;
  coreutils           = nxfsenv.coreutils;
  bash                = nxfsenv.shell;
  nxfs-defs           = nxfsenv.nxfs-defs;
in

let
  target_tuple        = nxfs-defs.target_tuple;
in

nxfsenv.mkDerivation {
  name               = "gcc-x0-wrapper-3";
  version            = nxfsenv.gcc_wrapper.gcc.version;
  system             = builtins.currentSystem;

  inherit glibc bash;

  gnused             = gnused;
  coreutils          = coreutils;

  gcc_wrapper_script = ./gcc-wrapper.sh;
  gxx_wrapper_script = ./gxx-wrapper.sh;

  # unwrapped gcc,gxx
  gcc                = "${nxfsenv.gcc_wrapper.gcc}/bin/gcc";
  gxx                = "${nxfsenv.gcc_wrapper.gcc}/bin/g++";

  target_tuple       = target_tuple;

  buildPhase = ''
    # script to intercept calls to $gcc,
    # and inject additional arguments
    #

    builddir=$TMPDIR

    export PATH="$gnused/bin:$coreutils/bin:$bash/bin"

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
