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

stem:=coreutils
PREFIX:=$(realpath ../$(stem))  

# REQUIRE:
#  - sysroot available in nix store
#
sysroot_storepath:=$(shell nix-build ../../nxfs-toolchain-0)
dynamic_linker:=$(sysroot_storepath)/lib/ld-linux-x86-64.so.2

version:=9.5
# unique package name
name:=$(stem)-$(version)
# local directory for unpacked source
unpackdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.xz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
url:=https://ftp.gnu.org/gnu/$(stem)/$(tarball)
# verify this sha
sha256:=cd328edeac92f6a665de9f323c93b712af1858bc2e0d88f3f7100469470a1b8a
#
patch_script:=coreutils-patch.sh
#
srcdir:=src
builddir:=build
# 1. PREFIX has been repointed to package-specific bootstrap dir, do not use
# 2. dynamic linker ld-linux-x86-64.so.2 and libc.so.6 *must* go together
#
cflags:=-I$(sysroot_storepath)/usr/include
ldflags:=-Wl,--enable-new-dtags -Wl,-rpath,$(sysroot_storepath)/lib -Wl,--dynamic-linker,$(dynamic_linker)
#
configure_extra_args:=--host=$(NXFS_HOST_TUPLE) --build=$(NXFS_BUILD_TUPLE) --enable-no-install-program=kill,uptime

.PHONY: all
all: install

include $(TOP_DIR)/mk/buildphases.mk

