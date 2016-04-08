#!/bin/bash
if ! [[ -d "$1/nodejs-$2" ]]; then
  mkdir -p "$1"/"nodejs-$2"
fi
cd "$1"/"nodejs-$2"
if ! [[ -f PKGBUILD ]]; then
  npm2PKGBUILD "$2" > PKGBUILD
fi
if ! [[ -f src/package/package.json ]]; then
  updpkgsums
fi
