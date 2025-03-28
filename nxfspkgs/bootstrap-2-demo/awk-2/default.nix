{
  # nxfsenv :: { mkDerivation :: attrs -> derivation,
  #              gcc-wrapper :: derivation,
  #              gcc         :: derivation,
  #              binutils    :: derivation,
  #              coreutils   :: derivation,
  #              bash        :: derivation,
  #              sysroot     :: derivation,
  #              nxfs-defs   :: { target_tuple :: string }
  #            }
  nxfsenv,
} :

nxfsenv.mkDerivation {
  name      = "demo-awk-2";

  buildPhase = ''
    # PATH=$toolchain/x86_64-pc-linux-gnu/debug-root/usr/bin:$PATH

    gawk_program=$gawk/bin/gawk
    sort_program=$coreutils/bin/sort

    mkdir -p $out

    cp $script $out/script.awk
    sed -i -e 's:/usr/bin/gawk:'$gawk_program':' $out/script.awk
    sed -i -e 's:@sort_program@:'$sort_program':' $out/script.awk

    echo "script.awk:"
    cat $out/script.awk

    $out/script.awk $input > $out/output1.txt
  '';

  gawk      = nxfsenv.gawk;
  coreutils = nxfsenv.coreutils;

  script    = ./script.awk;
  input     = ./input.txt;

  buildInputs = with nxfsenv; [ nxfsenv.gawk
                                nxfsenv.gnused
                                nxfsenv.coreutils ];
}
