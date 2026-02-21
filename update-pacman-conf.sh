#!/bin/sh
set -ex

cp keyrings/archlinuxarm* /usr/share/pacman/keyrings || :

arch="aarch64"
gpgdir=$arch/gnupg
cachedir=/var/cache/pacman/pkg/$arch

mkdir -p $arch/{db,root} $cachedir

echo [options] > $arch/pacman.conf
echo "Architecture = $arch" >> $arch/pacman.conf
echo "[core]" >> $arch/pacman.conf
echo "SigLevel = Required DatabaseOptional" >> $arch/pacman.conf
echo "Include = $(realpath mirrorlist)" >> $arch/pacman.conf

# Enable all mirrors (uncomment any line starting with #Server or # Server)
sed -i 's/^#[[:space:]]*Server[[:space:]]*=/Server =/' mirrorlist

pacman-key --config $arch/pacman.conf --gpgdir $gpgdir --init
pacman-key --config $arch/pacman.conf --gpgdir $gpgdir --populate archlinuxarm

pacman -Sy --config $arch/pacman.conf --dbpath $arch/db --gpgdir $gpgdir
pacman -Sdd --config $arch/pacman.conf --dbpath $arch/db --gpgdir $gpgdir --root $arch/root --cachedir $cachedir --needed --noconfirm pacman

cp $arch/root/etc/makepkg.conf makepkg-$arch.conf
cp $arch/root/etc/pacman.conf pacman-extra-$arch.conf

sed '/^PKGEXT/s/\.pkg\.tar\.xz/.pkg.tar.zst/' -i makepkg-$arch.conf

pacman -Sdd --config $arch/pacman.conf --dbpath $arch/db --gpgdir $gpgdir --root $arch/root --cachedir $cachedir --needed --noconfirm pacman-mirrorlist
pacman -Swdd --config $arch/pacman.conf --dbpath $arch/db --gpgdir $gpgdir --cachedir $cachedir --needed --noconfirm archlinuxarm-keyring
package=$(pacman -Sp --config $arch/pacman.conf --dbpath $arch/db --cachedir $cachedir archlinuxarm-keyring)
package=${package#file://}
rm -rf keyrings
xz -d $package --stdout | tar xvf - usr/share/pacman/keyrings --strip 3
cp $arch/root/etc/pacman.d/mirrorlist .
mv $package /tmp

pacman -Sc --config $arch/pacman.conf --dbpath $arch/db --gpgdir $gpgdir --cachedir $cachedir --noconfirm
mv /tmp/$(basename $package) $package || :
