# npm2archOBS

Convert npm packages into a PKGBUILD for Arch Linux integration. This project is a fork of the [`npm2arch` project of Filirom1](https://github.com/Filirom1/npm2arch), the main distinguishing characteristic of this fork is that there are some additional commands. Namely:

* [`npm2OBS`](https://github.com/fusion809/npm2archOBS/blob/master/bin/npm2OBS) &mdash; which generates an Open Build Service (OBS)-friendly PKGBUILD for the package in question. What this means is that the package does not require an Internet connection to build as it does not call `npm` to install the package. Instead all the package's NPM dependencies are listed in the `depends` array.
* [`npm2OBSIT`](https://github.com/fusion809/npm2archOBS/blob/master/bin/npm2OBSIT) &mdash; this is like `npm2OBS`, except it also adds all the package's NPM dependencies to the OBS too. 

## Install
### From AUR :
yaourt -S [nodejs-npm2arch](https://aur.archlinux.org/packages/nodejs-npm2arch/)


### From sources

    git clone https://github.com/Filirom1/npm2arch
    cd npm2arch
    [sudo] npm install -g


Usage
-----

### npm2PKGBUILD

Transform an npm package into an ArchLinux PKGBUILD

    npm2PKGBUILD `npm-name` > PKGBUILD
    makepkg
    pacman -U nodejs-`name`-`version`-any.pkg.tar.xz


### npm2aurball

Transform an npm package into an AUR tarball using `mkaurball`

    npm2aurball `npm-name`


### npm2archpkg

Transform an npm package into an ArchLinux package archive

    npm2archpkg `npm-name`
    pacman -U nodejs-`name`-`version`-any.pkg.tar.xz


### npm2archinstall

Install an npm package with pacman

    npm2archinstall `npm-name`


License
-------

npm2arch is licensed under the [MIT License](https://github.com/fusion809/npm2archOBS/blob/master/LICENSE).
