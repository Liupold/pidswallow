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

build_and_test(){
        pwd_="$(pwd)"
        pkgbuild_dir="$1"
        cd "$pkgbuild_dir" || return 1
        mkdir "build-test" && cd "build-test" || return 1
        cp ../PKGBUILD ./PKGBUILD
        yes | makepkg -si
        pidswallow -h || return 11
        cd ..  && rm -rf "build-test"
        cd "$pwd_" || return 2
}

build_and_test ./aur/stable
build_and_test ./aur/git
yes | sudo pacman -Rns pidswallow-dev-git
