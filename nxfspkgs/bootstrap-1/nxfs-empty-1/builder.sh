#!/bin/sh
#

set -euo pipefail

export PATH=${coreutils}/bin

mkdir -p ${out}
touch ${out}/done
