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

# unique package name
name:=autoconf-archive-2023.02.20
#name:=v2023.02.20
# local directory for unpacked source
srcdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.xz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
#url:=https://ftpmirror.gnu.org/autoconf-archive/$(tarball)
url:=https://mirror.csclub.uwaterloo.ca/gnu/autoconf-archive/$(tarball)  # .xz
# verify this sha
sha256:=71d4048479ae28f1f5794619c3d72df9c01df49b1c628ef85fde37596dc31a33
#
patch_script:=
#
builddir:=build
#
cflags:=-I$(PREFIX)/include
ldflags:=-L$(PREFIX)/lib -Wl,-rpath,$(PREFIX)/lib

PHASE:=fetch verify unpack patch config compile install
COMMANDS:=all sha256 clean unpackclean distclean
.PHONY: $(PHASE) $(COMMANDS)

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

verifyclean: unpackclean
	rm -f state/verify.result

# unwind to state before src.
# preserves:
# - tarball in $(tarball_path)
# - cksum state
#
unpackclean: configclean
	rm -f state/unpack.result

configclean: clean
	$(TOP_DIR)/mk/configclean.sh --build-dir=$(builddir)

clean: distclean
	$(TOP_DIR)/mk/clean.sh --build-dir=$(builddir)

# unwind to state before fetch.
distclean: 
	$(TOP_DIR)/mk/distclean.sh --tarball-path=$(tarball_path) --build-dir=$(builddir)

