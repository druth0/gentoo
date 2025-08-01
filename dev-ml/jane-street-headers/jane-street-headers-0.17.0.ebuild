# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit dune

DESCRIPTION="Jane Street header files"
HOMEPAGE="https://github.com/janestreet/jane-street-headers"
SRC_URI="https://github.com/janestreet/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64 ~arm64 ~ppc ~ppc64 ~riscv"
IUSE="+ocamlopt"

RDEPEND=">=dev-lang/ocaml-5"
DEPEND="${RDEPEND}"
BDEPEND=">=dev-ml/dune-3.11"
