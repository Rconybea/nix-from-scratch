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

version:=8.44
stem:=pcre
# unique package name
name:=pcre-$(version)
# local directory for unpacked source
unpackdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.bz2
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
url:=https://sourceforge.net/projects/pcre/files/$(stem)/$(version)/$(tarball)/download
# verify this sha
sha256:=19108658b23b3ec5058edc9f66ac545ea19f9537234be1ec62b714c84399366d
#
cflags:=-I$(PREFIX)/include
ldflags:=-L$(PREFIX)/lib -Wl,-rpath,$(PREFIX)/lib
#
#fetch_extra_args:=--no-check-certificate
patch_script:=
srcdir:=src
builddir:=build
pre_configure_hook:=
configure_extra_args:=--docdir=$(PREFIX)/share/doc/$(name) --enable-unicode-properties --enable-pcre16 --enable-pcre32 --enable-pcregrep-libz --enable-pcregrep-libbz2 --enable-pcretest-libreadline 
post_install_hook:=

all: compile

include $(TOP_DIR)/mk/buildphases.mk

