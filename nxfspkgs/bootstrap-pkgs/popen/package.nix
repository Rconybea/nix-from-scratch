{
  # stdenv :: attrset+derivation
  stdenv,
  # popen-template :: derivation
  popen-template,
  # stageid :: string  -- "2" for stage2, "3" for stage3
  stageid
} :

let
  version = popen-template.version;
in

stdenv.mkDerivation {
  name = "nxfs-popen-template-${stageid}";

  inherit version;

  src = popen-template;

  buildPhase = ''
    mkdir -p $out/src

    cp $src/src/nxfs_system.c $out/src/nxfs_system.c
    cp $src/src/nxfs_popen.c $out/src/nxfs_popen.c

    shell_path=$shell

    sed -i -e '/^#define SHELL_PATH/s:@bash_path@:'$shell_path':' $out/src/nxfs_system.c
    sed -i -e '/^#define SHELL_PATH/s:@bash_path@:'$shell_path':' $out/src/nxfs_popen.c
  '';
}
