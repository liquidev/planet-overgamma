#!/bin/bash

echo preparing for distribution
rm -rf dist_*
mkdir dist_win
mkdir dist_linux
echo love archive
mkdir temp
cp -r * temp
cd temp
rm -rf temp
rm -rf love
rm -rf scripts
rm -rf dist
ls
zip -9 -r ../dist_win/planet-overgamma.love .
cd ..
rm -rf temp
echo windows executable
cat love/love.exe dist_win/planet-overgamma.love > dist_win/planet-overgamma.exe
cp love/* dist_win
rm dist_win/love.exe
rm dist_win/lovec.exe
echo done
