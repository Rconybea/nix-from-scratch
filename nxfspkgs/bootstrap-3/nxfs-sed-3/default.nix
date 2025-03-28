{
  # nxfsenv   :: { mkDerivation :: attrs -> derivation,
  #                gcc-wrapper :: derivation,  (also as gcc_wrapper)
  #                binutils    :: derivation,
  #                gawk        :: derivation,
  #                gnumake     :: derivation,
  #                gnugrep     :: derivation,
  #                gnutar      :: derivation,
  #                gnused      :: derivation,
  #                coreutils   :: derivation,
  #                bash        :: derivation,
  #                glibc       :: derivation,
  #                nxfs-defs   :: { target_tuple :: string }
  #              }
  nxfsenv,
  # nxfsenv-3 :: {
  #                findutils   :: derivation,
  #                diffutils   :: derivation
  #              }
  nxfsenv-3,
} :

let
  version = "4.9";
in

nxfsenv.mkDerivation {
  name         = "nxfs-sed-3";
  version      = version;
  system       = builtins.currentSystem;

  src          = builtins.fetchTarball { name = "sed-${version}-source";
                                         url = "https://ftp.gnu.org/gnu/sed/sed-${version}.tar.xz";
                                         sha256 = "170m9hyxnhnxisvmii5z7m8i446ab97kam10rqjylj70dk8wh169"; };

  buildPhase = ''
    set -e

    builddir=$TMPDIR

    bash_program=$bash/bin/bash

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$bash_program"

    # 1.
    # we shouldn't need special compiler/linker instructions,
    # since stage-1 toolchain "knows where it lives"

    (cd $builddir && $bash_program $src/configure --prefix=$out CFLAGS= LDFLAGS="-Wl,-enable-new-dtags")
    (cd $builddir && make SHELL=$CONFIG_SHELL)
    (cd $builddir && make install SHELL=$CONFIG_SHELL)
  '';

  buildInputs = [
    nxfsenv-3.findutils
    nxfsenv-3.diffutils
    nxfsenv.gcc_wrapper
    nxfsenv.binutils
    nxfsenv.gawk
    nxfsenv.gnumake
    nxfsenv.gnugrep
    nxfsenv.gnutar
    nxfsenv.gnused
    nxfsenv.coreutils
    nxfsenv.bash
    nxfsenv.glibc
  ];
}
