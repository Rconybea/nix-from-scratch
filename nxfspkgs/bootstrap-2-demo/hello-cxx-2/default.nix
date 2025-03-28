{
  # nxfsenv :: { mkDerivation :: attrs -> derivation,
  #              gcc-wrapper :: derivation,
  #              gcc         :: derivation,
  #              binutils    :: derivation,
  #              coreutils   :: derivation,
  #              bash        :: derivation,
  #              sysroot     :: derivation,
  #              nxfs-defs   :: { target_tuple :: string }
  #            }
  nxfsenv,
} :

let
  gcc_wrapper  = nxfsenv.gcc-wrapper;
  bash         = nxfsenv.bash;

in

# see nxfspkgs/build-support/autotools/{default.nix, default-builder.sh, setup.sh}
#
nxfsenv.mkDerivation {
  name = "hello-cxx-2";
  system = builtins.currentSystem;

  # to entirely replace the default build script,
  # uncomment 2 line below + provide local builder.sh
  #   builder = bash_program;
  #   args = [ ./builder.sh ];

  buildPhase = ''
    gxx=nxfs-g++
    mkdir -p $out/bin
    $gxx -o $out/bin/hello $src -lstdc++
  '';

  src = ./main.cpp;

  buildInputs = with nxfsenv; [ gcc_wrapper gcc binutils coreutils ];
}
