# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit cmake dot-a

CommitId=c278588e34e535f0bb8f00df3880d26928038cad

DESCRIPTION="ONNXIFI with Facebook Extension"
HOMEPAGE="https://github.com/houseroad/foxi/"
SRC_URI="https://github.com/houseroad/${PN}/archive/${CommitId}.tar.gz
	-> ${P}.tar.gz"

S="${WORKDIR}"/${PN}-${CommitId}

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~arm64"

RESTRICT="test" # No test available

PATCHES=(
	"${FILESDIR}"/${P}-gentoo.patch
	"${FILESDIR}"/${P}-cmake.patch
)

src_configure() {
	lto-guarantee-fat
	cmake_src_configure
}

src_install() {
	cmake_src_install
	strip-lto-bytecode
}
