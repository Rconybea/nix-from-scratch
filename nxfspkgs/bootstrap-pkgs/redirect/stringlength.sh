stringlength() {
    echo ${#1}
}

padding() {
    old=$1
    new=$2

    echo $((${#old} - ${#new}))
}

padwith() {
    old=$1
    new=$2
    with=$3

    printf '%*s' $((${#old} - ${#new})) ${with}
}
