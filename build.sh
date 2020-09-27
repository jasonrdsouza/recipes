#!/usr/bin/env sh

echo "Cleaning out old artifacts"
rm -rf docs
mkdir docs

echo "Generating new site"
pub run build_runner build --release --output web:docs
cp CNAME docs/CNAME
touch docs/.nojekyll
rm -rf docs/packages

echo "Finished generating site into docs/"
echo "Push to Github to deploy"
