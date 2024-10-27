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

# eventually need to match what nixpkgs uses to select?
#SYSTEM=$(shell echo "$$(uname -m)-nxfs-$$(uname -o | tr [:upper:] [:lower:])-gnu")
#SYSTEM=$(shell echo "$$(uname -m)-nxfs-$$(uname -o)-macos")
SYSTEM=aarch64-darwin

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
# Settings CFLAGS seems to break the flex configure script;
# complains that it can't invoke gcc.
cflags:=-I$(PREFIX)/include
ldflags:=-L$(PREFIX)/lib -Wl,-rpath,$(PREFIX)/lib
#
patch_script:=
srcdir:=src
builddir:=build
#
# --target: if doesn't match config.gues (I think)
#           so that binutils build prepares for a cross linker
#
configure_extra_args:=--with-sysroot=$(PREFIX) --disable-nls --enable-gprofng=no --disable-werror --enable-new-dtags --enable-default-hash-style=gnu
post_install_hook:=

all: compile

include $(TOP_DIR)/mk/buildphases.mk

