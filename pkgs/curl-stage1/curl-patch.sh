#!/usr/bin/env bash

# runs in *source* directory

patch -p1 < ../fix-sigpipe-leak.patch
