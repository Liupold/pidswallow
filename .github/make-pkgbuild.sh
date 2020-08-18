#!/bin/sh
version="$(cat ./version)"
echo "Deploy for version: $version on $(date)"

# make directory
mkdir -p ./aur/git ./aur/stable

# create PKGBUILDs
sed -e "s|{%version}|$version.d|g" ./aur/PKGBUILD.git.template \
        > ./aur/git/PKGBUILD
sed -e "s|{%version}|$version|g" ./aur/PKGBUILD.stable.template \
        > ./aur/stable/PKGBUILD

