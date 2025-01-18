#! ${bash}

set -e

PATH=
for pkg in $buildInputs; do
    if [[ -d ${pkg}/bin ]]; then
        if [[ -n $PATH ]]; then
            PATH+=":"
        fi
        PATH+=${pkg}/bin
    fi
done

echo "PATH=$PATH"

mkdir $out

# note: nothing canonical going on here.
#
# We're creating a bunch of symlinks just to show that builder
# sees that dependency.
#
for pkg in $buildInputs; do
    name=$(basename $pkg)
    ln -sf $pkg $out/$name
done

echo "stage1 complete" > $out/success.txt
