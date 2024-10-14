#!/usr/bin/env bash

# runs in *source* directory

patch -Np1 -i ../libssh2-1.11.0-security_fixes-1.patch
