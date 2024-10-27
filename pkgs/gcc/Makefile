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

version:=14.2.0
# unique package name
name:=gcc-$(version)
# local directory for unpacked source
unpackdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.xz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
url:=https://ftp.gnu.org/gnu/gcc/$(name)/$(tarball)
# verify this sha
sha256:=a7b39bc69cbf9e25826c5a60ab26477001f7c08d85cec04bc0e29cabed6f3cc9
# Settings CFLAGS seems to break the flex configure script;
# complains that it can't invoke gcc.
cflags:=-I$(PREFIX)/include
ldflags:=-L$(PREFIX)/lib -Wl,-rpath,$(PREFIX)/lib
#
srcdir:=src
builddir:=build
#
post_unpack_script:=$(THIS_DIR)/gcc-post-unpack.sh --archive-dir=$(ARCHIVE_DIR) --src-dir=$(srcdir) --gmp=gmp-6.3.0.tar.xz --mpc=mpc-1.3.1.tar.gz --mpfr=mpfr-4.2.1.tar.xz
patch_script:=gcc-patch.sh
#
# stage1 build.  don't need everything, keeping just what we need to bootstrap glibc
#
# not setting --target yet
# --target: if doesn't match config.gues (I think)
#           so that binutils build prepares for a cross linker
#
configure_extra_args:=--prefix=$(PREFIX)/stage1 --with-glibc-version=2.40 --with-sysroot=$(PREFIX) --with-newlib --without-headers --enable-default-pie --enable-default-ssp --disable-nls --disable-shared --disable-multilib --disable-threads --disable-libatomic --disable-libgomp --disable-libquadmath --disable-libssp --disable-libvtv --disable-libstdcxx --enable-languages=c,c++

post_install_hook:=

all: compile

include $(TOP_DIR)/mk/buildphases.mk

