{
  # stdenv :: derivation+attrset
  stdenv,
  # unwrapped C compiler
  #
  # require:
  # - cc.version
  # - cc/bin/{cpp, gcc, g++}
  #
  # cc :: derivation
  #
  cc,
  # glibc :: derivation  -- the libc we're imposing with this wrapper
  libc,
  # nxfs-defs :: derivation
  nxfs-defs,
  # stageid :: string  -- "2" for stage2, etc.
  stageid,
} :

stdenv.mkDerivation {
  # nxfsenv.gcc_wrapper     will be stage2pkgs.gcc-wrapper-2 (see nxfs-gcc-wrapper-2)
  #   wrapper needed to point to location of stage2 glibc and libstdc++
  # nxfsenv.gcc_wrapper.gcc will be stage2pkgs.gcc-x3-2      (see nxfs-gcc-stage2-2)
  #
  # Strategy here is to replicate the behavior of gcc-wrapper-2,
  # except we point to stage3 glibc instead of stage2 glibc

  name               = "gcc-x0-wrapper-${stageid}";
  version            = cc.version;
  system             = builtins.currentSystem;

  inherit cc libc;

  src = ./src;

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
  '';

  buildInputs = [ ];
}
