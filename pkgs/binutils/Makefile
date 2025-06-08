# Always gets directory containing this Makefile, regardless of cwd
THIS_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
# Always root directory for nix-from-scratch (even if not a git repo)
TOP_DIR:=$(realpath $(THIS_DIR)/../..)

# provides:
#   TOP_DIR
#   ARCHIVE_DIR
#   PREFIX           exported
#   PATH             exported
#   PKG_CONFIG_PATH  exported
#
include $(TOP_DIR)/mk/config.mk

#PREFIX:=$(PREFIX)/native-toolchain-experiment

version:=2.43.1
# unique package name
name:=binutils-$(version)
# local directory for unpacked source
unpackdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.xz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
url:=https://sourceware.org/pub/binutils/releases/$(tarball)
# verify this sha
sha256:=13f74202a3c4c51118b797a39ea4200d3f6cfbe224da6d1d95bb938480132dfd
#
#cflags:=-I$(PREFIX)/include
#ldflags:=-L$(PREFIX)/lib -Wl,-rpath,$(PREFIX)/lib
#
patch_script:=
srcdir:=src
builddir:=build
#
# -- with-sysroot:    where to look for system libraries
#                     to be owned by eventual system
#
# --target:           if doesn't match config.guess (I think)
#                     so that binutils build prepares for a cross linker
#
# --disable-nls        | jettison stuff we can live without for stage1 compiler
# --enable-gprofng=nop |
#
# --disable-werror:   tolerate warnings
# --enable-new-dtags: use RUNPATH instead of deprecated RPATH
#
# --enable-default-hash-style=gnu:
#    1. use faster hash mechanism by default
#    2. don't build classic ELF hash by default
#
configure_extra_args:=--disable-nls --enable-gprofng=no --disable-werror --enable-new-dtags --enable-default-hash-style=gnu
post_install_hook:=

all: compile

include $(TOP_DIR)/mk/buildphases.mk

