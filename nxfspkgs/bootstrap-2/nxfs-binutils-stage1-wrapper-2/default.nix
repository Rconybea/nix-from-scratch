let
  # {nxfs-coreutils-2 .. nxfs-sed-2} :: derivation
  nxfs-coreutils-2 = import ../nxfs-coreutils-2;
  nxfs-binutils-2 = import ../nxfs-binutils-2;
  nxfs-bash-2 = import ../nxfs-bash-2;
  nxfs-sed-2 = import ../nxfs-sed-2;
  nxfs-glibc-stage1-2 = import ../nxfs-glibc-stage1-2;
in

derivation {
  name = "binutils-stage1-wrapper";
  system = builtins.currentSystem;

  buildInputs = [ nxfs-coreutils-2 nxfs-binutils-2 nxfs-bash-2 nxfs-sed-2 ];

  binutils = nxfs-binutils-2;
  glibc = nxfs-glibc-stage1-2;
  bash = nxfs-bash-2;

  builder = "${nxfs-bash-2}/bin/bash";
  args = [ ./builder.sh ];

  ld_wrapper_script = ./ld-wrapper.sh;
}
