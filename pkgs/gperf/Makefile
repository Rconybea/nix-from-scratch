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

version:=3.0.4
# unique package name
name:=gperf-$(version)
# local directory for unpacked source
unpackdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.gz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
#url:=https://ftp.gnu.org/gnu/m4/$(tarball)
url:=https://ftp.gnu.org/gnu/gperf/$(tarball)
# verify this sha
sha256:=767112a204407e62dbc3106647cf839ed544f3cf5d0f0523aaa2508623aad63e
#
cflags:=-I$(PREFIX)/include
ldflags:=-L$(PREFIX)/lib -Wl,-rpath,$(PREFIX)/lib
#
patch_script:=
srcdir:=src
builddir:=build
# (runs in builddir) -- instead of "just calling path/to/src/configure"
configure_script:=
configure_exec:=
# (note: w/ non-empty configure_script, the 'extra' is superfluous)
configure_extra_args:=--prefix=$(PREFIX) --docdir=$(PREFIX)/share/doc/$(name)
#
post_install_hook:=./post-install-hook.sh --name=$(name) --prefix=$(PREFIX) --src-dir=$(srcdir)

.PHONY: all
all: compile

include $(TOP_DIR)/mk/buildphases.mk
