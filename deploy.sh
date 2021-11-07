#!/bin/bash
set -e

URL=$1

for path in .pio/build/*/ ; do
    name=$(basename $path)
    binpath=$(ls $path*.bin)
    remotepath=$URL/$name.bin

    curl -T $binpath $remotepath
    curl -O $remotepath
    diff $name.bin $binpath

    gzip -kf $binpath
    curl -T $binpath.gz $remotepath.gz
    curl -O $remotepath.gz
    diff $name.bin.gz $binpath.gz
done
