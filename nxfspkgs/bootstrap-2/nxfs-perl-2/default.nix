let

  nxfs-coreutils-2   = import ../nxfs-coreutils-2/default.nix;
  nxfs-bash-2        = import ../nxfs-bash-2/default.nix;
  nxfs-tar-2         = import ../nxfs-tar-2/default.nix;
  nxfs-gnumake-2     = import ../nxfs-gnumake-2/default.nix;
  nxfs-gawk-2        = import ../nxfs-gawk-2/default.nix;
  nxfs-grep-2        = import ../nxfs-grep-2/default.nix;
  nxfs-sed-2         = import ../nxfs-sed-2/default.nix;
  nxfs-findutils-2   = import ../nxfs-findutils-2/default.nix;
  nxfs-diffutils-2   = import ../nxfs-diffutils-2/default.nix;
  nxfs-toolchain-wrapper-1 = import ../../bootstrap-1/nxfs-toolchain-wrapper-1/default.nix;

  nxfs-toolchain-1   = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-sysroot-1     = import ../../bootstrap-1/nxfs-sysroot-1/default.nix;

  nxfs-defs = import ../nxfs-defs.nix;
in

derivation {
  name         = "nxfs-perl-2";

  system       = builtins.currentSystem;

  toolchain    = nxfs-toolchain-1;
  sysroot      = nxfs-sysroot-1;

  coreutils    = nxfs-coreutils-2;
  gnumake      = nxfs-gnumake-2;
  gawk         = nxfs-gawk-2;
  bash         = nxfs-bash-2;
  tar          = nxfs-tar-2;
  grep         = nxfs-grep-2;
  sed          = nxfs-sed-2;
  findutils    = nxfs-findutils-2;
  diffutils    = nxfs-diffutils-2;
  gcc_wrapper  = nxfs-toolchain-wrapper-1;

  builder      = "${nxfs-bash-2}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "perl-5.40.0-source";
                                         sha256 = "1yiqddm0l774a87y13jmqm6w0j0dja7ycnigzkkbsy7gm5bkb8ig";
                                         url = "https://www.cpan.org/src/5.0/perl-5.40.0.tar.xz"; };

  target_tuple = nxfs-defs.target_tuple;
}
