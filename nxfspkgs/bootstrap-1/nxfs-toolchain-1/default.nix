let
  nxfs-toolchain-0       = import ../../bootstrap/nxfs-toolchain-0/default.nix;

  nxfs-gawk-0            = import ../../bootstrap/nxfs-gawk-0/default.nix;
  nxfs-sed-0             = import ../../bootstrap/nxfs-sed-0/default.nix;
  nxfs-coreutils-0       = import ../../bootstrap/nxfs-coreutils-0/default.nix;
  nxfs-tar-0             = import ../../bootstrap/nxfs-tar-0/default.nix;
  nxfs-bash-0            = import ../../bootstrap/nxfs-bash-0/default.nix;
  nxfs-patchelf-0        = import ../../bootstrap/nxfs-patchelf-0/default.nix;
  nxfs-redirect-elf-file = import ../nxfs-redirect-elf-file/default.nix;

  bash              = "${nxfs-bash-0}/bin/bash";
  builder           = "${nxfs-toolchain-0}/bin/ld.so";

  redirect_elf_file_0 = "${nxfs-redirect-elf-file}/bootstrap-scripts/redirect-elf-file-0.sh";
in

derivation {
  name               = "nxfs-toolchain-1";
  host_tuple         = "x86_64-pc-linux-gnu";
  version            = "14.2.0";
  system             = builtins.currentSystem;

  # want to support the following structure for stdenv:
  #   stdenv.cc
  #   stdenv.cc.cc        *this package*            (bundled with stdenv.cc.libc in stage1)
  #   stdenv.cc.bintools  *wrapped* bintools
  #   stdenv.cc.libc      *also this package* glibc (bundled with stdenv.cc.cc in stage1)
  #   stdenv.cc.libc.dev  libc headers              (bundled with stdenv.cc.cc in stage1 - defer for now)

  toolchain          = nxfs-toolchain-0;

  inherit bash;

  builder            = builder;
  args               = [
    "--library-path" "${nxfs-toolchain-0}/lib"
    bash
    ./builder.sh
  ];

  gawk               = nxfs-gawk-0;
  gnused             = nxfs-sed-0;
  gnutar             = nxfs-tar-0;
  coreutils          = nxfs-coreutils-0;
  patchelf           = nxfs-patchelf-0;

  redirect_elf_file_0  = redirect_elf_file_0;

#  dynamic_linker_relpath = "lib/ld-linux-x86-64.so.2";
  libc_relpath = "lib/libc.so.6";
  libc_nv_relpath = "lib/libc.so";
  libm_nv_relpath = "lib/libm.so";
  libm_static_relpath = "lib/libm.a";

  buildInputs        = [];
}
