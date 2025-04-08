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

version:=3.3.1
# unique package name
name:=openssl-$(version)
# local directory for unpacked source
unpackdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.gz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
#url:=https://ftp.gnu.org/gnu/automake/$(tarball)
url:=https://www.openssl.org/source/$(tarball)
# verify this sha
sha256:=777cd596284c883375a2a7a11bf5d2786fc5413255efab20c50d6ffe6d020b7e
#
cflags:=-I$(PREFIX)/include
ldflags:=-L$(PREFIX)/lib -Wl,-rpath,$(PREFIX)/lib
#
patch_script:=
#
pre_configure_hook:=
#
srcdir:=src
builddir:=build
# (for openssl, instead of the usual 'configure')
configure_script:=config  
configure_extra_args:=--openssldir=$(PREFIX)/etc/ssl --libdir=lib zlib-dynamic
post_install_hook:=./post-install-hook.sh --name=$(name) --prefix=$(PREFIX)

all: compile

include $(TOP_DIR)/mk/buildphases.mk

