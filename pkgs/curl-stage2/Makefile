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

version:=8.9.1
# unique package name
name:=curl-$(version)
# local directory for unpacked source
unpackdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.gz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
url:=https://curl.haxx.se/download/$(tarball)
# verify this sha
sha256:=291124a007ee5111997825940b3876b3048f7d31e73e9caa681b80fe48b2dcd5
# Settings CFLAGS seems to break the flex configure script;
# complains that it can't invoke gcc.
cflags:=-I$(PREFIX)/include
ldflags:=-L$(PREFIX)/lib -Wl,-rpath,$(PREFIX)/lib
#
patch_script:=./curl-patch.sh
srcdir:=src
builddir:=build
pre_configure_hook:=$(THIS_DIR)/pre-configure-hook.sh --srcdir=$(srcdir)
configure_extra_args:=--with-openssl --enable-shared --enable-static=no 
post_install_hook:=

all: compile

include $(TOP_DIR)/mk/buildphases.mk
