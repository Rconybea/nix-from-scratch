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

stem:=diffutils
PREFIX:=$(shell realpath ../$(stem))  

# Get unique nix location where nxfs-sysroot-0 installed
#
# REQUIRE:
#  - sysroot available in nix store
#
sysroot_storepath:=$(shell nix-build ../../nxfs-sysroot-0)

version:=3.10
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
sha256:=90e5e93cc724e4ebe12ede80df1634063c7a855692685919bfe60b556c9bd09e
#
patch_script:=
#
srcdir:=src
builddir:=build
# 1. PREFIX has been repointed to package-specific bootstrap dir, do not use
# 2. dynamic linker ld-linux-x86-64.so.2 and libc.so.6 *must* go together
#
cflags:=-I$(sysroot_storepath)/usr/include
ldflags:=-Wl,-enable-new-dtags -Wl,-rpath,$(sysroot_storepath)/usr/lib -Wl,-rpath,$(sysroot_storepath)/lib -Wl,-dynamic-linker,$(sysroot_storepath)/lib/ld-linux-x86-64.so.2
#
configure_extra_args:=--host=$(NXFS_HOST_TUPLE) --build=$(NXFS_BUILD_TUPLE)
post_install_hook:=

.PHONY: all
all: install

include $(TOP_DIR)/mk/buildphases.mk

