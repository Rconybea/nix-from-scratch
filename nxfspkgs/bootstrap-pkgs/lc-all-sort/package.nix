{
  # stdenv :: attrset+derivation
  stdenv,
  # coreutils :: attrset
  coreutils
} :

# Shim for glibc build.
# Provides script 'bin/lc-all-sort';
# lc-all-sort invokes 'sort' (from coreutils) in environment with LC_ALL=C.
#
# Out-of-the-box glibc build invokes 'LC_ALL=C sort' in context that assumes
# sort resolves to /bin/sort.
# In nix build /bin isn't available, so we need a workaround.

stdenv.mkDerivation {
  name   = "lc-all-sort";
  system = builtins.currentSystem;

  src = ./src;

  coreutils = coreutils;

  buildPhase = ''
    mkdir -p $TMPDIR/bin
    mkdir -p $out/bin

    target=$TMPDIR/bin/lc-all-sort-wrapper
    cp $src/lc-all-sort.sh $target
    sed -i -e s:@shell@:$shell: \
           -e s:@coreutils@:$coreutils: \
           -e s:@sort_program@:$coreutils/bin/sort: \
           $target
    chmod +x $target
    cp $target $out/bin/
  '';
}
