{
  nxfsenv,
  # popen-template :: derivation
  popen-template
} :

nxfsenv.mkDerivation {
  name = "nxfs-popen-2";
  system = builtins.currentSystem;

  inherit (nxfsenv) coreutils;
  popen_template = popen-template;
  sed = nxfsenv.gnused;
  bash = nxfsenv.shell;

  builder = "${nxfsenv.shell}/bin/bash";
  args = [./builder.sh];
}
