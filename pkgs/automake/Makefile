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
name:=automake-1.17
# local directory for unpacked source
srcdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.gz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
#url:=https://ftp.gnu.org/gnu/automake/$(tarball)
url:=https://mirror.csclub.uwaterloo.ca/gnu/automake/$(tarball)
# verify this sha
sha256:=397767d4db3018dd4440825b60c64258b636eaf6bf99ac8b0897f06c89310acd
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

state/patch.result: state/unpack.result ${patch_script}
	$(TOP_DIR)/mk/patch-src-dir.sh --src-dir=$(srcdir) --patch-script=${patch_script}

patch: state/patch.result

state/config.result $(builddir): state/patch.result
	$(TOP_DIR)/mk/configure-autotools.sh \
       --prefix=$(PREFIX) --src-dir=$(srcdir) \
       --build-dir=$(builddir) --cflags="$(cflags)" --ldflags="$(ldflags)"

config: state/config.result

state/compile.result: state/config.result
	$(TOP_DIR)/mk/compile-autotools.sh --build-dir=$(builddir)

compile: state/compile.result $(builddir)

install:
	$(TOP_DIR)/mk/install-autotools.sh --build-dir=$(builddir)

verifyclean:
	rm -f state/expected.sha256 state/verify.result

# unwind to state before src.
# preserves:
# - tarball in $(tarball_path)
# - cksum state
#
unpackclean:
	rm -f state/unpack.result

configclean:
	$(TOP_DIR)/mk/configclean.sh --build-dir=$(builddir)

clean:
	$(TOP_DIR)/mk/clean.sh --build-dir=$(builddir)

# unwind to state before fetch.
distclean: 
	$(TOP_DIR)/mk/distclean.sh --tarball-path=$(tarball_path) --build-dir=$(builddir)

