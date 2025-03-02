BEGIN {} END {
    sort = "sort -u -t. -k 1,1 -k 2n,2n -k 3";
    printf "%s", "foo bar quux" | sort;
    close(sort)
}
