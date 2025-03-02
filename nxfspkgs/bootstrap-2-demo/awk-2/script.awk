#!/usr/bin/gawk -f

BEGIN {
    FS=";";
}

#{ cmd="echo"; system("echo " $1) | cmd; }


{
  command = "@sort_program@ -r "
  print $1 | command
}
