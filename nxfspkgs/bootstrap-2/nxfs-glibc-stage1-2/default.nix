let
  nxfs-patchelf-2    = import ../nxfs-patchelf-2/default.nix;                   # yes
  nxfs-python-2      = import ../nxfs-python-2/default.nix;                     # yes
  nxfs-bison-2       = import ../nxfs-bison-2/default.nix;                      # yes
  nxfs-texinfo-2     = import ../nxfs-texinfo-2/default.nix;
  nxfs-m4-2          = import ../nxfs-m4-2/default.nix;
  nxfs-gzip-2        = import ../nxfs-gzip-2/default.nix;                       # yes
  nxfs-gperf-2       = import ../nxfs-gperf-2/default.nix;                      # yes
  nxfs-gcc-wrapper-2 = import ../nxfs-gcc-wrapper-2/default.nix;                # yes
  nxfs-sed-2         = import ../nxfs-sed-2/default.nix;                        # yes
  nxfs-grep-2        = import ../nxfs-grep-2/default.nix;                       # yes
  nxfs-gawk-2        = import ../nxfs-gawk-2/default.nix;                       # yes
  nxfs-gnumake-2     = import ../nxfs-gnumake-2/default.nix;                    # yes
  nxfs-tar-2         = import ../nxfs-tar-2/default.nix;                        # yes
  nxfs-patch-2       = import ../nxfs-patch-2/default.nix;                      # yes
  nxfs-bash-2        = import ../nxfs-bash-2/default.nix;                       # yes
  nxfs-diffutils-2   = import ../nxfs-diffutils-2/default.nix;
  nxfs-findutils-2   = import ../nxfs-findutils-2/default.nix;                  # yes
  nxfs-coreutils-2   = import ../nxfs-coreutils-2/default.nix;                  # yes
  nxfs-binutils-2    = import ../nxfs-binutils-2/default.nix;

  nxfs-lc-all-sort-2 = import ../nxfs-lc-all-sort-2/default.nix;

  nxfs-locale-archive-1 = import ../../bootstrap-1/nxfs-locale-archive-1/default.nix; # yes
  nxfs-toolchain-1   = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;   # yes
  nxfs-sysroot-1     = import ../../bootstrap-1/nxfs-sysroot-1/default.nix;     # yes

  nxfs-defs = import ../nxfs-defs.nix;
in

# PLAN
#   - building with nxfs-toolchain-1 (redirected crosstool-ng toolchain):
#     compiler expects to use binutils from the crosstool-ng toolchain
#   - in this derivation building glibc from source from within nix environment
#
derivation {
  name         = "nxfs-glibc-stage1-2";

  # reminder: for __noChroot to take effect, needs nix.conf to contain:
  #   sandbox = relaxed
  #
  #__noChroot = true;

  system       = builtins.currentSystem;

  locale_archive = nxfs-locale-archive-1;
  toolchain      = nxfs-toolchain-1;
  sysroot        = nxfs-sysroot-1;

  patchelf     = nxfs-patchelf-2;
  python       = nxfs-python-2;
  bison        = nxfs-bison-2;
  texinfo      = nxfs-texinfo-2;
  m4           = nxfs-m4-2;
  patch        = nxfs-patch-2;
  gperf        = nxfs-gperf-2;
  gzip         = nxfs-gzip-2;
  coreutils    = nxfs-coreutils-2;
  bash         = nxfs-bash-2;
  tar          = nxfs-tar-2;
  gnumake      = nxfs-gnumake-2;
  gawk         = nxfs-gawk-2;
  sed          = nxfs-sed-2;
  grep         = nxfs-grep-2;
  binutils     = nxfs-binutils-2;
  diffutils    = nxfs-diffutils-2;
  findutils    = nxfs-findutils-2;
  gcc_wrapper  = nxfs-gcc-wrapper-2;

  patchfile    = ./glibc-2.40-fhs-1.patch;

  lc_all_sort  = nxfs-lc-all-sort-2;

  builder      = "${nxfs-bash-2}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "glibc-2.40-source";
                                         url = "https://ftp.gnu.org/gnu/glibc/glibc-2.40.tar.xz";
                                         sha256 = "0ncvsz2r8py3z0v52fqniz5lq5jy30h0m0xx41ah19nl1rznflkh";
                                       };

  outputs      = [ "out" "source" ];

  target_tuple = nxfs-defs.target_tuple;
}
