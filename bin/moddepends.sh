#!/bin/bash
if [[ -n $1 ]]; then
  sed -i -e "s/depends=('nodejs')/depends=($1)/g" $2/$3/PKGBUILD
fi