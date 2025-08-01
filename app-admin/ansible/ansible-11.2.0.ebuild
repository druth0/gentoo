# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517="setuptools"
PYTHON_COMPAT=( python3_{11..13} )

inherit distutils-r1 pypi

DESCRIPTION="Model-driven deployment, config management, and command execution framework"
HOMEPAGE="
	https://www.redhat.com/en/ansible-collaborative
	https://github.com/ansible-community/ansible-build-data
"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="amd64 ~arm arm64 ~ppc64 ~riscv x86 ~x64-macos"
RESTRICT="test"

RDEPEND="
	>=app-admin/ansible-core-2.18.2
	<app-admin/ansible-core-2.19
"

python_compile() {
	local -x ANSIBLE_SKIP_CONFLICT_CHECK=1
	distutils-r1_python_compile
}
python_install() {
	local -x ANSIBLE_SKIP_CONFLICT_CHECK=1
	distutils-r1_python_install
}
