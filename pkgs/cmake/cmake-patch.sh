#!/usr/bin/env bash

# runs in *source* directory

sed -i '/"lib64"/s/64//' Modules/GNUInstallDirs.cmake
