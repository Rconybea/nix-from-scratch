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
# local directory for unpacked source
srcdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.xz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
url:=https://ftpmirror.gnu.org/autoconf-archive/$(tarball)
#url:=https://mirror.csclub.uwaterloo.ca/gnu/autoconf/$(tarball)
# verify this sha
sha256:=71d4048479ae28f1f5794619c3d72df9c01df49b1c628ef85fde37596dc31a33
#
patch_script:=
#
builddir:=build
#
cflags:=-I$(PREFIX)/include
ldflags:=-L$(PREFIX)/lib -Wl,-rpath,$(PREFIX)/lib

#
#        /----distclean
#        v
#     (start)
#        |
#        |fetch
#        |
#        |/---verifyclean
#        vv
#       (s1)      [ok: empty state/fetch.result, $(tarball_path), log/wget.log]
#        |
#        |verify
#        |
#        |/---unpackclean
#        vv
#       (s2)      [ok: empty state/verify.result; state/*.sha256]
#        |
#        |unpack
#        v
#       (s3)
#        |
#        |patch
#        v
#       (s4)
#        |
#        |config
#        |
#        |/---clean
#        vv
#       (s5) 
#        |
#        |compile
#        v
#       (s6)
#        |
#        |install
#        v
#     (finish)
#

PHASE:=fetch verify unpack patch config compile install
COMMANDS:=all sha256 clean unpackclean distclean
.PHONY: $(PHASE) $(COMMANDS)

all: compile

# fetch tarball
#
# on success:
# - state/fetch.result holds tarball_path
# on failure:
# - state/fetch.result holds error message
#
$(tarball_path) state/fetch.result: 
	$(TOP_DIR)/mk/init.sh --archive-dir=$(ARCHIVE_DIR)
	$(TOP_DIR)/mk/fetch-tarball.sh --archive-dir=$(ARCHIVE_DIR) --url=$(url) --tarball-path=$(tarball_path)

# - noop when $(tarball_path) already established
#   (use `make distclean` to do-over)
#
fetch: $(tarball_path) state/fetch.result

# promise:
# - [state/expected_sha256] consistent with {$(sha256), $(tarball_path)};
#   only updated when contents changed
#   (so [state/expected.sha256] works well as make dependency)
# - exit code 0 iff {expected, actual} match
#
# (reminder: state/fetch.result here needed so that 'make all' in initial state does fetch,
#  since require-sha256 checks that tarball path is present + additionally produces actual sha256)
#
sha256 state/expected.sha256: state/fetch.result
	$(TOP_DIR)/mk/require-sha256.sh --sha256=$(sha256) --tarball-path=$(tarball_path)

state/verify.result: state/expected.sha256 
	$(MAKE) sha256  # in case Makefile was edited, but disk the same
	$(TOP_DIR)/mk/verify-sha256.sh

verify: state/verify.result

state/unpack.result: state/verify.result 
	$(TOP_DIR)/mk/unpack-tarball.sh --tarball-path=$(tarball_path) --src-dir=${srcdir}

unpack: state/unpack.result

state/patch.result: state/unpack.result ${patch_script}
	$(TOP_DIR)/mk/patch-src-dir.sh --src-dir=$(srcdir) --patch-script=${patch_script}

patch: state/patch.result

# note: for autotools-archive: could pass null values for --cflags and --ldflags
#
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
	rm -f state/verify.result

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

