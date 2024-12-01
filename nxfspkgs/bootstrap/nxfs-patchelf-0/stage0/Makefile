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

stem:=patchelf
PREFIX:=$(shell realpath ../$(stem))

# Get unique nix location where nxfs-sysroot-0 installed
#
# REQUIRE:
#  - sysroot available in nix store
#
sysroot_storepath:=$(shell nix-build ../../nxfs-sysroot-0)

version:=0.18.0
# unique package name
name:=$(stem)-$(version)
# local directory for unpacked source
unpackdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.gz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
#url:=https://ftp.gnu.org/gnu/automake/$(tarball)
url:=https://github.com/NixOS/patchelf/releases/download/$(version)/$(tarball)
# verify this sha
sha256:=64de10e4c6b8b8379db7e87f58030f336ea747c0515f381132e810dbf84a86e7
#
cflags:=-I$(sysroot_storepath)/usr/include
ldflags:=-Wl,-enable-new-dtags -Wl,-rpath,$(sysroot_storepath)/usr/lib -Wl,-rpath,$(sysroot_storepath)/lib -Wl,-dynamic-linker,$(sysroot_storepath)/lib/ld-linux-x86-64.so.2
#
patch_script:=
srcdir:=src
builddir:=build
pre_configure_hook:=
configure_extra_args:=--host=$(NXFS_HOST_TUPLE) --build=$(NXFS_BUILD_TUPLE) --docdir=$(PREFIX)/share/doc/$(name)
post_install_hook:=

.PHONY: all
all: install

include $(TOP_DIR)/mk/buildphases.mk
