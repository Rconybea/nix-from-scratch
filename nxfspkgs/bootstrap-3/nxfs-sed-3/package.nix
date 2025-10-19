{
  # stdenv :: attrset+derivation
  stdenv,
} :

let
  version = "4.9";
in

stdenv.mkDerivation {
  name         = "nxfs-gnused-3";
  version      = version;
  system       = builtins.currentSystem;

  src          = builtins.fetchTarball { name = "sed-${version}-source";
                                         url = "https://ftp.gnumirror.org/gnu/sed/sed-${version}.tar.xz";
                                         sha256 = "170m9hyxnhnxisvmii5z7m8i446ab97kam10rqjylj70dk8wh169"; };

  buildPhase = ''
    set -e

    builddir=$TMPDIR

    shell_program=$shell

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$shell_program"

    # 1.
    # we shouldn't need special compiler/linker instructions,
    # since stage-1 toolchain "knows where it lives"

    (cd $builddir && $shell_program $src/configure --prefix=$out CFLAGS= LDFLAGS="-Wl,-enable-new-dtags")
    (cd $builddir && make SHELL=$CONFIG_SHELL)
    (cd $builddir && make install SHELL=$CONFIG_SHELL)
  '';

  buildInputs = [
#    nxfsenv.findutils
#    nxfsenv.diffutils
#    nxfsenv.gcc_wrapper
#    nxfsenv.binutils
#    nxfsenv.gawk
#    nxfsenv.gnumake
#    nxfsenv.gnugrep
#    nxfsenv.gnutar
#    nxfsenv.gnused
#    nxfsenv.coreutils
#    nxfsenv.shell
#    nxfsenv.glibc
  ];
}
