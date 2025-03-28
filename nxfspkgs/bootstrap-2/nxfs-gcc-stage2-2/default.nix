let
  # {nxfs-binutils-2 .. nxfs-sysroot-1} :: derivation
  nxfs-binutils-2                = import ../nxfs-binutils-2;
  nxfs-mpc-2                     = import ../nxfs-mpc-2;
  nxfs-mpfr-2                    = import ../nxfs-mpfr-2;
  nxfs-gmp-2                     = import ../nxfs-gmp-2;
  nxfs-bison-2                   = import ../nxfs-bison-2;
  nxfs-flex-2                    = import ../nxfs-flex-2;
  nxfs-texinfo-2                 = import ../nxfs-texinfo-2;
  nxfs-m4-2                      = import ../nxfs-m4-2;
  nxfs-gnumake-2                 = import ../nxfs-gnumake-2;
  nxfs-file-2                    = import ../nxfs-file-2;
  nxfs-coreutils-2               = import ../nxfs-coreutils-2;
  nxfs-bash-2                    = import ../nxfs-bash-2;
  nxfs-tar-2                     = import ../nxfs-tar-2;
  nxfs-gawk-2                    = import ../nxfs-gawk-2;
  nxfs-grep-2                    = import ../nxfs-grep-2;
  nxfs-sed-2                     = import ../nxfs-sed-2;
  nxfs-findutils-2               = import ../nxfs-findutils-2;
  nxfs-diffutils-2               = import ../nxfs-diffutils-2;
  nxfs-gcc-stage3-wrapper-2      = import ../nxfs-gcc-stage3-wrapper-2;
  nxfs-binutils-stage1-wrapper-2 = import ../nxfs-binutils-stage1-wrapper-2;

  nxfs-glibc-stage1-2            = import ../nxfs-glibc-stage1-2;

  nxfs-toolchain-1               = import ../../bootstrap-1/nxfs-toolchain-1;
  nxfs-sysroot-1                 = import ../../bootstrap-1/nxfs-sysroot-1;

  # nxfs-defs :: attrset
  nxfs-defs                      = import ../nxfs-defs.nix;
in

let
  # nxfs-nixified-gcc-source :: derivation
  nxfs-nixified-gcc-source = import ../nxfs-nixify-gcc-source {
    bash      = nxfs-bash-2;
    file      = nxfs-file-2;
    findutils = nxfs-findutils-2;
    sed       = nxfs-sed-2;
    grep      = nxfs-grep-2;
    tar       = nxfs-tar-2;
    coreutils = nxfs-coreutils-2;
    nxfs-defs = nxfs-defs;
  };

  # version :: string
  version = nxfs-gcc-stage3-wrapper-2.version;

  # target_tuple :: string
  target_tuple = nxfs-defs.target_tuple;
in

derivation {
  name         = "nxfs-gcc-stage2-2";
  version      = version;

  system       = builtins.currentSystem;

  # note: will appear in path left-to-right
  buildInputs  = [ nxfs-bison-2
                   nxfs-flex-2
                   nxfs-texinfo-2
                   nxfs-m4-2
                   nxfs-diffutils-2
                   nxfs-findutils-2
                   nxfs-binutils-stage1-wrapper-2
                   nxfs-binutils-2
                   nxfs-gcc-stage3-wrapper-2
                   nxfs-toolchain-1
                   nxfs-gnumake-2
                   nxfs-gawk-2
                   nxfs-grep-2
                   nxfs-sed-2
                   nxfs-tar-2
                   nxfs-coreutils-2
                   nxfs-bash-2
                 ];

  glibc        = nxfs-glibc-stage1-2;

  sysroot      = nxfs-sysroot-1;

  mpc          = nxfs-mpc-2;   # mpc:  need this explicitly
  mpfr         = nxfs-mpfr-2;  # mpfr: need this explicitly
  gmp          = nxfs-gmp-2;   # gmp:  need this explicitly
  flex         = nxfs-flex-2;  # flex: need this explicitly
  #binutils     = nxfs-binutils-2;
  #binutils_stage1_wrapper_2 = nxfs-binutils-stage1-wrapper-2;
  bash         = nxfs-bash-2;  # bash: need this explicitly

  builder      = "${nxfs-bash-2}/bin/bash";
  args         = [ ./builder.sh ];

  src          = nxfs-nixified-gcc-source;

  target_tuple = target_tuple;
}
