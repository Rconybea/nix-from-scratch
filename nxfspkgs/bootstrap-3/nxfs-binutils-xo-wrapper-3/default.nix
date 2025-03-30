{
  # everything in nxfsenv is from bootstrap-3/
  #  nxfsenv :: { mkDerivation, ... }
  nxfsenv,
  #  nxfsenv-3
  nxfsenv-3,
  # glibc :: derivation
  glibc
} :

let
  binutils  = nxfsenv-3.binutils;
  gnused    = nxfsenv-3.gnused;
  coreutils = nxfsenv-3.coreutils;
  which     = nxfsenv-3.which;
in

nxfsenv.mkDerivation {
  name    = "binutils-xo-wrapper-3";
  version = binutils.version;
  system  = builtins.currentSystem;

  ld_wrapper_script = ./ld-wrapper.sh;

  glibc = glibc;

  buildPhase = ''
    bash_program=$bash/bin/bash
    unwrapped_ld=$(which ld)
    builddir=$TMPDIR

    mkdir -p $builddir/bin
    mkdir -p $out/bin

    # prepare ld-wrapper script from template
    tmp=$builddir/bin/ld
    cp $ld_wrapper_script $tmp
    sed -i -e s:@bash@:$bash_program: $tmp
    sed -i -e s:@unwrapped_ld@:$unwrapped_ld: $tmp
    sed -i -e s:@glibc@:$glibc: $tmp
    chmod +x $tmp

    # install ld-wrapper script to output
    cp $tmp $out/bin

  '';

  buildInputs = [ binutils
                  gnused
                  coreutils
                  which
                ];
}
