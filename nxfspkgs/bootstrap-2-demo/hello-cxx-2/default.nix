{
  stdenv,
} :

# see nxfspkgs/build-support/autotools/{default.nix, default-builder.sh, setup.sh}
#
stdenv.mkDerivation {
  name = "hello-cxx-2";
  system = builtins.currentSystem;

  unpackPhase = ":";

  # to entirely replace the default build script,
  # uncomment 2 line below + provide local builder.sh
  #   builder = bash_program;
  #   args = [ ./builder.sh ];

  buildPhase = ''
    #gxx=nxfs-g++
    mkdir -p $out/bin

    # -B$libc :  glibc location missing from gcc build
    #
    g++ -v -o $out/bin/hello $src
    #g++ -o $out/bin/hello $src -lstdc++ -Wl,-rpath,${stdenv.cc}/lib -B${stdenv.cc.libc}/lib

  '';

  src = ./main.cpp;

  buildInputs = [];
}
