.PHONY: all
all:
	(cd @SRCDIR@ && make)

install:
	(cd @SRCDIR@ && make install)
	(cd @SRCDIR@ && make install_static)
	(cd @SRCDIR@ && make install_shared)
