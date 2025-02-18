#!/bin/bash

set -eu

root="$1"
date="$2"

FILES=()
trap 'touch -t "$date" "${FILES[@]}"' EXIT

rm -rf "$root"
mkdir "$root"
FILES+=("$root")

d()
{
    mkdir "$root/$1"
    FILES+=("$root/$1")
}

f()
{
    echo "$2" > "$root/$1"
    FILES+=("$root/$1")
}

f README.md "A set of files to test minitar"
d src
f src/main.c "# nothing important"
d lib
d lib/data
f lib/data/big.txt "$(yes 'a large file' | head -n 1000000)"
