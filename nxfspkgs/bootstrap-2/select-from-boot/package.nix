{
  # stdenv :: attrset + derivation
  stdenv,
  # boot :: derivation     -- nxfs bootstrap tools.  boot/{bash, coreutils, gcc, glibc}
  boot,
  # boot_subdir :: string  -- toplevel subdirectory of boot output.
  boot-subdir,
  # stageid :: string
  stageid,
} :

stdenv.mkDerivation {
  name = "${boot-subdir}-boot-${stageid}";

  # just want to symlink to ${boot}/${boot-subdir}/{bin, lib, ..}
  buildPhase = ''

    # symlink to version from ${boot} instead (? may want to revisit)
    rmdir $out/nix-support

    for i in ${boot}/${boot-subdir}/*; do
      (cd $out && ln -sf $i)
    done
  '';

  nativeBuildInputs = [ boot ];
}
