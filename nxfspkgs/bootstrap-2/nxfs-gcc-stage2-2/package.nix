{
  # nxfsenv :: attrset
  nxfsenv,
  # nixified-gcc-source :: derivation
  nixified-gcc-source,
  # mpc :: derivation
  mpc,
  # mpfr :: derivation
  mpfr,
  # gmp :: derivation
  gmp,
  # binutils-wrapper :: derivation
  binutils-wrapper
} :

let
  # version :: string
  version = nxfsenv.gcc.version; #nxfs-gcc-stage3-wrapper-2.version;

  # toolchain :: derivation
  toolchain = nxfsenv.toolchain.toolchain;

  # target_tuple :: string
  target_tuple = nxfsenv.nxfs-defs.target_tuple;
in

nxfsenv.mkDerivation {
  name         = "nxfs-gcc-stage2-2";
  version      = version;

  system       = builtins.currentSystem;

  inherit mpc mpfr gmp toolchain;

  # note: will appear in path left-to-right
  buildInputs  = [ nxfsenv.bison
                   nxfsenv.flex
                   nxfsenv.texinfo
                   nxfsenv.m4
                   nxfsenv.diffutils
                   nxfsenv.findutils
                   binutils-wrapper
                   nxfsenv.binutils
                   nxfsenv.gcc
                   toolchain
                   nxfsenv.gnumake
                   nxfsenv.gawk
                   nxfsenv.gnugrep
                   nxfsenv.gnused
                   nxfsenv.gnutar
                   nxfsenv.coreutils
                   nxfsenv.shell
                 ];

  glibc        = nxfsenv.glibc;
  flex         = nxfsenv.flex;
  bash         = nxfsenv.shell;

  builder      = "${nxfsenv.shell}/bin/bash";
  args         = [ ./builder.sh ];

  src          = nixified-gcc-source;

  target_tuple = target_tuple;
}
