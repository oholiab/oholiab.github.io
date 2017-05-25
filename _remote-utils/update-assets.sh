#!/bin/bash -x
ASSETPATH=$1

pushd "$ASSETPATH"
git annex get .
find . -type l -exec chmod 644 {} \;
