# strategy from https://adonis0147.gihub.io/post/portable-gcc-toolchain
#
# we're going to build the toolchain in one go.
# This helps resolve circular dependencies between glibc<->gcc
#
# We don't have separate install step, because build will incrementally install
# as it runs.
#
# Instead we use separate install destination $(NXFS_TOOLCHAIN_PREFIX)

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

# we're bootstrapping.
#  NXFS_TOOLCHAIN_PREFIX is our ultimate destination (from included prefix.mk)
#  PREFIX_0              saving for hygiene, since we override PREFIX locally
#  STAGE1_PREFIX         install destination for this build; temporary under NXFS_TOOLCHAIN_PREFIX
PREFIX_0:=$(PREFIX)
PREFIX:=$(NXFS_TOOLCHAIN_PREFIX)
TARGET:=x86_64-pc-linux-gnu

# using binutils here, but will actually fetch all of:
#   binutils
#   mpfr
#   mpc
#   gmp
#   isl
#   gettext
#   glibc
#   gcc
#

binutils_name:=binutils-2.43.1
binutils_tarball:=$(binutils_name).tar.xz
binutils_url:=https://sourceware.org/pub/binutils/releases/$(binutils_tarball)
binutils_sha256:=13f74202a3c4c51118b797a39ea4200d3f6cfbe224da6d1d95bb938480132dfd

linux_headers_name:=linux-6.12.49
linux_headers_version_major:=6
linux_headers_tarball:=$(linux_headers_name).tar.xz
linux_headers_url=https://www.kernel.org/pub/linux/kernel/v$(linux_headers_version_major).x/$(linux_headers_tarball)
linux_headers_sha256:=234621e146dacce2241049555d550e4f7a6bde67ccd7ef232d47ac8145425526

gmp_name:=gmp-6.3.0
gmp_tarball:=$(gmp_name).tar.xz
gmp_url:=https://ftpmirror.gnu.org/gnu/gmp/$(gmp_tarball)
gmp_sha256:=a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898

mpfr_name:=mpfr-4.2.1
mpfr_tarball:=$(mpfr_name).tar.xz
mpfr_url:=https://ftpmirror.gnu.org/gnu/mpfr/$(mpfr_tarball)
mpfr_sha256:=277807353a6726978996945af13e52829e3abd7a9a5b7fb2793894e18f1fcbb2

mpc_name:=mpc-1.3.1
mpc_tarball:=$(mpc_name).tar.gz
mpc_url:=https://ftpmirror.gnu.org/gnu/mpc/$(mpc_tarball)
mpc_sha256:=ab642492f5cf882b74aa0cb730cd410a81edcdbec895183ce930e706c1c759b8

isl_name:=isl-0.24
isl_tarball:=$(isl_name).tar.bz2
isl_url:=https://gcc.gnu.org/pub/gcc/infrastructure/$(isl_tarball)
isl_sha256:=fcf78dd9656c10eb8cf9fbd5f59a0b6b01386205fe1934b3b287a0a1898145c0

gettext_name:=gettext-0.22
gettext_tarball:=$(gettext_name).tar.gz
gettext_url:=https://gcc.gnu.org/pub/gcc/infrastructure/$(gettext_tarball)
gettext_sha256:=49f089be11b490170bbf09ed2f51e5f5177f55be4cc66504a5861820e0fb06ab

gcc_name:=gcc-14.2.0
gcc_tarball:=$(gcc_name).tar.xz
gcc_url:=https://ftpmirror.gnu.org/gnu/gcc/$(gcc_name)/$(gcc_tarball)
gcc_sha256:=a7b39bc69cbf9e25826c5a60ab26477001f7c08d85cec04bc0e29cabed6f3cc9

glibc_name:=glibc-2.40
glibc_tarball:=$(glibc_name).tar.xz
glibc_url:=https://ftpmirror.gnu.org/gnu/glibc/$(glibc_tarball)
glibc_sha256:=19a890175e9263d748f627993de6f4b1af9cd21e03f080e4bfb3a1fac10205a2


patch_script:=
#
srcdir:=src
builddir:=build
#
pre_configure_hook:=
configure_exec:=true
# build+install both done from build scripts
build_exec:=$(THIS_DIR)/tools/build.sh
#
install_exec:=true

all: compile

state/fetch-binutils.result:
	$(TOP_DIR)/scripts/init.sh --archive-dir=$(ARCHIVE_DIR)
	$(TOP_DIR)/scripts/fetch-tarball.sh --archive-dir=$(ARCHIVE_DIR) --url=$(binutils_url) --tarball-path=$(ARCHIVE_DIR)/$(binutils_tarball) --noclobber --fetchresult=state/fetch-binutils.result

