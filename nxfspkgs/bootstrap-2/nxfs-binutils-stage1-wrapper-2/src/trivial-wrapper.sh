#! @bash@
#
# nxfs wrapper for @prog@
#
# In this case just passthru

binutils=@binutils@

exec ${binutils}/bin/@prog@ "$@"
