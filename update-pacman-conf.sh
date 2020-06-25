#!/bin/sh
set -ex

cp keyrings/archlinuxarm* /usr/share/pacman/keyrings || :

for arch in armv6h armv7h aarch64
do
	gpgdir=$arch/gnupg
	cachedir=/var/cache/pacman/pkg/$arch

	mkdir -p $arch/{db,root} $cachedir

	echo [options] > $arch/pacman.conf
	echo "Architecture = $arch" >> $arch/pacman.conf
	echo "[core]" >> $arch/pacman.conf
	echo "Include = $(realpath mirrorlist)" >> $arch/pacman.conf

	pacman-key --config $arch/pacman.conf --gpgdir $gpgdir --init
	pacman-key --config $arch/pacman.conf --gpgdir $gpgdir --populate archlinuxarm

	pacman -Sy --config $arch/pacman.conf --dbpath $arch/db --gpgdir $gpgdir
	pacman -Sdd --config $arch/pacman.conf --dbpath $arch/db --gpgdir $gpgdir --root $arch/root --cachedir $cachedir --needed --noconfirm pacman

	cp $arch/root/etc/makepkg.conf makepkg-$arch.conf
	cp $arch/root/etc/pacman.conf pacman-extra-$arch.conf

	sed '/^#CacheDir/{s/^#//;s/$/'${arch}'/}' -i pacman-extra-$arch.conf
	sed '/^PKGEXT/s/\.pkg\.tar\.xz/.pkg.tar.zst/' -i makepkg-$arch.conf

	if [ "$arch" = "aarch64" ]
	then
		pacman -Sdd --config $arch/pacman.conf --dbpath $arch/db --gpgdir $gpgdir --root $arch/root --cachedir $cachedir --needed --noconfirm pacman-mirrorlist
		pacman -Swdd --config $arch/pacman.conf --dbpath $arch/db --gpgdir $gpgdir --cachedir $cachedir --needed --noconfirm archlinuxarm-keyring
		package=$(pacman -Sp --config $arch/pacman.conf --dbpath $arch/db --cachedir $cachedir archlinuxarm-keyring)
		package=${package#file://}
		rm -rf keyrings
		xz -d $package --stdout | tar xvf - usr/share/pacman/keyrings --strip 3
		cp $arch/root/etc/pacman.d/mirrorlist .
		mv $package /tmp
	fi

	pacman -Sc --config $arch/pacman.conf --dbpath $arch/db --gpgdir $gpgdir --cachedir $cachedir --noconfirm
	[ "$arch" = "aarch64" ] && mv /tmp/$(basename $package) $package || :
done
