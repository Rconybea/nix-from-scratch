let
    nxfs-sysroot-0 = import ../../bootstrap/nxfs-sysroot-0/default.nix;
    nxfs-coreutils-0 = import ../../bootstrap/nxfs-coreutils-0/default.nix;
    nxfs-patchelf-0 = import ../../bootstrap/nxfs-patchelf-0/default.nix;
    nxfs-tar-0 = import ../../bootstrap/nxfs-tar-0/default.nix;
    nxfs-bash-0 = import ../../bootstrap/nxfs-bash-0/default.nix;

    bash = "${nxfs-bash-0}/bin/bash";
    builder = "${nxfs-sysroot-0}/lib/ld-linux-x86-64.so.2";
in

derivation {
  name = "nxfs-sysroot-1";
  system = builtins.currentSystem;

  # fails on roly-desktop-23
  # Not sure exactly why.
  # Bash derivation has patched interpreter
  # (patchelf --print-interpreter ${bash}/bin/bash -> nix store path)
  # but strace -f on nix-build reports ENOENT from attempt to invoke.
  # The fact that we *can* invoke bash by directly invoking the ld-linux
  # compels us to belive problem *must* be path-to-interpreter-related
  # (also same process succesfully uses openat() to get file descriptor for
  #  the same path)
  # suspect the problem is the old location of ld-linux not being accessible
  # during build?
  #
  #  builder = "${bash}/bin/bash";
  #  args = ["--version"];

  bash = bash;
  builder = builder;

  patchelf = nxfs-patchelf-0;
  coreutils = nxfs-coreutils-0;
  tar = nxfs-tar-0;
  nxfs_sysroot_0 = nxfs-sysroot-0;

  bash_builder = "./builder.sh";

  # works on roly-desktop-23 (doesn't satisfy nix, but hello runs to completion)
  #builder = "${sysroot}/lib/ld-linux-x86-64.so.2";
  #args = ["${bash}/bin/bash" "--version"];

  # works on roly-desktop-23.
  # Creates $out/greetings.txt
  #

  args = [bash ./builder.sh];

  # fails on roly-desktop-23.  Looks like patchelf'ing interpreter
  # isn't sufficient
  #builder = "${hello}";

  buildInputs = [];
}
