# Maintainer: tomektom
pkgname=ass
pkgver=0.1.1
pkgrel=1
pkgdesc="Simple password manager based on Age"
arch=('any')
url="https://github.com/tomektom/ass.git"
license=('GPL3')
depends=('gum' 'age' 'tree' 'pwgen')
optdepends=('wl-clipboard: copying on Wayland'
            'xsel: copying on Xorg'
            'xclip: copying on Xorg')
source=("git+https://github.com/tomektom/ass.git#tag=v$pkgver")
md5sums=('SKIP')

package() {
	cd "$srcdir/$pkgname"
	install -Dm755 ass "$pkgdir/usr/bin/ass"
}
