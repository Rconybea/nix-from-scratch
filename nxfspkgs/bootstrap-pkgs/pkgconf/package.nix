{
  # stdenv :: attrset+derivation
  stdenv,
  # stageid :: string  -- "2" for stage2, "3" for stage3
  stageid,
} :

let
  version = "2.3.0";
in

stdenv.mkDerivation {
  name         = "nxfs-pkgconf-${stageid}";
  version      = version;

  src          = builtins.fetchTarball { name = "pkgconf-${version}-source";
                                         url = "https://distfiles.ariadne.space/pkgconf/pkgconf-${version}.tar.xz";
                                         sha256 = "1xrwjysmjkf4q9ygbzq5crhyckpqn18mi208m6l9hk731mf5vvk6"; };

  outputs = [ "out" "source" ];

  buildPhase = ''
    set -e

    builddir=$TMPDIR/build

    mkdir -p $builddir

    mkdir $source

    src2=$source

    shell_program=$shell

    # 1. copy source tree to temporary directory,
    #
    (cd $src && (tar cf - . | tar xf - -C $src2))

    # ----------------------------------------------------------------
    # NOTE: omitting coreutils unicode patch
    #       since we don't need it for bootstrap
    # ----------------------------------------------------------------

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$shell_program"

    (cd $builddir && export CC=nxfs-gcc && export CFLAGS= && export LDFLAGS="-Wl,-enable-new-dtags" && $shell_program $src2/configure --prefix=$out)

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)

    (cd $out/bin && ln -s pkgconf pkg-config)
'';

  buildInputs = [ ];
}
