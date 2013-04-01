#!/bin/sh

# Based on https://github.com/OneGameAMonth/Rogue-Beach-CA/blob/master/build.sh
# Configure this, and also ensure you have the build/osx.patch ready.
NAME="115-1gam-johnwatson"
SHORTNAME="115"

# Version is {last tag}-{commits since last tag}.
# e.g: 0.1.2-3
REVISION=`git log --oneline | head -1 | awk '{ print $1 }'`

FILENAME="$NAME-$REVISION"
VERSION=0.8.0
BUILD="`pwd`/build"
mkdir -p "${BUILD}"

# Take HEAD make an archive of it
git archive HEAD -o "$BUILD/$FILENAME.zip"
echo "game = {}; game.version = '${REVISION}'" > "version.lua"

# Add the version file
zip -q "$BUILD/$FILENAME.zip" "version.lua"
mv "$BUILD/$FILENAME.zip" "$BUILD/$FILENAME.love"

GAME="$BUILD/$FILENAME.love"

echo "Building $FILENAME..."

# For windows, just append our love file and zip it
for arch in 'win-x86' 'win-x64'
do
  echo "    $arch..."

  # Unzip archive
  ARCHIVE="$BUILD/love-$VERSION-$arch"
  if [ -f "$BUILD/$ARCHIVE" ]; then rm -r "$BUILD/$ARCHIVE"; fi
  unzip -q -d "$BUILD" "$ARCHIVE.zip"
  
  # Append game to love.exe
  cat "$GAME" >> "$ARCHIVE/love.exe"

  # Rename love.exe
  mv "$ARCHIVE/love.exe" "$ARCHIVE/$SHORTNAME.exe"

  # Build zip
  mv "$ARCHIVE" "$BUILD/${FILENAME}_$arch"
  R_PWD=`pwd`
  cd "$BUILD"
  if [ -f "$BUILD/${FILENAME}_$arch.zip" ]; then rm "$BUILD/${FILENAME}_$arch.zip"; fi
  zip -q -r "$BUILD/${FILENAME}_$arch.zip" "${FILENAME}_$arch"
  rm -r "$BUILD/${FILENAME}_$arch"
  cd "$R_PWD"
done

echo "DONE"
