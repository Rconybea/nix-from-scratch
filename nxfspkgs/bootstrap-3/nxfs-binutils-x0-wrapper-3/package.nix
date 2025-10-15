{
  #  nxfsenv :: derivation
  nxfsenv,
} :

let
  binutils  = nxfsenv.binutils;
  gnused    = nxfsenv.gnused;
  coreutils = nxfsenv.coreutils;
  which     = nxfsenv.which;
  glibc     = nxfsenv.glibc;
in

nxfsenv.mkDerivation {
  name    = "binutils-xo-wrapper-3";
  version = binutils.version;
  system  = builtins.currentSystem;

  ld_wrapper_script = ./ld-wrapper.sh;

  inherit glibc;

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
