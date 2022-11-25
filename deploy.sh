#!/bin/bash
set -e

URL=$1

for buildpath in .pio/build/*/ ; do
    echo ; echo
    echo "Uploading ..... $buildpath"

    name=$(basename $buildpath)
    binpath=$(ls $buildpath/firmware.bin)
    remotepath=$URL/$name.bin

    curl -T $binpath $remotepath
    curl -O $remotepath
    diff $name.bin $binpath

    gzip -kf $binpath
    curl -T $binpath.gz $remotepath.gz
    curl -O $remotepath.gz
    diff $name.bin.gz $binpath.gz
done
