#!/bin/bash

echo preparing for distribution
rm -rf dist
mkdir dist
echo love archive
zip -9 -r dist/spamality.love .
echo windows executable
cat love/love.exe dist/spamality.love > dist/spamality.exe
cp love/* dist
rm dist/love.exe
rm dist/lovec.exe
echo done
