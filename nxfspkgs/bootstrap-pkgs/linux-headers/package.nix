{
  stdenv
} :

let
  version = "6.12.49";
  version_major = "6";
  tarball = "linux-${version}.tar.xz";
in

stdenv.mkDerivation {
  name = "linux-headers";
  version = version;
  version_major = version_major;

  # NOTE: using builtins.fetchTarball instead of builtins.fetchurl
  #       because we don't have stage1 xz program available

  src = builtins.fetchTarball {
    url = "https://www.kernel.org/pub/linux/kernel/v${version_major}.x/${tarball}";
    sha256 = "sha256:0nxbwcyb1shfw9s833agk32zh133xzqxpw7j4fzdskzl1x65jaws";
  };

  buildPhase = ''
    #set -x

    src2=$TMPDIR/src2
    mkdir -p $src2

    (cd $src && (tar cf - . | tar xf - -C $src2))

    chmod -R +w $src2

    # headers_install: this form requires rsync.
    # We don't have that at this point in bootstrap.
    #make -C $src2 ARCH=x86 INSTALL_HDR_PATH=$out headers_install

    pushd $src2

    make mrproper
    make headers

    # delete everything except header files
    find usr/include -type f ! -name '*.h' -delete

    cp -rv usr/include $out
  '';
}
