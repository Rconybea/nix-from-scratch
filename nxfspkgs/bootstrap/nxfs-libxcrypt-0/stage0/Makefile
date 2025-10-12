# Always gets directory containing this Makefile, regardless of cwd
THIS_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
# Always root directory for nix-from-scratch (even if not a git repo)
TOP_DIR:=$(realpath $(THIS_DIR)/../../../..)

# provides:
#   TOP_DIR
#   ARCHIVE_DIR
#   PREFIX           exported
#   PATH             exported
#   PKG_CONFIG_PATH  exported
#
include $(TOP_DIR)/mk/config.mk

stem:=libxcrypt
PREFIX:=$(shell realpath ../$(stem))

# Get unique nix location where nxfs-sysroot-0 installed
#
# REQUIRE:
#  - sysroot available in nix store
#
sysroot_storepath:=$(shell nix-build ../../nxfs-toolchain-0)
dynamic_linker:=$(sysroot_storepath)/lib/ld-linux-x86-64.so.2

version:=4.4.36
# unique package name
name:=$(stem)-$(version)
# local directory for unpacked source
unpackdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.xz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
url:=https://github.com/besser82/libxcrypt/releases/download/v$(version)/$(tarball)
# verify this sha
sha256:=e5e1f4caee0a01de2aee26e3138807d6d3ca2b8e67287966d1fefd65e1fd8943
#
#
srcdir:=src
builddir:=build
#
# don't do this -- interferes with compiler's patched system includes
#cflags:=-I$(sysroot_storepath)/usr/include
ldflags:=-Wl,-enable-new-dtags -Wl,-rpath,$(sysroot_storepath)/lib -Wl,-dynamic-linker,$(dynamic_linker)
#
patch_script:=
configure_extra_args:=--host=$(NXFS_HOST_TUPLE) --build=$(NXFS_BUILD_TUPLE) --enable-hashes=strong,glibc --enable-obsolete-api=no --disable-static --disable-failure-tokens
install_args:=
post_install_hook:=

.PHONY: all
all: install

# provides targets:
# - $(tarball_path)
# - state/fetch.result
# - fetch
# - sh256
# - state/expected.sha256
# - state/verify.result
# - verify
# - state/unpack.result
# - unpack
# - state/patch.result
# - patch
# - state/config.result
# - config
# - state/compile.mk
# - compile
# - state/install.mk
# - install
# - distclean
# - verifyclean
# - unpackclean
# - configclean
# - clean
#
include $(TOP_DIR)/mk/buildphases.mk

