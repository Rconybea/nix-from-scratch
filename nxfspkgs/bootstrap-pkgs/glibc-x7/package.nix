{
  # stdenv :: attrset+derivation
  stdenv,
  # glibc :: derivation
  glibc,
  # prev-glibc :: derivation
  prev-glibc,
  # perl :: derivation
  perl,
  # stageid :: string -- "2" for stage2, etc.
  stageid,
} :

stdenv.mkDerivation {
  name = "nxfs-glibc-x7-${stageid}";
  version = glibc.version;
  system = builtins.currentSystem;

  locales = prev-glibc.locales;

  buildPhase = ''
    rm -f $out/build.env

    (cd ${glibc} && (tar cf - . | tar xf - -C $TMPDIR))
    chmod -R +w $TMPDIR

    new=$(basename $out)
    old1=$(basename ${glibc})
    old2=$(basename ${prev-glibc})

    echo "redirect [$old1],[$old2] to [$new] throughout [$(basename ${glibc})]"

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
