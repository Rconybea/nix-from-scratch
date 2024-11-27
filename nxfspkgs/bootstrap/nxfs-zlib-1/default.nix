derivation {
  name = "zlib";
  system = builtins.currentSystem;
  builder = ./builder.sh;
  buildInputs = [ ../nxfs-bash-0/default.nix ];
}
