.PHONY: all install

all:
	(cd ../@SRCDIR@ && export LD_RUN_PATH=@PREFIX@/lib && ./b2 stage -j1 threading=multi link=shared)

install:
	(cd ../@SRCDIR@ && ./b2 install threading=multi link=shared)
