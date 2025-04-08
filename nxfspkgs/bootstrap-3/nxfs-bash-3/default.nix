{
  # nxfsenv   :: { mkDerivation :: attrs -> derivation,
  #                gcc-wrapper :: derivation  (also as gcc_wrapper)
  #                binutils    :: derivation
  #                gawk        :: derivation
  #                gnumake     :: derivation
  #                gnugrep     :: derivation
  #                gnutar      :: derivation
  #                gnused      :: derivation
  #                coreutils   :: derivation
  #                bash        :: derivation
  #                glibc       :: derivation
  #                nxfs-defs   :: { target_tuple :: string }
  #              }
  nxfsenv,
  # nxfsenv-3 :: {
  #                gnutar      :: derivation
  #                gnugrep     :: derivation
  #                gnused      :: derivation
  #                findutils   :: derivation
  #                diffutils   :: derivation
  #              }
  nxfsenv-3,
} :

let
  version = "5.2.32";

in

nxfsenv.mkDerivation {
  name         = "nxfs-bash-3";

  src          = builtins.fetchTarball { name = "bash-${version}-source";
                                         url = "https://ftp.gnu.org/gnu/bash/bash-${version}.tar.gz";
                                         sha256 = "1bhqakwia1zpnq9kgpn7kxsgvgh5b8nysanki0j2m7v7im4yjcvp"; };

  # for example: nixpkgs bintools-wrapper relies on this
  shellPath = "/bin/bash";

  buildPhase = ''
    set -e

    src2=$TMPDIR/src2
    builddir=$TMPDIR/build

    mkdir -p $src2
    mkdir -p $builddir

    (cd $src && (tar cf - . | tar xf - -C $src2))

    chmod -R +w $src2

    bash_program=$bash/bin/bash

    # patch tparam.c
    sed -i -e '1i #include <unistd.h>' $src2/lib/termcap/tparam.c

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$bash_program"

    (cd $builddir && $bash_program $src2/configure --prefix=$out --without-bash-malloc bash_cv_strtold_broken=no CFLAGS= LDFLAGS="-Wl,-enable-new-dtags")
    (cd $builddir && make SHELL=$CONFIG_SHELL)
    (cd $builddir && make install SHELL=$CONFIG_SHELL)

    # post-install
    (cd $out/bin && ln -sfv bash sh)
  '';

  buildInputs = [
    nxfsenv.gcc_wrapper
    nxfsenv.binutils
    nxfsenv.gnumake
    nxfsenv.gawk
    nxfsenv-3.gnutar
    nxfsenv-3.gnugrep
    nxfsenv-3.gnused
    nxfsenv-3.findutils
    nxfsenv-3.diffutils
    nxfsenv.coreutils
    nxfsenv.bash
    nxfsenv.glibc
  ];
}
