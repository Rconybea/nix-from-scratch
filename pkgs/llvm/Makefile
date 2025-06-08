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

version_major:=18
version:=$(version_major).1.7
# unique package name
name1:=llvm-$(version)
name2:=llvm-cmake-$(version_major)
name3:=llvm-third-party-$(version_major)
name4:=clang-$(version)
name:=$(name1)
# local directory for unpacked source
unpackdir1:=$(name1).src
unpackdir2:=$(name2).src
unpackdir3:=$(name3).src
unpackdir4:=$(name4).src
# unique tarball name (in ARCHIVE_DIR)
tarball1:=$(name1).src.tar.xz
tarball2:=$(name2).src.tar.xz
tarball3:=$(name3).src.tar.xz
tarball4:=$(name4).src.tar.xz
# full path to local tarball
tarball_path1:=$(ARCHIVE_DIR)/$(tarball1)
tarball_path2:=$(ARCHIVE_DIR)/$(tarball2)
tarball_path3:=$(ARCHIVE_DIR)/$(tarball3)
tarball_path4:=$(ARCHIVE_DIR)/$(tarball4)
# obtain tarball by fetching from these urls 
# 1: llvm
# 2: cmake modules for llvm
# 3: 3rd party deps for llvm build system (?)
url1:=https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/$(tarball1)
url2:=https://anduin.linuxfromscratch.org/BLFS/llvm/$(tarball2)
url3:=https://anduin.linuxfromscratch.org/BLFS/llvm/$(tarball3)
url4:=https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/$(tarball4)
# verify this sha
sha256_1:=17ba3d57c3db185722c36e736a189b2110e8cb842cc9e53dcc74e938bdadb97e
sha256_2:=857fb826ee0e159cb1ad282790c6613e55048bd9ecb3248940689d48cbe9da96
sha256_3:=ceb38dabc7250a3cda53fd81978d0f1b7aeaa8a3a055d5a336892665609b0f11
sha256_4:=c9191e4896e43425a8fbbb29e3b25b3a83050781809fbd4d0ad2382bc4a5c43d
#
# {cflags,ldflags} won't work when configure_script=cmake
cflags:=-I$(PREFIX)/include
ldflags:=-L$(PREFIX)/lib -Wl,-rpath,$(PREFIX)/lib
#
patch_script:=./llvm-patch.sh
srcdir:=src
builddir:=build
pre_configure_hook:=
# reminder: configure runs in build directory
configure_exec:=cmake
configure_script:=
configure_extra_args:=-DCMAKE_INSTALL_PREFIX=$(PREFIX) -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_RPATH=$(PREFIX)/lib -DLLVM_ENABLE_FFI=ON -DLLVM_BUILD_LLVM_DYLLIB=ON -DLLVM_LINK_LLVM_DYLIB=ON -DLLVM_ENABLE_RTTI=ON -DLLVM_TARGETS_TO_BUILD='host;AMDGPU' -DLLVM_BINUTILS_INCDIR=$(PREFIX)/include -DLLVM_INCLUDE_BENCHMARKS=OFF -DCLANG_DEFAULT_PIE_ON_LINUX=ON -DCLANG_CONFIG_FILE_SYSTEM_DIR=$(PREFIX)/etc/clang -Wno-dev "-DCMAKE_CXX_FLAGS=-I$(PREFIX)/include" "-DCMAKE_SHARED_LINKER_FLAGS=-L$(PREFIX)/lib" -B . -S ../$(srcdir)
post_install_hook:=

all: compile

# ----- fetch ----------------------------------------------------------------

# need 4 tarballs here.

$(tarball_path1) state/fetch.result1:
	$(TOP_DIR)/scripts/init.sh --archive-dir=$(ARCHIVE_DIR)
	$(TOP_DIR)/scripts/fetch-tarball.sh --archive-dir=$(ARCHIVE_DIR) --url=$(url1) --tarball-path=$(tarball_path1) --fetchresult=state/fetch.result1 "--fetch-extra-args=${fetch_extra_args}"

$(tarball_path2) state/fetch.result2:
	$(TOP_DIR)/scripts/init.sh --archive-dir=$(ARCHIVE_DIR)
	$(TOP_DIR)/scripts/fetch-tarball.sh --archive-dir=$(ARCHIVE_DIR) --url=$(url2) --tarball-path=$(tarball_path2) --fetchresult=state/fetch.result2 "--fetch-extra-args=${fetch_extra_args}"

$(tarball_path3) state/fetch.result3:
	$(TOP_DIR)/scripts/init.sh --archive-dir=$(ARCHIVE_DIR)
	$(TOP_DIR)/scripts/fetch-tarball.sh --archive-dir=$(ARCHIVE_DIR) --url=$(url3) --tarball-path=$(tarball_path3) --fetchresult=state/fetch.result3 "--fetch-extra-args=${fetch_extra_args}"

