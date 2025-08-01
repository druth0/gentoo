# Copyright 2021-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit savedconfig toolchain-funcs

DESCRIPTION="Simple Virtual Keyboard"
HOMEPAGE="https://tools.suckless.org/x/svkbd/"
SRC_URI="https://dl.suckless.org/tools/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	x11-libs/libX11
	x11-libs/libXft
	x11-libs/libXinerama
	x11-libs/libXtst
"
DEPEND="
	${RDEPEND}
	x11-base/xorg-proto
"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	default

	restore_config config.def.h

	sed -i -e 's|pkg-config|$(PKG_CONFIG)|g' Makefile config.mk || die
}

src_compile() {
	local i
	for i in layout.*.h; do
		i=${i/layout.}
		i=${i/.h}
		emake \
			CC="$(tc-getCC)" \
			PKG_CONFIG="$(tc-getPKG_CONFIG)" \
			LAYOUT=${i}
	done
}

src_install() {
	emake DESTDIR="${D}" PREFIX="${EPREFIX}/usr" install
	dobin ${PN}-*[!\.o]
	doman ${PN}.1
	save_config config.def.h
}
