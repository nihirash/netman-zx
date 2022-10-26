#!/bin/bash
VERSION=$(expr "$(cat version.def)" + 1)
echo $VERSION >version.def

TARGETS=("zxuno" "ay")
rm -rf release
mkdir release

prepare() {
    target=$1
    mkdir release/netman
    make clean
    make $target

    cp NETMAN.BAS release/netman/netman.bas
    cp netman.cod release/netman/
    (cd release && zip -r $target.zip netman/ && rm -rf netman)
}

for t in ${TARGETS[*]}
do
    echo "Building $t"
    prepare $t
done