state/fetch-linux-headers.result:
	$(TOP_DIR)/scripts/init.sh --archive-dir=$(ARCHIVE_DIR)
	$(TOP_DIR)/scripts/fetch-tarball.sh --archive-dir=$(ARCHIVE_DIR) --url=$(linux_headers_url) --tarball-path=$(ARCHIVE_DIR)/$(linux_headers_tarball) --noclobber --fetchresult=state/fetch-linux-headers.result

state/fetch-gmp.result:
	$(TOP_DIR)/scripts/init.sh --archive-dir=$(ARCHIVE_DIR)
	$(TOP_DIR)/scripts/fetch-tarball.sh --archive-dir=$(ARCHIVE_DIR) --url=$(gmp_url) --tarball-path=$(ARCHIVE_DIR)/$(gmp_tarball) --noclobber --fetchresult=state/fetch-gmp.result

state/fetch-mpfr.result:
	$(TOP_DIR)/scripts/init.sh --archive-dir=$(ARCHIVE_DIR)
	$(TOP_DIR)/scripts/fetch-tarball.sh --archive-dir=$(ARCHIVE_DIR) --url=$(mpfr_url) --tarball-path=$(ARCHIVE_DIR)/$(mpfr_tarball) --noclobber --fetchresult=state/fetch-mpfr.result

state/fetch-mpc.result:
	$(TOP_DIR)/scripts/init.sh --archive-dir=$(ARCHIVE_DIR)
	$(TOP_DIR)/scripts/fetch-tarball.sh --archive-dir=$(ARCHIVE_DIR) --url=$(mpc_url) --tarball-path=$(ARCHIVE_DIR)/$(mpc_tarball) --noclobber --fetchresult=state/fetch-mpc.result

state/fetch-isl.result:
	$(TOP_DIR)/scripts/init.sh --archive-dir=$(ARCHIVE_DIR)
	$(TOP_DIR)/scripts/fetch-tarball.sh --archive-dir=$(ARCHIVE_DIR) --url=$(isl_url) --tarball-path=$(ARCHIVE_DIR)/$(isl_tarball) --noclobber --fetchresult=state/fetch-isl.result

state/fetch-gettext.result:
	$(TOP_DIR)/scripts/init.sh --archive-dir=$(ARCHIVE_DIR)
	$(TOP_DIR)/scripts/fetch-tarball.sh --archive-dir=$(ARCHIVE_DIR) --url=$(gettext_url) --tarball-path=$(ARCHIVE_DIR)/$(gettext_tarball) --noclobber --fetchresult=state/fetch-gettext.result

state/fetch-gcc.result:
	$(TOP_DIR)/scripts/init.sh --archive-dir=$(ARCHIVE_DIR)
	$(TOP_DIR)/scripts/fetch-tarball.sh --archive-dir=$(ARCHIVE_DIR) --url=$(gcc_url) --tarball-path=$(ARCHIVE_DIR)/$(gcc_tarball) --noclobber --fetchresult=state/fetch-gcc.result

state/fetch-glibc.result:
	$(TOP_DIR)/scripts/init.sh --archive-dir=$(ARCHIVE_DIR)
	$(TOP_DIR)/scripts/fetch-tarball.sh --archive-dir=$(ARCHIVE_DIR) --url=$(glibc_url) --tarball-path=$(ARCHIVE_DIR)/$(glibc_tarball) --noclobber --fetchresult=state/fetch-glibc.result


.PHONY: fetch
fetch:
	${MAKE} state/fetch.result
	cat state/fetch.result

state/fetch.result: state/fetch-binutils.result \
                    state/fetch-linux-headers.result \
                    state/fetch-gmp.result \
                    state/fetch-mpfr.result \
                    state/fetch-mpc.result \
                    state/fetch-isl.result \
                    state/fetch-gettext.result \
                    state/fetch-gcc.result \
                    state/fetch-glibc.result
	cat state/fetch-binutils.result \
        state/fetch-linux-headers.result \
        state/fetch-gmp.result \
        state/fetch-mpfr.result \
        state/fetch-mpc.result \
        state/fetch-isl.result \
        state/fetch-gettext.result \
        state/fetch-gcc.result \
        state/fetch-glibc.result > state/fetch.result

# require-sha256.sh: establish file with checksums for verify-sha256 script
sha256 state/expected.sha256: state/fetch.result
	$(TOP_DIR)/scripts/require-multiple-sha256.sh --archive-dir=$(ARCHIVE_DIR) \
      $(binutils_sha256):$(binutils_tarball) \
      $(linux_headers_sha256):$(linux_headers_tarball) \
      $(gmp_sha256):$(gmp_tarball) \
      $(mpfr_sha256):$(mpfr_tarball) \
      $(mpc_sha256):$(mpc_tarball) \
      $(isl_sha256):$(isl_tarball) \
      $(gettext_sha256):$(gettext_tarball) \
      $(gcc_sha256):$(gcc_tarball) \
      $(glibc_sha256):$(glibc_tarball)

