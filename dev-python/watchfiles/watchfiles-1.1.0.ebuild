# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=maturin
PYTHON_COMPAT=( python3_{11..14} pypy3_11 )

CRATES="
	autocfg@1.3.0
	bitflags@1.3.2
	bitflags@2.7.0
	cc@1.0.96
	cfg-if@1.0.0
	crossbeam-channel@0.5.15
	crossbeam-utils@0.8.19
	filetime@0.2.24
	fsevent-sys@4.1.0
	heck@0.5.0
	indoc@2.0.5
	inotify-sys@0.1.5
	inotify@0.11.0
	kqueue-sys@1.0.4
	kqueue@1.0.8
	libc@0.2.169
	libredox@0.1.3
	log@0.4.22
	memoffset@0.9.1
	mio@1.0.3
	notify-types@2.0.0
	notify@8.0.0
	once_cell@1.19.0
	portable-atomic@1.6.0
	proc-macro2@1.0.81
	pyo3-build-config@0.25.1
	pyo3-ffi@0.25.1
	pyo3-macros-backend@0.25.1
	pyo3-macros@0.25.1
	pyo3@0.25.1
	python3-dll-a@0.2.13
	quote@1.0.36
	redox_syscall@0.5.3
	same-file@1.0.6
	syn@2.0.60
	target-lexicon@0.13.2
	unicode-ident@1.0.12
	unindent@0.2.3
	walkdir@2.5.0
	wasi@0.11.0+wasi-snapshot-preview1
	winapi-util@0.1.9
	windows-sys@0.52.0
	windows-sys@0.59.0
	windows-targets@0.52.6
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_msvc@0.52.6
	windows_i686_gnu@0.52.6
	windows_i686_gnullvm@0.52.6
	windows_i686_msvc@0.52.6
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_msvc@0.52.6
"

inherit cargo distutils-r1

DESCRIPTION="Simple, modern file watching and code reload in Python"
HOMEPAGE="
	https://pypi.org/project/watchfiles/
	https://github.com/samuelcolvin/watchfiles/
"
SRC_URI="
	https://github.com/samuelcolvin/watchfiles/archive/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
	${CARGO_CRATE_URIS}
"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+="
	Apache-2.0-with-LLVM-exceptions CC0-1.0 ISC MIT Unicode-DFS-2016
"
SLOT="0"
KEYWORDS="amd64 arm arm64 ppc ppc64 ~riscv ~s390 sparc x86"

RDEPEND="
	>=dev-python/anyio-4.0.0[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/setuptools-rust[${PYTHON_USEDEP}]
	test? (
		dev-python/dirty-equals[${PYTHON_USEDEP}]
		dev-python/pytest-mock[${PYTHON_USEDEP}]
		dev-python/pytest-timeout[${PYTHON_USEDEP}]
	)
"

# enjoy Rust
QA_FLAGS_IGNORED=".*/_rust_notify.*"

export PYO3_USE_ABI3_FORWARD_COMPATIBILITY=1

distutils_enable_tests pytest

python_test() {
	local EPYTEST_DESELECT=(
		# test broken with new anyio
		# https://github.com/samuelcolvin/watchfiles/issues/254
		tests/test_watch.py::test_awatch_interrupt_raise
	)

	rm -rf watchfiles || die
	epytest
}
