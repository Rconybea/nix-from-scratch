{
  # { bash,coreutils,findutils,grep,tar,sed} :: derivatioh
  bash ? import ../nxfs-bash-2,
  python ? import ../nxfs-python-2,
  coreutils ? import ../nxfs-coreutils-2,
  findutils ? import ../nxfs-findutils-2,
  grep ? import ../nxfs-grep-2,
  tar ? import ../nxfs-tar-2,
  sed ? import ../nxfs-sed-2,
  locale-archive ? import ../../bootstrap-1/nxfs-locale-archive-1,
  # nxfs-defs :: attrset
  nxfs-defs ? import ../nxfs-defs.nix
} :

let
  version = "2.40";
in

derivation {
  name = "nxfs-nixify-glibc-source";
  version = version;

  system = builtins.currentSystem;

  buildInputs = [ bash python coreutils findutils grep sed tar coreutils ];
  bash = bash;
  python = python;
  coreutils = coreutils;
  locale_archive = locale-archive;

  builder = "${bash}/bin/bash";
  args = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "glibc-${version}-source";
                                         # TODO: use ftpmirror.gnu.org here
                                         url = "https://ftp.gnu.org/gnu/glibc/glibc-${version}.tar.xz";
                                         sha256 = "0ncvsz2r8py3z0v52fqniz5lq5jy30h0m0xx41ah19nl1rznflkh";
                                       };

  target_tuple = nxfs-defs.target_tuple;
}
