#!/bin/sh
set -e

cp keyrings/archlinuxarm* /usr/share/devtools/ || :
fakeroot pacman-key --gpgdir gnupg --init
fakeroot pacman-key --gpgdir gnupg --populate archlinuxarm || :

for arch in armv6h armv7h aarch64
do
	mkdir -p $arch/{db,root}
	cachedir=/var/cache/pacman/pkg/$arch
	echo [options] > $arch/pacman.conf
	echo "Architecture = $arch" >> $arch/pacman.conf
	echo "[core]" >> $arch/pacman.conf
	echo "Include = $(realpath mirrorlist)" >> $arch/pacman.conf

	fakeroot pacman -Sy --config $arch/pacman.conf --dbpath $arch/db --gpgdir gnupg
	fakeroot pacman -Sdd --config $arch/pacman.conf --dbpath $arch/db --gpgdir gnupg --root $arch/root --cachedir $cachedir --needed --noconfirm pacman

	cp $arch/root/etc/makepkg.conf makepkg-$arch.conf
	cp $arch/root/etc/pacman.conf pacman-extra-$arch.conf

	if [ "$arch" = "aarch64" ]
	then
		fakeroot pacman -Sdd --config $arch/pacman.conf --dbpath $arch/db --gpgdir gnupg --root $arch/root --cachedir $cachedir --needed --noconfirm pacman-mirrorlist
		fakeroot pacman -Swdd --config $arch/pacman.conf --dbpath $arch/db --gpgdir gnupg --cachedir $cachedir --noconfirm archlinuxarm-keyring
		fakeroot pacman -Sc --config $arch/pacman.conf --dbpath $arch/db --gpgdir gnupg --cachedir $cachedir --noconfirm
		rm -rf keyrings
		xz -d $arch/cache/archlinuxarm-keyring-*.pkg.tar.xz --stdout | tar xvf - usr/share/pacman/keyrings --strip 3
		cp $arch/root/etc/pacman.d/mirrorlist .
	fi

	fakeroot pacman -Sc --config $arch/pacman.conf --dbpath $arch/db --gpgdir gnupg --cachedir $cachedir --noconfirm
done
