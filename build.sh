#!/usr/bin/env sh

echo "Cleaning out old artifacts"
rm -rf docs
mkdir docs

echo "Generating new site"
dart run build_runner build --release --output web:docs
cp CNAME docs/CNAME
touch docs/.nojekyll

echo "Removing build cruft"
rm -rf docs/packages
rm docs/.build.manifest
rm -rf docs/.dart_tool
rm docs/.packages

echo "Finished generating site into docs/"
echo "Push to Github to deploy"
