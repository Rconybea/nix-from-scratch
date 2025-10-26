set -e
#set -x

source ${setupScript}

mkdir -pv ${out}
mkdir -pv ${out}/nix-support

# MISGUIDED INTERPOLATION.
# turns all build-time dependencies into run-time dependencies,
# which defeats bootstrap
#
#env > ${out}/build.env

genericBuild
