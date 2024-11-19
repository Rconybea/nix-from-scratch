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

version:=1.4.19
# unique package name
name:=m4-$(version)
# local directory for unpacked source
unpackdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.gz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
#url:=https://ftp.gnu.org/gnu/m4/$(tarball)
url:=https://mirror.csclub.uwaterloo.ca/gnu/m4/$(tarball)
# verify this sha
sha256:=3be4a26d825ffdfda52a56fc43246456989a3630093cced3fbddf4771ee58a70
#
patch_script:=m4-patch.sh
#
srcdir:=src
builddir:=build
#
cflags:=-I$(PREFIX)/include
ldflags:=-L$(PREFIX)/lib -Wl,-rpath,$(PREFIX)/lib

.PHONY: all
all: compile

include $(TOP_DIR)/mk/buildphases.mk


