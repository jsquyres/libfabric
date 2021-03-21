#!/bin/bash

check() {
    a=$1

    if test -n "`echo "$a" | grep secret`"; then
        echo "yow: it has the word secret!"
    fi
    if test -n "`echo "$a" | grep jsquyres`"; then
        echo "yow: it has the word jsquyres!"
    fi
    if test -n "`echo "$a" | grep ecc`"; then
        echo "yow: it has the word ecc!"
    fi
}

echo yow: this is env val: $VAL
check $VAL

arg=$1
echo yow: this is arg: $arg
check $arg
