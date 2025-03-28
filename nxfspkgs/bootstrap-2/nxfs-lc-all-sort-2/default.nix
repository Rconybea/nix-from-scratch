let
  nxfs-sed-1 = import ../../bootstrap-1/nxfs-sed-1/default.nix;
  nxfs-toolchain-1 = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-sysroot-1 = import ../../bootstrap-1/nxfs-sysroot-1/default.nix;
  nxfs-coreutils-1 = import ../../bootstrap-1/nxfs-coreutils-1/default.nix;
  nxfs-bash-1 = import ../../bootstrap-1/nxfs-bash-1/default.nix;
in

derivation {
  name = "gcc-wrapper";
  system = builtins.currentSystem;

  # Shim for glibc build.
  # Provides script 'bin/lc-all-sort';
  # lc-all-sort invokes 'sort' (from coreutils) in environment with LC_ALL=C.
  #
  # Out-of-the-box glibc build invokes 'LC_ALL=C sort' in context that assumes
  # sort resolves to /bin/sort.
  # In nix build /bin isn't available, so we need a workaround.

  bash = nxfs-bash-1;
  sed = nxfs-sed-1;
  toolchain = nxfs-toolchain-1;
  sysroot = nxfs-sysroot-1;
  coreutils = nxfs-coreutils-1;
  gnused = nxfs-sed-1;

  builder = "${nxfs-bash-1}/bin/bash";
  args = [ ./builder.sh ];

  lc_all_sort_script = ./lc-all-sort.sh;

  #target_tuple="x86_64-pc-linux-gnu";
}
