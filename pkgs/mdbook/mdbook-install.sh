#!/bin/bash

set -euo pipefail

declare prefix
# /opt/rustc-1.80
prefix=$HOME/.cargo

while [[ $# > 0 ]]; do
    case "$1" in
        --prefix=*)
            prefix=${1#*=}
            ;;
        *)
            echo "error: unexpected argument [${1}]"
            exit 1
            ;;
    esac

    shift
done

cargo install --root ${prefix} mdbook-linkcheck
cargo install --root ${prefix} mdbook





