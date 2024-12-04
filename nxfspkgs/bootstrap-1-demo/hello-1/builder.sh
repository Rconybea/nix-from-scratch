#!/bin/bash

set -e

echo
echo "gcc=${gcc}";
echo "mkdir=${mkdir}";
echo "bash=${bash}";
echo

${mkdir} ${out}

echo "hello roly" > ${out}/greetings.txt

${gcc} --version

${gcc} -o ${out}/hello ${src}
