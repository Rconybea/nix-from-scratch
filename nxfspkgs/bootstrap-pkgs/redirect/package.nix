{
  # stdenv :: attrset+derivation
  stdenv,
  # gcc-p1 :: derivation
  gcc-p1,
  # gcc-p2 :: derivation
  gcc-p2,
  # nixified-gcc-source-p1 :: derivation
  nixify-gcc-source-p1,
  # nixified-gcc-source-p2 :: derivation
  nixify-gcc-source-p2,
  # mpc-p1 :: derivation
  mpc-p1,
  # mpc-p2 :: derivation
  mpc-p2,
  # mpfr-p1 :: derivation
  mpfr-p1,
  # mpfr-p2 :: derivation
  mpfr-p2,
  # isl-p1 :: derivation
  isl-p1,
  # isl-p2 :: derivation
  isl-p2,
  # gmp-p1 :: derivation
  gmp-p1,
  # gmp-p2 :: derivation
  gmp-p2,
  # flex-p1 :: derivation
  flex-p1,
  # flex-p2 :: derivation
  flex-p2,
  # file-p1 :: derivation
  file-p1,
  # file-p2 :: derivation
  file-p2,
  # m4-p1 :: derivation
  m4-p1,
  # m4-p2 :: derivation
  m4-p2,
  # glibc-p1 :: derivation
  glibc-p1,
  # glibc-p2 :: derivation
  glibc-p2,
  # coreutils-p1 :: derivation
  coreutils-p1,
  # coreutils-p2 :: derivation
  coreutils-p2,
  # bash-p1 :: derivation
  bash-p1,
  # bash-p2 :: derivation
  bash-p2,
  # perl :: derivation
  perl,
  # stageid :: string -- "2" for stage2, etc.
  stageid,
} :

