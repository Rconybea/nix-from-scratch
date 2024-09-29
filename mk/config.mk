# Require:
# - including makefile provides TOP_DIR.
#
# Note: included in both toplevel Makefile ($(TOP_DIR)/Makefile)
#       and per-package Makefiles ($(TOP_DIR)/pkgs/foo/Makefile)
#   

ARCHIVE_DIR:=$(TOP_DIR)/archive

# Prefix directory for build artifacts constructed by the nix-from-scratch project.
#
# To use installed-by-nix-from-scratch binaries, want:
# 1. $PREFIX/bin in $PATH
# 2. $PREFIX/share/man in $MANPATH
#
# To compile programs/libraries using artifacts from installed-by-nix-from-scratch binaries, want:
# 3. $PREFIX/lib/pkgconfig, $PREFIX/share/pkgconfig in $PKG_CONFIG_PATH
#    (for a build using pkg-config to get build ingredients for other components)
# 4. $PREFIX/share/cmake in $CMAKE_MODULE_PATH
#    (for a build using cmake to get cmake modules for dependent components)
#
# provides PREFIX;  set from ./bootstrap.sh
include prefix.mk
export PREFIX

# ----------------------------------------------------------------
# Unlikely to need to change anything below this line
# ----------------------------------------------------------------

PATH:=$(PREFIX)/bin:$(PATH)
export PATH

PKG_CONFIG_PATH:=$(PREFIX)/lib/pkgconfig:$(PREFIX)/share/pkgconfig
export PKG_CONFIG_PATH


