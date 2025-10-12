let
  nxfs-coreutils-0 = import ../../bootstrap/nxfs-coreutils-0/default.nix;
  nxfs-toolchain-0 = import ../../bootstrap/nxfs-toolchain-0/default.nix;
  nxfs-bash-0 = import ../../bootstrap/nxfs-bash-0/default.nix;

  bash = "${nxfs-bash-0}/bin/bash";
in

derivation {
  name = "run-toolchain-0";
  system = "x86_64-linux";
  builder = "${nxfs-toolchain-0}/bin/ld.so";
  args = [
    "--library-path" "${nxfs-toolchain-0}/lib"
    bash
    ./builder.sh
  ];

  toolchain = nxfs-toolchain-0;
  coreutils = nxfs-coreutils-0;

  inherit bash;
}
