pkgname=devtools-alarm-extra
pkgver=8.bc28f5b
pkgrel=1
pkgdesc='Extra tools for Arch Linux ARM package maintainers'
arch=('any')
url='http://github.com/arch4edu/devtools-alarm-extra'
license=('GPL')
depends=('archlinuxarm-keyring' 'devtools-alarm')
makedepends=('git')
source=("git+${url}.git")
sha256sums=('SKIP')

pkgver() {
  cd "$srcdir/$pkgname"
  echo "$(git rev-list --count makepkg).$(git rev-parse --short makepkg)"
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
