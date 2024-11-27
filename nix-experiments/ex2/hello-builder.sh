export PATH="$coreutils/bin:$gcc/bin"
mkdir $out

declare -xp > $out/env

gcc -o $out/hello $src
