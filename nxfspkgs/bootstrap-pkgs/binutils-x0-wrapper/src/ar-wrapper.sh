#! @bash@
#
# Script to provide a version of ar
#
# Main thing we want to do is interpose the D flag to get determinstic archive
#

binutils=@binutils@

extraBefore=()
extraBefore+=("D")

exec ${binutils}/bin/ar "${extraBefore[@]}" "$@"
