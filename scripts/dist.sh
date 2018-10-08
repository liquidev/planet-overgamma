#!/bin/bash

echo preparing for distribution
rm -rf dist
mkdir dist
echo love archive
mkdir temp
cp -r * temp
cd temp
rm -rf temp
rm -rf love
rm -rf scripts
rm -rf dist
ls
zip -9 -r ../dist/spamality.love .
cd ..
rm -rf temp
echo windows executable
cat love/love.exe dist/spamality.love > dist/spamality.exe
cp love/* dist
rm dist/love.exe
rm dist/lovec.exe
echo done
