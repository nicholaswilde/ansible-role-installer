#!/usr/bin/env sh

# Credit to https://github.com/andrewrothstein

if ! [ -x "$(command -v yq)" ]; then
  echo "yq is not installed" >&2
  exit 1
fi

set -e
DIR=/tmp
APPNAME=$(yq r defaults/main.yaml bin_name)
NAMESPACE=$(yq r defaults/main.yaml namespace)
REPO=$(yq r defaults/main.yaml repo)
MIRROR=https://github.com/${NAMESPACE}/${REPO}/releases/download
VERSION=$(yq r defaults/main.yaml app_ver)

dl() {
    local ver=$1
    local os=$2
    local arch=$3
    local suffix=${4:-tar.gz}
    local platform="${os}_${arch}"
    local file="${APPNAME}_${ver}_${platform}.${suffix}"
    local url=$MIRROR/v$ver/$file
    local lfile=$DIR/$file

    if [ ! -e $lfile ]; then
        wget -q -O $lfile $url
    fi

    printf "    # %s\n" $url
    printf "    %s: sha256:%s\n" $platform $(sha256sum $lfile | awk '{print $1}')
}

dl_ver() {
    local ver=$1
    printf "  '%s':\n" $ver
    dl $ver darwin amd64 gz
    dl $ver linux 386 gz
    dl $ver linux amd64 gz
    dl $ver linux arm64 gz
    dl $ver linux armv6 gz
    dl $ver linux armv7 gz
    dl $ver windows 386 gz
    dl $ver windows amd64 gz
}

dl_ver ${1:-$VERSION}
