{
  # everything in nxfsenv is from bootstrap-3/
  #  mkDerivation :: attrset -> derivation
  mkDerivation,
  #  xz           :: derivation
  xz,
  #  bzip2        :: derivation
  bzip2,
  #  patch        :: derivation
  patch,
  #  file         :: derivation
  file,
  #  gnumake      :: derivation
  gnumake,
  #  gzip         :: derivation
  gzip,
  #  gnutar       :: derivation
  gnutar,
  #  gawk         :: derivation
  gawk,
  #  gnugrep      :: derivation
  gnugrep,
  #  gnused       :: derivation
  gnused,
  #  coreutils    :: derivation
  coreutils,
  #  findutils    :: derivation
  findutils,
  #  diffutils    :: derivation
  diffutils,
  #  bash         :: derivation
  bash,
  #  which        :: derivation
  which,
  # gcc           :: derivation
  gcc,
  # glibc         :: derivation
  glibc,
  # patchelf      :: derivation
  patchelf
} :

# mkDerivation (from autotools/default.nix) provides various interesting default.
# All we care about here is the build *result*
#
mkDerivation {
  # nxfs-stdenv: intended to be a functional substitute for nixpkgs stdenv-linux

  name               = "stdenv-nxfs";
  system             = builtins.currentSystem;

  # copied into build output;  *not* invoked here
  setup_program      = ./setup.sh;

#  builder            = "${bash}/bin/bash";
#  bash               = bash;
#  setupScript        = ./setup.sh;

  glibc              = glibc;

  buildPhase = ''
    mkdir -p $out
    mkdir -p $out/nix-support

    bash_program=$(which bash)

    cat > $out/setup <<EOF
export SHELL=$bash_program
initialPath="$initialPath"
defaultNativeBuildInputs="$defaultNativeBuildInputs"
defaultBuildInputs="$defaultBuildInputs"
EOF
    cat $setup_program >> $out/setup
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
  #    # /nix/store/k97fic16vmpf9z6vjx5dgd6rxcvv5wwh-patchelf-0.15.0
  #    /nix/store/9l3havpzc3w1xggd19l5c395az4yh449-update-autotools-gnu-config-scripts-hook
  #    /nix/store/h9lc1dpi14z7is86ffhl3ld569138595-audit-tmpdir.sh
  #    /nix/store/m54bmrhj6fqz8nds5zcj97w9s9bckc9v-compress-man-pages.sh
  #    /nix/store/wgrbkkaldkrlrni33ccvm3b6vbxzb656-make-symlinks-relative.sh
  #    /nix/store/5yzw0vhkyszf2d179m0qfkgxmp5wjjx4-move-docs.sh
  #    /nix/store/fyaryjvghbkpfnsyw97hb3lyb37s1pd6-move-lib64.sh
  #    /nix/store/kd4xwxjpjxi71jkm6ka0np72if9rm3y0-move-sbin.sh
  #    /nix/store/pag6l61paj1dc9sv15l7bm5c17xn5kyk-move-systemd-user-units.sh
  #    /nix/store/jivxp510zxakaaic7qkrb7v1dd2rdbw9-multiple-outputs.sh
  #    /nix/store/12lvf0c7xric9cny7slvf9cmhypl1p67-patch-shebangs.sh
  #    /nix/store/cickvswrvann041nqxb0rxilc46svw1n-prune-libtool-files.sh
  #    /nix/store/xyff06pkhki3qy1ls77w10s0v79c9il0-reproducible-builds.sh
  #    /nix/store/aazf105snicrlvyzzbdj85sx4179rpfp-set-source-date-epoch-to-latest.sh
  #    /nix/store/gps9qrh99j7g02840wv5x78ykmz30byp-strip.sh
  #    # /nix/store/zznja5f8v3jafffyah1rk46vpfcn38dv-gcc-wrapper-13.3.0
  #
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
  buildInputs = [ coreutils bash which ];

  initialPath = [ bzip2 xz patch file gnumake gzip gnutar
                  gawk gnugrep gnused coreutils
                  findutils diffutils bash which ];
  defaultNativeBuildInputs = [ patchelf gcc ];
  defaultBuildInputs = [ ];
}
