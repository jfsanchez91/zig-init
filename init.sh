#!/bin/sh

name=$PROJECT_NAME
if [ -z "$name" ]; then
  echo "Usage: $0 <project-name>"
  exit 1
fi
if [ -d "$name" ]; then
  echo "Directory $name already exists. Please choose a different name."
  exit 1
fi

echo "Starting a new clean Zig project at $name ..."
git clone --depth=1 https://github.com/jfsanchez91/zig-init.git $name
if [ ! -d "$name/.git" ]; then
  echo "Error: Failed to clone the repository."
  exit 1
fi

echo "Updating build.zig ..."
sed -i "s/{{__NAME__}}/$name/g" $name/build.zig

echo "Updating build.zig.zon ..."
sed -i "s/{{__NAME__}}/$name/g" $name/build.zig.zon
fingerprint=$(cd $name && zig build 2>&1 | grep -o "0x[0-9a-fA-F]\{16\}" | grep -v "^0xb111111111111111$")
echo "Relplacing fingerprint with new value: $fingerprint ..."
sed -i "s/0xb111111111111111/$fingerprint/g" $name/build.zig.zon

echo "Cleaning README.md ..."
echo -e "# $name\n" > $name/README.md

echo "Cleaning up ..."
rm -rf $name/.git/
rm -rf $name/.zig-cache/
rm $name/init.sh
