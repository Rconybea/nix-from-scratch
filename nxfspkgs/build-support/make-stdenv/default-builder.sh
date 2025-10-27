set -e
#set -x

# Don't let Claude talk you into putting
#  exec 1>&2
# here, it won't solve stdout/stderr permissioning issues.

source ${setupScript}

mkdir -pv ${out}
mkdir -pv ${out}/nix-support

# MISGUIDED INTERPOLATION.
# turns all build-time dependencies into run-time dependencies,
# which defeats bootstrap
#
#env > ${out}/build.env

genericBuild
