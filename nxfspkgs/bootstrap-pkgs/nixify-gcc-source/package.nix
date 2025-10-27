{
  # stdenv :: derivation+attrset
  stdenv,
  # file :: derivation
  file,
  # which :: derivation
  which,
  # stageid :: string
  stageid
} :

let
  version = "14.2.0";
in

stdenv.mkDerivation {
  name = "nixify-gcc-source-${stageid}";
  version = version;

  src = builtins.fetchTarball { name = "gcc-${version}-source";
                                url = "https://ftpmirror.gnu.org/gnu/gcc/gcc-${version}/gcc-${version}.tar.xz";
                                sha256 = "1bdp6l9732316ylpzxnamwpn08kpk91h7cmr3h1rgm3wnkfgxzh9";
                              };

  buildPhase = ''
    file_program=$(which file)

    (cd $src && (tar cf - . | tar xf - -C $out))
    chmod -R +w $out

    (cd $out && sed -i -e '/m64=/s:lib64:lib:' ./gcc/config/i386/t-linux64)
    (cd $out && sed -i -e "1s:#!/bin/sh:#!$shell:" move-if-change)
    (cd $out && sed -i -e "s:/usr/bin/file:$file_program:" ./libstdc++-v3/configure)
    (cd $out && sed -i -e "s:/usr/bin/file:$file_program:" ./libcc1/configure)
    (cd $out && sed -i -e "s:/usr/bin/file:$file_program:" ./gcc/configure)
    (cd $out && sed -i -e "s:/usr/bin/file:$file_program:" ./zlib/configure)
    #
    # in general:
    #  - don't try to expand .l files (will trigger doc rebuild)
    #  - replace shebangs: {/bin/sh, /usr/bin/env sh, /usr/bin/env bash} -> $shell
    #
    (cd $out && find . -type f | grep -v '*.l$' | xargs sed -i -e "1s:#! /bin/sh:#! $shell:" -e "1s:#!/usr/bin/env sh:#! $shell:" -e "#1:#!/usr/bin/env bash:#! $shell:")
'';

  shell = stdenv.shell;

  # buildInputs: runtime dependencies
  buildInputs = [ file which ];
}
