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

# NOTE: for mdbook, trying a binary release.
#       Building from source would require we add to nix-from-scratch:
#          - rust
#          - cargo
#          - llvm
#       which we'd like to avoid diving into for now

version:=0.7.7
# unique package name
#name:=mdBook-$(version)
stem:=mdbook-linkcheck
name:=$(stem)-v$(version)
# local directory for unpacked source
unpackdir:=mdbook-linkcheck
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).zip
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
url=https://github.com/Michael-F-Bryan/$(stem)/releases/download/v$(version)/$(stem).x86_64-unknown-linux-gnu.zip
# verify this sha
sha256:=18cebca9493804b307b39a44af2664cdfa881e84b8d92a94205d6c51572318ef

#
cflags:=-I$(PREFIX)/include
ldflags:=-L$(PREFIX)/lib -Wl,-rpath,$(PREFIX)/lib
#
patch_script:=
srcdir:=binary
builddir:=build
unpack_exec:=unzip
unpack_args:=-o
patch_script:=mdbook-linkcheck-patch.sh
pre_configure_hook:=
# noop configure
configure_exec:=true
configure_extra_args:=
build_exec:=true
install_exec:=install 
install_args:=-m 755 $(THIS_DIR)/binary $(PREFIX)/bin/mdbook-linkcheck
post_install_hook:=

all: compile

# provides targets:
# - $(tarball_path)
# - state/fetch.result
# - fetch
#
include $(TOP_DIR)/mk/fetch.mk

# provides targets:
# - sh256
# - state/expected.sha256
# - state/verify.result
# - verify
#
include $(TOP_DIR)/mk/verify.mk

# provides targets:
# - state/unpack.result
# - unpack
#
include $(TOP_DIR)/mk/unpack.mk

# provides targets:
# - state/patch.result
# - patch
#
include $(TOP_DIR)/mk/patch.mk

# provides targets:
# - state/config.result
# - config
#
include $(TOP_DIR)/mk/configure.mk

# provides targets:
# - state/compile.mk
# - compile
#
include $(TOP_DIR)/mk/compile.mk

# provides targets:
# - state/install.mk
# - install
#
include $(TOP_DIR)/mk/install.mk

# provides targets:
# - distclean
# - verifyclean
# - unpackclean
# - configclean
# - clean
#
include $(TOP_DIR)/mk/clean.mk

