#!/bin/bash
mkdir -p "$1"/"nodejs-$2"
cd "$1"/"nodejs-$2"
npm2PKGBUILD "$2" > PKGBUILD
updpkgsums
