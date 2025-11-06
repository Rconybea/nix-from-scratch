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

stem:=xz
PREFIX:=$(shell realpath ../$(stem))

# TODO: could get this from nxfspkgs/bootstrap/nxfs-vars.sh
#       or introduce nxfspkgs/bootstrap/nxfs-vars.mk
#
# Get unique nix location where nxfs-sysroot-0 installed
#
# REQUIRE:
#  - sysroot available in nix store
#
sysroot_storepath:=$(shell nix-build ../../nxfs-toolchain-0)
dynamic_linker:=$(sysroot_storepath)/lib/ld-linux-x86-64.so.2

version:=5.6.2
# unique package name
name:=$(stem)-$(version)
# local directory for unpacked source
unpackdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.gz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
url:=https://github.com//tukaani-project/xz/releases/download/v$(version)/$(name).tar.gz
# verify this sha
sha256:=8bfd20c0e1d86f0402f2497cfa71c6ab62d4cd35fd704276e3140bfb71414519
#
patch_script:=
#
srcdir:=src
builddir:=build
# 1. PREFIX has been repointed to package-specific bootstrap dir, do not use
# 2. dynamic linker ld-linux-x86-64.so.2 and libc.so.6 *must* go together
#
cflags:=-I$(sysroot_storepath)/include
ldflags:=-Wl,-enable-new-dtags -Wl,-rpath,$(sysroot_storepath)/lib -Wl,-dynamic-linker,$(dynamic_linker)
#
configure_extra_args:=--docdir=$(PREFIX)/share/doc/$(name) --enable-shared
post_install_hook:=
pre_configure_hook:=
configure_script:=

.PHONY: all
all: compile

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
