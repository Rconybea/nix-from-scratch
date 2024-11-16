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

version:=1.8.1
# unique package name
stem:=libgit2
name:=$(stem)-$(version)
# local directory for unpacked source
unpackdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(stem).tar.gz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
#url:=https://ftp.gnu.org/gnu/automake/$(tarball)
url:=https://github.com/libgit2/libgit2/archive/refs/tags/v$(version).tar.gz
# verify this sha
sha256:=8c1eaf0cf07cba0e9021920bfba9502140220786ed5d8a8ec6c7ad9174522f8e
#
# {cflags,ldflags} won't work when configure_script=cmake
#cflags:=-I$(PREFIX)/include
#ldflags:=-L$(PREFIX)/lib -Wl,-rpath,$(PREFIX)/lib
#
patch_script:=
srcdir:=src
builddir:=build
pre_configure_hook:=
configure_exec:=cmake
configure_script:=
configure_extra_args:=-DCMAKE_INSTALL_PREFIX=$(PREFIX) -DCMAKE_INSTALL_RPATH=$(PREFIX)/lib -DBUILD_SHARED_LIBS=ON -DUSE_SSH=ON -DCMAKE_C_FLAGS=-I$(PREFIX)/include -B . -S ../$(srcdir)
post_install_hook:=

all: compile

include $(TOP_DIR)/mk/buildphases.mk
