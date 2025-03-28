set -e

source ${setupScript}

mkdir -pv ${out}
mkdir -pv ${out}/nix-support

env > ${out}/build.env

genericBuild