$(tarball_path4) state/fetch.result4:
	$(TOP_DIR)/scripts/init.sh --archive-dir=$(ARCHIVE_DIR)
	$(TOP_DIR)/scripts/fetch-tarball.sh --archive-dir=$(ARCHIVE_DIR) --url=$(url4) --tarball-path=$(tarball_path4) --fetchresult=state/fetch.result4 "--fetch-extra-args=${fetch_extra_args}"

.PHONY: fetch1 fetch2
fetch1: $(tarball_path1) state/fetch.result1
fetch2: $(tarball_path2) state/fetch.result2
fetch3: $(tarball_path3) state/fetch.result3
fetch4: $(tarball_path4) state/fetch.result4

state/fetch.result: state/fetch.result1 state/fetch.result2 state/fetch.result3 state/fetch.result4
	cat state/fetch.result[1-4] > state/fetch.result

.PHONY: fetch
fetch: fetch1 fetch2 fetch3 fetch4 state/fetch.result

# ----- verify ----------------------------------------------------------------

# WARNING: not threadsafe

sha256_1 state/expected.sha256_1: state/fetch.result1
	$(TOP_DIR)/scripts/require-sha256.sh --sha256=$(sha256_1) --tarball-path=$(tarball_path1)

state/verify.result1: state/expected.sha256_1
	make sha256_1
	$(TOP_DIR)/scripts/verify-sha256.sh --verifyresult=state/verify.result1

# ----------------------------------------------------------------

sha256_2 state/expected.sha256_2: state/fetch.result2
	$(TOP_DIR)/scripts/require-sha256.sh --sha256=$(sha256_2) --tarball-path=$(tarball_path2)

state/verify.result2: state/expected.sha256_2
	make sha256_2
	$(TOP_DIR)/scripts/verify-sha256.sh --verifyresult=state/verify.result2

# ----------------------------------------------------------------

sha256_3 state/expected.sha256_3: state/fetch.result3
	$(TOP_DIR)/scripts/require-sha256.sh --sha256=$(sha256_3) --tarball-path=$(tarball_path3)

state/verify.result3: state/expected.sha256_3
	make sha256_3
	$(TOP_DIR)/scripts/verify-sha256.sh --verifyresult=state/verify.result3

# ----------------------------------------------------------------

sha256_4 state/expected.sha256_4: state/fetch.result4
	$(TOP_DIR)/scripts/require-sha256.sh --sha256=$(sha256_4) --tarball-path=$(tarball_path4)

state/verify.result4: state/expected.sha256_4
	make sha256_4
	$(TOP_DIR)/scripts/verify-sha256.sh --verifyresult=state/verify.result4

# ----------------------------------------------------------------

.PHONY: verfy1 verify2 verify3 verify4
verify1: state/verify.result1
verify2: state/verify.result2
verify3: state/verify.result3
verify4: state/verify.result4

state/verify.result: state/verify.result1 state/verify.result2 state/verify.result3 state/verify.result4
	cat state/verify.result[1-4] > state/verify.result

.PHONY: verify
verify: verify1 verify2 verify3 verify4 state/verify.result

# ----- unpack ----------------------------------------------------------------

# everything unpacks into the same directory
state/unpack.result: state/verify.result
	echo $(name) > state/package-version
	$(TOP_DIR)/scripts/unpack-tarball.sh --tarball-path=$(tarball_path1) --tarball-unpack-dir=$(unpackdir1) --src-dir=${srcdir} --unpack-exec=$(unpack_exec) --unpack-args=$(unpack_args)
	$(TOP_DIR)/scripts/unpack-tarball.sh --tarball-path=$(tarball_path2) --tarball-unpack-dir=$(unpackdir2) --src-dir=${srcdir}/$(unpackdir2) --unpack-exec=$(unpack_exec) --unpack-args=$(unpack_args)
	$(TOP_DIR)/scripts/unpack-tarball.sh --tarball-path=$(tarball_path3) --tarball-unpack-dir=$(unpackdir3) --src-dir=${srcdir}/$(unpackdir3)
	$(TOP_DIR)/scripts/unpack-tarball.sh --tarball-path=$(tarball_path4) --tarball-unpack-dir=$(unpackdir4) --src-dir=${srcdir}/tools/clang

.PHONY: unpack
unpack: state/unpack.result

# ----- patch ----------------------------------------------------------------

# runs $(patch_script)
include $(TOP_DIR)/mk/patch.mk

# ----- configure ------------------------------------------------------------

include $(TOP_DIR)/mk/configure.mk

# ----- compile --------------------------------------------------------------

include $(TOP_DIR)/mk/compile.mk

# ----- install --------------------------------------------------------------

include $(TOP_DIR)/mk/install.mk

