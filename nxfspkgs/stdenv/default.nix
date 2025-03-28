{
  # everything in nxfsenv is from bootstrap-3/
  #  mkDerivation :: attrset -> derivation
  mkDerivation,
  #  coreutils :: derivation
  coreutils,
  #  bash :: derivation
  bash,
  #  which :: derivation
  which,
  # gcc :: derivation
  gcc,
  # glibc :: derivation
  glibc
} :

mkDerivation {
  # nxfs-stdenv: intended to be a functional substitute for nixpkgs stdenv-linux

  name               = "nxfs-stdenv";
  system             = builtins.currentSystem;

  glibc              = glibc;

#  target_tuple       = nxfs-defs.target_tuple;

  buildPhase = ''
    mkdir -p $out
    mkdir -p $out/nix-support

    bash_program=$(which bash)

    cat > $out/setup <<EOF
export SHELL=$bash_program
initialPath="$coreutils"
defaultNativeBuildInputs="$gcc"
EOF
    '';

  # based on nixpkgs stdenv, we need for:
  #  initialPath
  #   coreutils
  #   findutils
  #   diffutils
  #   gnused
  #   gnugrep
  #   gawk
  #   gnutar
  #   gzip
  #   bzip2
  #   gnumake
  #   bash
  #   patch
  #   xz
  #   file
  #
  #  defaultNativeBuildInputs
  #   patchelf
  #   update-autotools-gnu-config-scripts-hook
  #   audit-tmpdir.sh
  #   compress-man-pages.sh
  #   make-symlinks-relaitve.sh
  #   move-docs.sh
  #   move-lib64.sh
  #   move-sbin.sh
  #   move-systemd-user-units.sh
  #   multiple-outputs.sh
  #   patch-shebangs.sh
  #   prune-libtool-files.sh
  #   reproducible-builds.sh
  #   set-source-date-epoch-to-latest.sh
  #   strip.sh
  #   gcc-wrapper-13.3.0
  #
  # Reminder: nativeBuildInputs are build-time only
  #
  buildInputs = [ bash which ];
}
