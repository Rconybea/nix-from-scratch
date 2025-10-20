{
  # stdenv :: attrset+derivation
  stdenv,
  # stageid :: string
  stageid,
} :

let
  version = "5.2.32";

in

stdenv.mkDerivation {
  name         = "nxfs-bash-${stageid}";

  src          = builtins.fetchTarball { name = "bash-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/bash/bash-${version}.tar.gz";
                                         sha256 = "1bhqakwia1zpnq9kgpn7kxsgvgh5b8nysanki0j2m7v7im4yjcvp"; };

  # for example: nixpkgs bintools-wrapper relies on this (?)
  shellPath = "/bin/bash";

  buildPhase = ''
    set -e

    src2=$TMPDIR/src2
    builddir=$TMPDIR/build

    mkdir -p $src2
    mkdir -p $builddir

    (cd $src && (tar cf - . | tar xf - -C $src2))

    chmod -R +w $src2

    shell_program=$shell

    # patch tparam.c
    sed -i -e '1i #include <unistd.h>' $src2/lib/termcap/tparam.c

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$shell_program"

    (cd $builddir && $shell_program $src2/configure --prefix=$out --without-bash-malloc bash_cv_strtold_broken=no CFLAGS= LDFLAGS="-Wl,-enable-new-dtags")
    (cd $builddir && make SHELL=$CONFIG_SHELL)
    (cd $builddir && make install SHELL=$CONFIG_SHELL)

    # post-install
    (cd $out/bin && ln -sfv bash sh)
  '';

  buildInputs = [
  ];
}
