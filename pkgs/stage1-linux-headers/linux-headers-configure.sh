#!/bin/bash

make mrproper
make headers
find usr/include -type f ! -name '*.h' -delete