stdenv.mkDerivation {
  # name for each output will look like ${hash}-${stageid}-${out}
  # e.g. abc123-boot-bash
  #
  # Need boot-bash to be no longer than nxfs-bash-2
  #
  name = "BOOT-${stageid}";
  version = "${stageid}";
  system = builtins.currentSystem;

  buildPhase = ''
    # must be the same length:
    #   nxfs-bash-2
    #   BOOT-2/bash
    #
    #   nxfs-coreutils-2
    #   BOOT-2/coreutils
    #
    #   nxfs-mpfr-2
    #   BOOT-2/mpfr
    #
    #   nxfs-isl-2
    #   BOOT-2/isl
    #
    #   nxfs-gmp-2
    #   BOOT-2/gmp
    #
    #   nxfs-flex-2
    #   BOOT-2/flex
    #
    #   nxfs-glibc-x1-2.40-2
    #   BOOT-2/glibcXXXXXXXX
    #
    mkdir -p $out/bash
    mkdir -p $out/coreutils
    mkdir -p $out/glibcXXXXXXXX
    mkdir -p $out/gmp
    mkdir -p $out/isl
    mkdir -p $out/mpfr
    mkdir -p $out/mpc
    mkdir -p $out/flex
    mkdir -p $out/file
    mkdir -p $out/m4
    mkdir -p $out/nxfy-gcc-src
    mkdir -p $out/gccXXX

    mkdir -p $TMPDIR/bash
    (cd ${bash-p1} && (tar cf - . | tar xf - -C $TMPDIR/bash))
    chmod -R +w $TMPDIR/bash

    mkdir -p $TMPDIR/coreutils
    (cd ${coreutils-p1} && (tar cf - . | tar xf - -C $TMPDIR/coreutils))
    chmod -R +w $TMPDIR/coreutils

    mkdir -p $TMPDIR/glibc
    (cd ${glibc-p1} && (tar cf - . | tar xf - -C $TMPDIR/glibc))
    chmod -R +w $TMPDIR/glibc

    mkdir -p $TMPDIR/m4
    (cd ${m4-p1} && (tar cf - . | tar xf - -C $TMPDIR/m4))
    chmod -R +w $TMPDIR/m4

    mkdir -p $TMPDIR/file
    (cd ${file-p1} && (tar cf - . | tar xf - -C $TMPDIR/file))
    chmod -R +w $TMPDIR/file

    mkdir -p $TMPDIR/flex
    (cd ${flex-p1} && (tar cf - . | tar xf - -C $TMPDIR/flex))
    chmod -R +w $TMPDIR/flex

    mkdir -p $TMPDIR/gmp
    (cd ${gmp-p1} && (tar cf - . | tar xf - -C $TMPDIR/gmp))
    chmod -R +w $TMPDIR/gmp

    mkdir -p $TMPDIR/isl
    (cd ${isl-p1} && (tar cf - . | tar xf - -C $TMPDIR/isl))
    chmod -R +w $TMPDIR/isl

    mkdir -p $TMPDIR/mpfr
    (cd ${mpfr-p1} && (tar cf - . | tar xf - -C $TMPDIR/mpfr))
    chmod -R +w $TMPDIR/mpfr

    mkdir -p $TMPDIR/mpc
    (cd ${mpc-p1} && (tar cf - . | tar xf - -C $TMPDIR/mpc))
    chmod -R +w $TMPDIR/mpc

    mkdir -p $TMPDIR/nxfy-gcc-src
    (cd ${nixify-gcc-source-p1} && (tar cf - . | tar xf - -C $TMPDIR/nxfy-gcc-src))
    chmod -R +w $TMPDIR/nxfy-gcc-src

    mkdir -p $TMPDIR/gcc
    (cd ${gcc-p1} && (tar cf - . | tar xf - -C $TMPDIR/gcc))
    chmod -R +w $TMPDIR/gcc

    bash_new=$(basename $out)/bash
    bash_p1=$(basename ${bash-p1})
    bash_p2=$(basename ${bash-p2})

    coreutils_new=$(basename $out)/coreutils
    coreutils_p1=$(basename ${coreutils-p1})
    coreutils_p2=$(basename ${coreutils-p2})

    glibc_new=$(basename $out)/glibcXXXXXXXX
    glibc_p1=$(basename ${glibc-p1})
    glibc_p2=$(basename ${glibc-p2})

    m4_new=$(basename $out)/m4
    m4_p1=$(basename ${m4-p1})
    m4_p2=$(basename ${m4-p2})

    file_new=$(basename $out)/file
    file_p1=$(basename ${file-p1})
    file_p2=$(basename ${file-p2})

    flex_new=$(basename $out)/flex
    flex_p1=$(basename ${flex-p1})
    flex_p2=$(basename ${flex-p2})

    gmp_new=$(basename $out)/gmp
    gmp_p1=$(basename ${gmp-p1})
    gmp_p2=$(basename ${gmp-p2})

    isl_new=$(basename $out)/isl
    isl_p1=$(basename ${isl-p1})
    isl_p2=$(basename ${isl-p2})

    mpfr_new=$(basename $out)/mpfr
    mpfr_p1=$(basename ${mpfr-p1})
    mpfr_p2=$(basename ${mpfr-p2})

    mpc_new=$(basename $out)/mpc
    mpc_p1=$(basename ${mpc-p1})
    mpc_p2=$(basename ${mpc-p2})

    nixify_gcc_source_new=$(basename $out)/nxfy-gcc-src
    nixify_gcc_source_p1=$(basename ${nixify-gcc-source-p1})
    nixify_gcc_source_p2=$(basename ${nixify-gcc-source-p2})

    gcc_new=$(basename $out)/gccXXX
    gcc_p1=$(basename ${gcc-p1})
    gcc_p2=$(basename ${gcc-p2})

    # supplies stringlength(), padspaces()
    source ${./stringlength.sh}

    echo "redirect throughout {bash,coreutils}:"
    echo " [$bash_p1]      to [$bash_new]      padding [$(padding $bash_p1 $bash_new)]"
    echo " [$bash_p2]      to [$bash_new]      padding [$(padding $bash_p2 $bash_new)]"
    echo " [$coreutils_p1] to [$coreutils_new] padding [$(padding $coreutils_p1 $coreutils_new)]"
    echo " [$coreutils_p2] to [$coreutils_new] padding [$(padding $coreutils_p2 $coreutils_new)]"
    echo " [$glibc_p1]     to [$glibc_new]     padding [$(padding $glibc_p1 $glibc_new)]"
    echo " [$glibc_p2]     to [$glibc_new]     padding [$(padding $glibc_p2 $glibc_new)]"
    echo " [$m4_p1]        to [$m4_new]        padding [$(padding $m4_p1 $m4_new)]"
    echo " [$m4_p2]        to [$m4_new]        padding [$(padding $m4_p2 $m4_new)]"
    echo " [$file_p1]      to [$file_new]      padding [$(padding $file_p1 $file_new)]"
    echo " [$file_p2]      to [$file_new]      padding [$(padding $file_p2 $file_new)]"
    echo " [$flex_p1]      to [$flex_new]      padding [$(padding $flex_p1 $flex_new)]"
    echo " [$flex_p2]      to [$flex_new]      padding [$(padding $flex_p2 $flex_new)]"
    echo " [$gmp_p1]       to [$gmp_new]       padding [$(padding $gmp_p1 $gmp_new)]"
    echo " [$gmp_p2]       to [$gmp_new]       padding [$(padding $gmp_p2 $gmp_new)]"
    echo " [$isl_p1]       to [$isl_new]       padding [$(padding $isl_p1 $isl_new)]"
    echo " [$isl_p2]       to [$isl_new]       padding [$(padding $isl_p2 $isl_new)]"
    echo " [$mpfr_p1]      to [$mpfr_new]      padding [$(padding $mpfr_p1 $mpfr_new)]"
    echo " [$mpfr_p2]      to [$mpfr_new]      padding [$(padding $mpfr_p2 $mpfr_new)]"
    echo " [$mpc_p1]       to [$mpc_new]       padding [$(padding $mpc_p1 $mpc_new)]"
    echo " [$mpc_p2]       to [$mpc_new]       padding [$(padding $mpc_p2 $mpc_new)]"
    echo " [$nixify_gcc_source_p1] to [$nixify_gcc_source_new] padding [$(padding $nixify_gcc_source_p1 $nixify_gcc_source_new)]"
    echo " [$nixify_gcc_source_p2] to [$nixify_gcc_source_new] padding [$(padding $nixify_gcc_source_p2 $nixify_gcc_source_new)]"
    echo " [$gcc_p1]       to [$gcc_new]       padding [$(padding $gcc_p1 $gcc_new)]"
    echo " [$gcc_p2]       to [$gcc_new]       padding [$(padding $gcc_p2 $gcc_new)]"

    replace_refs() {
      file=$1
      old=$2
      new=$3

      oldz=$(stringlength "$old")
      newz=$(stringlength "$new")

      if (( $oldz != $newz )); then
        echo "replace_refs: cannot modify string size in place. old=[$old], new=[$new]"
        exit 1
      fi

      if grep -l -a -F "$old" $file 2>/dev/null; then
        #echo "update [$file]"
        perl -pi -e "s|\Q$old\E|$new|g" $file
      fi
    }

    # find/replace across $TMPDIR/{bash,coreutils,..}
    find $TMPDIR -type f | while read -r file; do
       replace_refs $file $bash_p1 $bash_new
       replace_refs $file $bash_p2 $bash_new

       replace_refs $file $coreutils_p1 $coreutils_new
       replace_refs $file $coreutils_p2 $coreutils_new

       replace_refs $file $glibc_p1 $glibc_new
       replace_refs $file $glibc_p2 $glibc_new

       replace_refs $file $m4_p1 $m4_new
       replace_refs $file $m4_p2 $m4_new

       replace_refs $file $file_p1 $file_new
       replace_refs $file $file_p2 $file_new

       replace_refs $file $flex_p1 $flex_new
       replace_refs $file $flex_p2 $flex_new

       replace_refs $file $gmp_p1 $gmp_new
       replace_refs $file $gmp_p2 $gmp_new

       replace_refs $file $isl_p1 $isl_new
       replace_refs $file $isl_p2 $isl_new

       replace_refs $file $mpfr_p1 $mpfr_new
       replace_refs $file $mpfr_p2 $mpfr_new

       replace_refs $file $mpc_p1 $mpc_new
       replace_refs $file $mpc_p2 $mpc_new

       replace_refs $file $nixify_gcc_source_p1 $nixify_gcc_source_new
       replace_refs $file $nixify_gcc_source_p2 $nixify_gcc_source_new

       replace_refs $file $gcc_p1 $gcc_new
       replace_refs $file $gcc_p2 $gcc_new
    done

    (cd $TMPDIR/bash && (tar cf - . | tar xf - -C $out/bash))
    (cd $TMPDIR/coreutils && (tar cf - . | tar xf - -C $out/coreutils))
    (cd $TMPDIR/glibc && (tar cf - . | tar xf - -C $out/glibcXXXXXXXX))
    (cd $TMPDIR/file && (tar cf - . | tar xf - -C $out/file))
    (cd $TMPDIR/m4 && (tar cf - . | tar xf - -C $out/m4))
    (cd $TMPDIR/flex && (tar cf - . | tar xf - -C $out/flex))
    (cd $TMPDIR/gmp && (tar cf - . | tar xf - -C $out/gmp))
    (cd $TMPDIR/isl && (tar cf - . | tar xf - -C $out/isl))
    (cd $TMPDIR/mpfr && (tar cf - . | tar xf - -C $out/mpfr))
    (cd $TMPDIR/mpc && (tar cf - . | tar xf - -C $out/mpc))
    (cd $TMPDIR/nxfy-gcc-src && (tar cf - . | tar xf - -C $out/nxfy-gcc-src))
    (cd $TMPDIR/gcc && (tar cf - . | tar xf - -C $out/gccXXX))

    (cd $out && ln -s glibcXXXXXXXX glibc)
    (cd $out && ln -s gccXXX gcc)
  '';

  buildInputs = [ perl ];
}
