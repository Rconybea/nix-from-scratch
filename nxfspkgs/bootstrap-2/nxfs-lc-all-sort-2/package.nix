{
  nxfsenv
} :

nxfsenv.mkDerivation {
  name   = "lc-all-sort-2";
  system = builtins.currentSystem;

  # Shim for glibc build.
  # Provides script 'bin/lc-all-sort';
  # lc-all-sort invokes 'sort' (from coreutils) in environment with LC_ALL=C.
  #
  # Out-of-the-box glibc build invokes 'LC_ALL=C sort' in context that assumes
  # sort resolves to /bin/sort.
  # In nix build /bin isn't available, so we need a workaround.

  coreutils = nxfsenv.coreutils;
  bash      = nxfsenv.shell;
  sed       = nxfsenv.gnused;
  gnused    = nxfsenv.gnused;
  toolchain = nxfsenv.toolchain.toolchain;

  builder   = "${nxfsenv.shell}/bin/bash";
  args      = [ ./builder.sh ];

  lc_all_sort_script = ./lc-all-sort.sh;
}
