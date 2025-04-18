#! /bin/sh
#
# copied from debianutils

set -ef

SILENT=0
if test -n "$KSH_VERSION"; then
    puts() {
                [ "$SILENT" -eq 1 ] && return
        print -r -- "$*"
    }
else
    puts() {
                [ "$SILENT" -eq 1 ] && return
        printf '%s\n' "$*"
    }
fi

ALLMATCHES=0

while getopts as whichopts
do
        case "$whichopts" in
                a) ALLMATCHES=1 ;;
                s) SILENT=1 ;;
                ?) puts "Usage: $0 [-as] args"; exit 2 ;;
        esac
done
shift $(($OPTIND - 1))

if [ "$#" -eq 0 ]; then
 ALLRET=1
else
 ALLRET=0
fi
case $PATH in
    (*[!:]:) PATH="$PATH:" ;;
esac
for PROGRAM in "$@"; do
 RET=1
 IFS_SAVE="$IFS"
 IFS=:
 case $PROGRAM in
  */*)
   if [ -f "$PROGRAM" ] && [ -x "$PROGRAM" ]; then
    puts "$PROGRAM"
    RET=0
   fi
   ;;
  *)
   for ELEMENT in $PATH; do
    if [ -z "$ELEMENT" ]; then
     ELEMENT=.
    fi
    if [ -f "$ELEMENT/$PROGRAM" ] && [ -x "$ELEMENT/$PROGRAM" ]; then
     puts "$ELEMENT/$PROGRAM"
     RET=0
     [ "$ALLMATCHES" -eq 1 ] || break
    fi
   done
   ;;
 esac
 IFS="$IFS_SAVE"
 if [ "$RET" -ne 0 ]; then
  ALLRET=1
 fi
done

exit "$ALLRET"
