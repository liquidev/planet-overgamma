echo preparing for distribution
mkdir dist
echo love archive
zip -9 -r dist/spamality.love .
echo windows executable
cat dist/love.exe dist/spamality.love > dist/spamality.exe
echo done
