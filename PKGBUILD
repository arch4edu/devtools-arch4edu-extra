pkgname=devtools-alarm-extra
pkgver=3.e2c0d17
pkgrel=1
pkgdesc='Extra tools for Arch Linux ARM package maintainers'
arch=('any')
url='http://github.com/petronny/devtools-alarm-extra'
license=('GPL')
depends=('archlinuxarm-keyring' 'devtools-alarm')
makedepends=('git')
source=('git+https://github.com/petronny/devtools-alarm-extra.git')
sha256sums=('SKIP')

pkgver() {
  cd "$srcdir/$pkgname"
  echo "$(git rev-list --count master).$(git rev-parse --short master)"
}

package() {
  mkdir -p $pkgdir/usr/bin
  mkdir -p $pkgdir/usr/share/devtools

  for i in armv6h armv7h aarch64
  do
    cp $srcdir/$pkgname/pacman-extra-$i.conf $pkgdir/usr/share/devtools/
    cp $srcdir/$pkgname/makepkg-$i.conf $pkgdir/usr/share/devtools/
    ln -sf /usr/bin/archbuild $pkgdir/usr/bin/extra-$i-build
  done
}
