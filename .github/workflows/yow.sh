#!/bin/bash

check() {
    a=$1

    if echo "$a" | grep secret; then
        echo "it has the word secret!"
    fi
    if echo "$a" | grep jsquyres; then
        echo "it has the word jsquyres!"
    fi
    if echo "$a" | grep ecc; then
        echo "it has the word ecc!"
    fi
}

echo yow: this is env val: $VAL
check $VAL

read in
echo yow: this is what I read from stdin: $in
check $in

arg=$1
echo yow: this is arg: $arg
check $ARG
