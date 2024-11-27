let
  pkgs = import <nixpkgs> {};
in

derivation {
  name = "hello";
  builder = "${pkgs.bash}/bin/bash";
  args = [ ./hello-builder.sh ];
  gcc = pkgs.gcc;
  coreutils = pkgs.coreutils;
  src = ./hello.c;
  system = builtins.currentSystem;
}
