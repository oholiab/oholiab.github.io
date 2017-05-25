#!/bin/bash -x
ASSETPATH=$1
PARENT=$(dirname $ASSETPATH)
REMOTE=$2

mkdir -p "$PARENT"
pushd "$PARENT"
git clone $REMOTE
pushd "$ASSETPATH"
git annex get .
find . -type l -exec chmod 644 {} \;
