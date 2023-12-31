#!/bin/sh
startdir=$1
pkgname=$2

if [ -z "$startdir" ] || [ -z "$pkgname" ]; then
	echo "ERROR: missing argument!"
	echo "Please call $0 with \$startdir \$pkgname as arguments."
	exit 1
fi

srcdir="$startdir/src"
pkgdir="$startdir/pkg/$pkgname"

if [ ! -f "$srcdir/deviceinfo" ]; then
	echo "NOTE: $0 is intended to be used inside of the package() function"
	echo "of a device package's APKBUILD only."
	echo "ERROR: deviceinfo file missing!"
	exit 1
fi

install -Dm644 "$srcdir/deviceinfo" \
	"$pkgdir/etc/deviceinfo"
install -Dm644 "$srcdir/machine-info" \
	"$pkgdir/etc/machine-info"

if [ -f "$srcdir/90-$pkgname.rules" ]; then
	install -Dm644 "$srcdir/90-$pkgname.rules" \
		"$pkgdir/etc/udev/rules.d/90-$pkgname.rules"
fi

if [ -f "$srcdir/initfs-hook.sh" ]; then
	install -Dm644 "$srcdir/initfs-hook.sh" \
		"$pkgdir/usr/share/mkinitfs/hooks/00-$pkgname.sh"
fi

# All the installation paths for the modules conflict with those from
# devicepkg_subpackage_kernel. See comment there for details
if [ -f "$srcdir/modules-initfs" ]; then
	install -Dm644 "$srcdir/modules-initfs" \
		"$pkgdir/usr/share/mkinitfs/modules/00-$pkgname.modules"
	mkdir -p "$pkgdir/usr/share/mkinitfs/files"
	echo "/usr/share/mkinitfs/modules/00-$pkgname.modules:/lib/modules/initramfs.load" \
	     > "$pkgdir/usr/share/mkinitfs/files/00-$pkgname-modules.files"
fi

if [ -f "$srcdir/modules-load.conf" ]; then
	install -Dm644 "$srcdir/modules-load.conf" \
		"$pkgdir/etc/modules-load.d/00-$pkgname.conf"
fi

if [ -f "$srcdir/modprobe.conf" ]; then
	install -Dm644 "$srcdir/modprobe.conf" \
		"$pkgdir/etc/modprobe.d/$pkgname.conf"
fi

# Workaround for https://gitlab.com/postmarketOS/pmaports/-/issues/2228
touch "$pkgname"-trigger
install -Dm644 "$pkgname"-trigger \
	"$pkgdir"/usr/share/mkinitfs-triggers/"$pkgname"
