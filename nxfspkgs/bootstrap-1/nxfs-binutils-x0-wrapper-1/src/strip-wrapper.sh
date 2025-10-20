#! @bash@
#
# Script to provide a version of strip
#
# For nix we need to keep comments and .note.GNU-stack
#

binutils=@binutils@

extraBefore=()

# TODO: honor $dontStripSections flag

# these sections keep important metadata
# that nix needs to identify dependencies
#
extraBefore+=("--keep-section=.comment")
extraBefore+=("--keep-section=.note.GNU-stack")

exec ${binutils}/bin/strip "${extraBefore[@]}" "$@"
