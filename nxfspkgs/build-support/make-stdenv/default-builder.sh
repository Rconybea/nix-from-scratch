set -e

source ${setupScript}

mkdir -pv ${out}
mkdir -pv ${out}/nix-support

# nxfs interpolation
env > ${out}/build.env

genericBuild
