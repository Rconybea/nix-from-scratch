#!/bin/bash

set -e

infodir=${1}
shift

cd ${infodir}
rm -v dir
for FILENAME in *; do
    install-info ${FILENAME} dir 2> /dev/null
done
