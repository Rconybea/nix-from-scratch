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

version:=3.11.3
# unique package name
name:=json-$(version)
# local directory for unpacked source
srcdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=v$(version).tar.gz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
url:=https://github.com/nlohmann/json/archive/refs/tags/$(tarball)
# verify this sha
sha256:=0d8ef5af7f9794e3263480193c491549b2ba6cc74bb018906202ada498a79406
#
#cflags:=-I$(PREFIX)/include
#ldflags:=-L$(PREFIX)/lib -Wl,-rpath,$(PREFIX)/lib
#
patch_script:=
builddir:=build
# (runs in builddir) -- instead of "just calling path/to/src/configure"
configure_exec:=cmake
configure_script:=
# (note: w/ non-empty configure_script, the 'extra' is superfluous)
configure_extra_args:=-DCMAKE_INSTALL_PREFIX=$(PREFIX) -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_RPATH=$(PREFIX)/lib "-DCMAKE_CXX_FLAGS=-I$(PREFIX)/include" -DBUILD_SHARED_LIBS=ON "-DCMAKE_SHARED_LINKER_FLAGS=-L$(PREFIX)/lib" -B . -S ../$(srcdir)
#
post_install_hook:=

.PHONY: all
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
