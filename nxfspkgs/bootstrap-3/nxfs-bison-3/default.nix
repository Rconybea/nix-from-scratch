let
  nxfs-flex-3        = import ../nxfs-flex-3/default.nix;
  nxfs-file-3        = import ../nxfs-file-3/default.nix;
  nxfs-perl-3        = import ../nxfs-perl-3/default.nix;
  nxfs-m4-3          = import ../nxfs-m4-3/default.nix;
  nxfs-binutils-3    = import ../nxfs-binutils-3/default.nix;
  nxfs-coreutils-3   = import ../nxfs-coreutils-3/default.nix;
  nxfs-bash-3        = import ../nxfs-bash-3/default.nix;
  nxfs-tar-3         = import ../nxfs-tar-3/default.nix;
  nxfs-gnumake-3     = import ../nxfs-gnumake-3/default.nix;
  nxfs-gawk-3        = import ../nxfs-gawk-3/default.nix;
  nxfs-grep-3        = import ../nxfs-grep-3/default.nix;
  nxfs-sed-3         = import ../nxfs-sed-3/default.nix;
  nxfs-findutils-3   = import ../nxfs-findutils-3/default.nix;
  nxfs-diffutils-3   = import ../nxfs-diffutils-3/default.nix;
  nxfs-gcc-wrapper-2 = import ../../bootstrap-2/nxfs-gcc-wrapper-2/default.nix;

  nxfs-defs = import ../nxfs-defs.nix;

  version = "3.8.2";
in

derivation {
  name         = "nxfs-bison-3";

  system       = builtins.currentSystem;

  flex         = nxfs-flex-3;
  file         = nxfs-file-3;
  perl         = nxfs-perl-3;
  m4           = nxfs-m4-3;
  binutils     = nxfs-binutils-3;
  coreutils    = nxfs-coreutils-3;
  bash         = nxfs-bash-3;
  tar          = nxfs-tar-3;
  gnumake      = nxfs-gnumake-3;
  gawk         = nxfs-gawk-3;
  grep         = nxfs-grep-3;
  sed          = nxfs-sed-3;
  findutils    = nxfs-findutils-3;
  diffutils    = nxfs-diffutils-3;
  gcc_wrapper  = nxfs-gcc-wrapper-2;

  builder      = "${nxfs-bash-3}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "bison-${version}-source";
                                         url = "https://ftp.gnu.org/gnu/bison/bison-${version}.tar.xz";
                                         sha256 = "0w18vf97c1kddc52ljb2x82rsn9k3mffz3acqybhcjfl2l6apn59"; };
  target_tuple = nxfs-defs.target_tuple;
}
