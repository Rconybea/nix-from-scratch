{
  # { bash,coreutils,findutils,grep,tar,sed} :: derivatioh
  bash ? import ../nxfs-bash-2,
  file ? import ../nxfs-file-2,
  coreutils ? import ../nxfs-coreutils-2,
  findutils ? import ../nxfs-findutils-2,
  grep ? import ../nxfs-grep-2,
  tar ? import ../nxfs-tar-2,
  sed ? import ../nxfs-sed-2,
  # nxfs-defs :: attrset
  nxfs-defs ? import ../nxfs-defs.nix
} :

let
  version = "14.2.0";
in

derivation {
  name = "nxfs-nixify-gcc-source";
  version = version;

  system = builtins.currentSystem;

  buildInputs = [ bash file coreutils findutils grep sed tar coreutils ];
  bash = bash;
  file = file;

  builder = "${bash}/bin/bash";
  args = [ ./builder.sh ];

  src = builtins.fetchTarball { name = "gcc-${version}-source";
                                url = "https://ftpmirror.gnu.org/gnu/gcc/gcc-${version}/gcc-${version}.tar.xz";
                                sha256 = "1bdp6l9732316ylpzxnamwpn08kpk91h7cmr3h1rgm3wnkfgxzh9";
                              };

  target_tuple = nxfs-defs.target_tuple;
}
