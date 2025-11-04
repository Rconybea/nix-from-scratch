{
  # stdenv :: attrset+derivation
  stdenv,
  # unwrapped C compiler
  #
  # cc :: derivation
  #
  cc,
  # libc :: derivation
  libc,
  # nxfs-defs :: derivation
  nxfs-defs,
  # stageid :: derivation  -- e.g. x3-2
  stageid,
} :

stdenv.mkDerivation {
  name               = "gcc-wrapper-${stageid}";
  version            = cc.version;
  system             = builtins.currentSystem;

  src = ./src;

  inherit cc libc;

  target_tuple       = nxfs-defs.target_tuple;

  buildPhase = ''
    # script to intercept calls to $cc,
    # and inject additional arguments
    #

    builddir=$TMPDIR

    gcc_version="${cc.version}";

    unwrapped_cpp=$cc/bin/cpp
    unwrapped_gcc=$cc/bin/gcc
    unwrapped_gxx=$cc/bin/g++

    mkdir -p $builddir/bin

    cpp_basename=cpp
    gcc_basename=gcc
    gxx_basename=g++

    mkdir -p $out/bin
    mkdir -p $out/nix-support

    prepare_wrapper() {
        # e.g. nxfs-gcc
        name=nxfs-$1
        template=$2

        tmp=$builddir/bin/$name
        cp $template $tmp

        sed -i -e s:@bash@:$shell: \
               -e s:@unwrapped_cpp@:$cpp_basename: \
               -e s:@unwrapped_gcc@:$gcc_basename: \
               -e s:@unwrapped_gxx@:$gxx_basename: \
               -e s:@gcc@:$cc: \
               -e s:@glibc@:$libc: \
               -e s:@target_tuple@:$target_tuple: \
               -e s:@gcc_version@:$gcc_version: \
               $tmp
        chmod +x $tmp
        cp $tmp $out/bin

        # e.g. symlink gcc -> nxfs-gcc
        (cd $out/bin && ln -s $name $1)
    }

    prepare_wrapper cpp $src/cpp-wrapper.sh
    prepare_wrapper gcc $src/gcc-wrapper.sh
    prepare_wrapper g++ $src/g++-wrapper.sh

    cp ${./setup-hook.sh} $out/nix-support/setup-hook
    '';

  buildInputs = [ cc libc ];
}
