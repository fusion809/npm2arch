#!/usr/bin/env coffee

# This library converts the npm package into a PKGBUILD compatible with the
# Open Build Service (OBS)
npm      = require 'npm'
mustache = require 'mustache'
fs       = require 'fs'

# transform pkg.json of `npmName` into a PKGBUILD
# `cb` is called like this: `cb(err, pkgbuild)`
module.exports = (npmName, options, cb) ->

  if typeof options is 'function'
    cb = options
    options = null

  options or= {}

  # Execute npm info `argv[0]`
  npm.load loglevel:'silent', (er)->
    return cb(er) if er
    npm.commands.view [npmName], true, (er, json) ->
      return cb(er) if er
      parseNPM json

  # Parse the info json
  parseNPM = (data) ->
    version = Object.keys(data)[0]
    pkg = data[version]
    pkg = cleanup pkg
    pkg.nameLowerCase = pkg.name.toLowerCase()
    pkg.homepage or= pkg.url
    pkg.homepage or= pkg.repository.url.replace(/^git(@|:\/\/)/, 'http://').replace(/\.git$/, '').replace(/(\.\w*)\:/g, '$1\/') if pkg.repository?.url
    pkg.depends = options.depends
    pkg.optdepends = options.optdepends?.map (o)->
      key = (Object.keys o)[0]
      value = o[key]
      return "#{key}: #{value}"
    pkg.archVersion = pkg.version.replace(/-/, '_')
    populateTemplate pkg

  # Populate the template
  populateTemplate = (pkg) ->
    cb null, mustache.to_html(template, pkg)

template = '''_npmname={{{name}}}
_npmver={{{version}}}
pkgname=nodejs-{{{nameLowerCase}}}
pkgver={{{archVersion}}}
pkgrel=1
pkgdesc=\"{{{description}}}\"
arch=(any)
url=\"{{{homepage}}}\"
license=('MIT')
depends=('nodejs')
source=(http://registry.npmjs.org/$_npmname/-/$_npmname-$_npmver.tgz)
sha1sums=({{#dist}}{{{shasum}}}{{/dist}})

package() {
  cd $srcdir
  _npmdir="$pkgdir/usr/lib/node_modules/$_npmname"
  mkdir -p $_npmdir
  cp -a $srcdir/package/* $_npmdir
  if [[ -d "$pkgdir/usr/lib/node_modules/$_npmname/bin" ]]; then
    BIN=$pkgdir/usr/bin
    mkdir -p $BIN
    cd $BIN
    for i in "../lib/node_modules/$_npmname/bin/"*
    do
      L="${i##*/}"
      K="${L%.*}"
      if [[ "$L" == "$K" ]]; then
        echo "Creating binary $L"
        ln -s $i $L
      fi
    done
  fi
  if [[ -f "$_npmdir/LICENSE" ]]; then
    mkdir -p $pkgdir/usr/share/licenses/$pkgname
    install -m644 "$_npmdir/LICENSE" "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
  elif [[ -f "$_npmdir/license" ]]; then
    mkdir -p $pkgdir/usr/share/licenses/$pkgname
    install -m644 "$_npmdir/license" "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
  elif [[ -f "$_npmdir/LICENSE.md" ]]; then
    mkdir -p $pkgdir/usr/share/licenses/$pkgname
    install -m644 "$_npmdir/LICENSE.md" "$pkgdir/usr/share/licenses/$pkgname/LICENSE.md"
  elif [[ -f "$_npmdir/LICENSE.txt" ]]; then
    mkdir -p $pkgdir/usr/share/licenses/$pkgname
    install -m644 "$_npmdir/LICENSE.txt" "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
  elif [[ -f "$_npmdir/LICENCE" ]]; then
    mkdir -p $pkgdir/usr/share/licenses/$pkgname
    install -m644 "$_npmdir/LICENCE" "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
  fi
}'''

# From NPM sources
`function cleanup (data) {
  if (Array.isArray(data)) {
    if (data.length === 1) {
      data = data[0]
    } else {
      return data.map(cleanup)
    }
  }
  if (!data || typeof data !== "object") return data

  if (typeof data.versions === "object"
      && data.versions
      && !Array.isArray(data.versions)) {
    data.versions = Object.keys(data.versions || {})
  }

  var keys = Object.keys(data)
  keys.forEach(function (d) {
    if (d.charAt(0) === "_") delete data[d]
    else if (typeof data[d] === "object") data[d] = cleanup(data[d])
  })
  keys = Object.keys(data)
  if (keys.length <= 3
      && data.name
      && (keys.length === 1
          || keys.length === 3 && data.email && data.url
          || keys.length === 2 && (data.email || data.url))) {
    data = unparsePerson(data)
  }
  return data
}
function unparsePerson (d) {
  if (typeof d === "string") return d
  return d.name
       + (d.email ? " <"+d.email+">" : "")
       + (d.url ? " ("+d.url+")" : "")
}`
