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

#  Yes we're bootstrapping.
#  unlike with stage1-binutils, stage1-gcc:
#  glibc does *not* go in the stage1 directory
#  instead it goes into final-destination PREFIX

# must mage stage1-binutils, stage1-gcc
TARGET=x86_64-nxfs-linux-gnu

stem:=glibc
version:=2.40
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
sha256:=19a890175e9263d748f627993de6f4b1af9cd21e03f080e4bfb3a1fac10205a2
#cflags:=-I$(PREFIX)/include
#ldflags:=-L$(PREFIX)/lib -Wl,-rpath,$(PREFIX)/lib
#
srcdir:=src
builddir:=build
#
post_unpack_script:=
patch_script:=glibc-patch.sh
#
# stage1 build.  don't need everything, keeping just what we need to bootstrap glibc
#
# --with-headers: point at /usr/include so we get headers for the host where we're building.
#                 How does nix bootstrap handle this?
#
# *not setting --target yet*
# --target: if doesn't match config.guess (I think)
#           so that binutils build prepares for a cross linker
#
pre_configure_hook:=../glibc-preconfigure.sh --prefix=$(PREFIX) # runs in build directory
configure_extra_args:=--host=$(TARGET) --build=x86_64-pc-linux-gnu --enable-kernel=4.19 --with-headers=$(NXFS_TOOLCHAIN_SYSROOT)/usr/include --disable-nscd libc_cv_slibdir=$(PREFIX)/lib #--build=$(THIS_DIR)/$(srcdir)/scripts/config.guess 

post_install_hook:=

all: compile

include $(TOP_DIR)/mk/buildphases.mk


