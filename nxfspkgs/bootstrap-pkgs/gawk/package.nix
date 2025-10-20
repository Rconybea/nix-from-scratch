{
  # stdenv :: derivation+attrset
  stdenv,
  # popen :: derivation
  popen,
  # stageid :: string  -- "2" for stage2, "3" for stage3
  stageid
} :

let
  version = "5.3.0";
in

stdenv.mkDerivation {
  name         = "nxfs-gawk-${stageid}";

  src          = builtins.fetchTarball { name = "gawk-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/gawk/gawk-${version}.tar.xz";
                                         sha256 = "03fsh86d3jbafmbhm1n0rx8wzsbvlfmpdscfx85dqx6isyk35sd9"; };

  outputs      = [ "out" "source" ];

  inherit popen;

  buildPhase = ''
    set -e

    src2=$TMPDIR/src2
    builddir=$TMPDIR/build

    mkdir -p $src2
    mkdir -p $builddir

    #mkdir $out
    mkdir $source

    # 1. copy source tree to temporary directory,
    #
    (cd $src && (tar cf - . | tar xf - -C $src2))
    chmod -R +w $src2

    # 2. substitute nix-store path-to-bash for /bin/sh.
    #
    shell_program=$shell

    # skipping:
    #   .m4 and .in files (assume they trigger re-running autoconf)
    #   test/ files
    #
    sed -i -e "s:/bin/sh:$shell_program:g" $src2/configure $src2/build-aux/*

    # The file io.c contains sveral calls like
    #   execl("/bin/sh", "sh", "-c", command, NULL)
    # rewrite these to
    #   execl("/path/to/nix/store/bash/bin/bash", "bash", "c", command, NULL)
    #
    sed -i -e 's:"/bin/sh", "sh":"'$shell_program'", "bash":' $src2/io.c

    # ----------------------------------------------------------------
    # nxfs_system()
    # ----------------------------------------------------------------

    # insert decl
    #    statc int nxfs_system(const char* line);
    # near the top of builtin.c
    #
    sed -i -e '/^static size_t mbc_byte_count/ i\
    static int nxfs_system(const char* line);\
    ' $src2/builtin.c

    nxfs_system_src=$popen/src/nxfs_system.c

    # use nxfs_system() instead of glibc system() to implement gawk's system() builtin
    #
    sed -i -e 's:status = system(cmd):status = nxfs_system(cmd):' $src2/builtin.c

    # add definition of nxfs_system() to builtin.c
    #
    cat $nxfs_system_src >> $src2/builtin.c

    # ----------------------------------------------------------------
    # nxfs_popen
    # ----------------------------------------------------------------

    # insert decl
    #   static FILE* nxfs_popen(char const* cmd, char const* mode);
    # near the top of io.c
    #
    sed -i -e '/^static int iop_close/ i\
    static FILE* nxfs_popen(char const* cmd, char const* mode);\
    static int nxfs_pclose(FILE* fp);\
    ' $src2/io.c

    nxfs_popen_src=$popen/src/nxfs_popen.c

    # use nxfs_popen() instead of glibc popen() to implement gawk's '|' builtin
    #
    sed -i -e "s: popen(: nxfs_popen(:" $src2/io.c
    sed -i -e "s:pclose(rp->output.fp):nxfs_pclose(rp->output.fp):" $src2/io.c
    sed -i -e "s:pclose(current):nxfs_pclose(current):" $src2/io.c
    sed -i -e "s:pclose(rp->ifp):nxfs_pclose(rp->ifp):" $src2/io.c

    # add definition of nxfs_popen() and nxfs_pclose() to io.c
    #
    cat $nxfs_popen_src >> $src2/io.c

    # ----------------------------------------------------------------

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$shell_program"

    # 1.
    # we shouldn't need special compiler/linker instructions,
    # since stage-1 toolchain "knows where it lives"
    #
    # 2.
    # do need to give --host and --build arguments to configure,
    # since we're using a cross compiler.

    # inspect shebang
    head -5 $src2/configure

    (cd $builddir && $src2/configure --prefix=$out CFLAGS= LDFLAGS="-Wl,-enable-new-dtags" SHELL=$CONFIG_SHELL)

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)

    (cd $src2 && (tar cvf - . | tar xf - -C $source))
    '';

  buildInputs = [ ];
}