state/verify.result: state/expected.sha256 state/actual.sha256
	make sha256  # for when makefile sha256 edited
	$(TOP_DIR)/scripts/verify-sha256.sh

# - noop when state/verify.result already established
#   (use `make verifyclean` to do-over)
#
.PHONY: verify
verify: state/verify.result

state/unpack.result: state/verify.result 
	mkdir -p src
	mkdir -p src/gcc
	echo '$(binutils_name)' > state/package-version
	$(TOP_DIR)/scripts/unpack-tarball.sh --tarball-path=$(ARCHIVE_DIR)/$(binutils_tarball) --tarball-unpack-dir=$(binutils_name) --src-dir=src/binutils
	echo '$(linux_headers_name)' >> state/package-version
	$(TOP_DIR)/scripts/unpack-tarball.sh --tarball-path=$(ARCHIVE_DIR)/$(linux_headers_tarball) --tarball-unpack-dir=$(linux_headers_name) --src-dir=src/linux
	echo '$(gmp_name)' >> state/package-version
	$(TOP_DIR)/scripts/unpack-tarball.sh --tarball-path=$(ARCHIVE_DIR)/$(gmp_tarball) --tarball-unpack-dir=$(gmp_name) --src-dir=src/gcc/gmp	
	echo '$(mpfr_name)' >> state/package-version
	$(TOP_DIR)/scripts/unpack-tarball.sh --tarball-path=$(ARCHIVE_DIR)/$(mpfr_tarball) --tarball-unpack-dir=$(mpfr_name) --src-dir=src/gcc/mpfr
	echo '$(mpc_name)' >> state/package-version
	$(TOP_DIR)/scripts/unpack-tarball.sh --tarball-path=$(ARCHIVE_DIR)/$(mpc_tarball) --tarball-unpack-dir=$(mpc_name) --src-dir=src/gcc/mpc
	echo '$(isl_name)' >> state/package-version
	$(TOP_DIR)/scripts/unpack-tarball.sh --tarball-path=$(ARCHIVE_DIR)/$(isl_tarball) --tarball-unpack-dir=$(isl_name) --src-dir=src/gcc/isl
	echo '$(gettext_name)' >> state/package-version
	$(TOP_DIR)/scripts/unpack-tarball.sh --tarball-path=$(ARCHIVE_DIR)/$(gettext_tarball) --tarball-unpack-dir=$(gettext_name) --src-dir=src/gcc/gettext
	echo '$(gcc_name)' >> state/package-version
	$(TOP_DIR)/scripts/unpack-tarball.sh --tarball-path=$(ARCHIVE_DIR)/$(gcc_tarball) --tarball-unpack-dir=$(gcc_name) --src-dir=src/gcc
	echo '$(glibc_name)' >> state/package-version
	$(TOP_DIR)/scripts/unpack-tarball.sh --tarball-path=$(ARCHIVE_DIR)/$(glibc_tarball) --tarball-unpack-dir=$(glibc_name) --src-dir=src/glibc

.PHONY: unpack
unpack: state/unpack.result

state/patch.result: state/unpack.result toolchain-patch.sh
	$(TOP_DIR)/scripts/patch-src-dir.sh --src-dir=src --patch-script=toolchain-patch.sh

.PHONY: patch
patch: state/patch.result

.PHONY: config reconfig
config: state/config.result

state/config.result reconfig $(builddir): state/patch.result
	rm -f state/config.result
	mkdir -p $(builddir)
	(cd $(builddir) && ../toolchain-configure.sh --archive-dir=$(ARCHIVE_DIR) --prefix=$(NXFS_TOOLCHAIN_PREFIX) --target=$(TARGET) --binutils=$(binutils_tarball) --linux-headers=$(linux_headers_tarball) --gmp=$(gmp_tarball) --mpfr=${mpfr_tarball} --mpc=${mpc_tarball} --isl=${isl_tarball} --gettext=${gettext_tarball} --gcc=${gcc_tarball} --glibc=${glibc_tarball} --max-jobs=$(NXFS_MAX_JOBS))
	cp -f state/patch.result state/config.result


state/compile.result: state/config.result
	($(THIS_DIR)/tools/build.sh 2>&1) | tee log/compile.log

.PHONY: compile
compile: state/compile.result $(builddir)

# provides targets:
# - state/install.mk
# - install
#
# these will be no-ops;  install done in compile step
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

