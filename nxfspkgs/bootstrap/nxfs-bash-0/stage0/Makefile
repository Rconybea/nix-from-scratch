# Always gets directory containing this Makefile, regardless of cwd
THIS_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
# Always root directory for nix-from-scratch (even if not a git repo)
TOP_DIR:=$(realpath $(THIS_DIR)/../../../..)

# provides:
#   ARCHIVE_DIR
#   PREFIX           exported
#   PATH             exported
#   PKG_CONFIG_PATH  exported
#
include $(TOP_DIR)/mk/config.mk

stem:=bash
PREFIX:=$(shell realpath ../$(stem))  

# Get unique nix location where nxfs-sysroot-0 installed
#
# REQUIRE:
#  - sysroot available in nix store
#
sysroot_storepath:=$(shell nix-build ../../nxfs-toolchain-0)
dynamic_linker:=$(sysroot_storepath)/lib/ld-linux-x86-64.so.2

version:=5.2.32
# unique package name
name:=$(stem)-$(version)
# local directory for unpacked source
unpackdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.gz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
url:=https://ftpmirror.gnu.org/gnu/$(stem)/$(tarball)
# verify this sha
sha256:=d3ef80d2b67d8cbbe4d3265c63a72c46f9b278ead6e0e06d61801b58f23f50b5
#
patch_script:=
#
srcdir:=src
builddir:=build
# 1. PREFIX has been repointed to package-specific bootstrap dir, do not use
# 2. dynamic linker ld-linux-x86-64.so.2 and libc.so.6 *must* go together
#    
cflags:=-I$(sysroot_storepath)/include -Wno-error=implicit-function-declaration
ldflags:=-Wl,-enable-new-dtags -Wl,-rpath,$(sysroot_storepath)/lib -Wl,-dynamic-linker,$(sysroot_storepath)/lib/ld-linux-x86-64.so.2
#
configure_extra_args:=--host=$(NXFS_HOST_TUPLE) --build=$(NXFS_BUILD_TUPLE) --without-bash-malloc bash_cv_strtold_broken=no
post_install_hook:=./post-install-hook.sh "--prefix=$(PREFIX)"

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

