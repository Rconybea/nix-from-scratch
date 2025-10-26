{
  # stdenv :: attrset+derivation
  stdenv,
  # gcc :: derivation
  gcc,
  # prev-gcc :: derivation
  prev-gcc,
  # perl :: derivation
  perl,
  # stageid :: string -- "2" for stage2, etc.
  stageid,
} :

stdenv.mkDerivation {
  name = "nxfs-gcc-x5-${stageid}";
  version = gcc.version;
  system = builtins.currentSystem;

  buildPhase = ''
    rm -f $out/build.env

    (cd ${gcc} && (tar cf - . | tar xf - -C $TMPDIR))
    chmod -R +w $TMPDIR

    new=$(basename $out)
    old1=$(basename ${gcc})
    old2=$(basename ${prev-gcc})

    echo "redirect [$old1],[$old2] to [$new] throughout [$(basename ${gcc})]"

    find $TMPDIR -type f | while read -r file; do
       if grep -l -a -F "$old1" $file 2>/dev/null; then
         echo "replace [$old1] in [$file]"
         perl -pi -e "s|\Q$old1\E|$new|g" "$file"
       fi

       if grep -l -a -F "$old2" $file 2>/dev/null; then
         echo "replace [$old2] in [$file]"
         perl -pi -e "s|\Q$old2\E|$new|g" "$file"
       fi
    done

    (cd $TMPDIR && (tar cf - . | tar xf - -C $out))
  '';

  buildInputs = [ perl ];
}
