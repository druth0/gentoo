# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LUA_COMPAT=( lua5-{1..4} luajit )

PYTHON_COMPAT=( python3_{10..14} )

WEBAPP_MANUAL_SLOT="yes"

inherit flag-o-matic lua-single python-single-r1 tmpfiles toolchain-funcs webapp git-r3

[[ -z "${CGIT_CACHEDIR}" ]] && CGIT_CACHEDIR="/var/cache/${PN}/"

GIT_V="2.46.0"

DESCRIPTION="A fast web-interface for Git repositories"
HOMEPAGE="https://git.zx2c4.com/cgit/about"
if [[ ${PV} =~ 9999* ]]; then
	EGIT_REPO_URI="https://git.zx2c4.com/cgit"
else
	SRC_URI="https://www.kernel.org/pub/software/scm/git/git-${GIT_V}.tar.xz
		https://git.zx2c4.com/cgit/snapshot/${P}.tar.xz"
fi

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="doc +highlight +lua test"
REQUIRED_USE="lua? ( ${LUA_REQUIRED_USE} ) ${PYTHON_REQUIRED_USE}"
RESTRICT="!test? ( test )"

RDEPEND="
	${PYTHON_DEPS}
	acct-group/cgit
	acct-user/cgit
	dev-libs/openssl:0=
	dev-vcs/git
	highlight? (
		$(python_gen_cond_dep '
			dev-python/docutils[${PYTHON_USEDEP}]
			dev-python/markdown[${PYTHON_USEDEP}]
			dev-python/pygments[${PYTHON_USEDEP}]
		')
		sys-apps/groff
	)
	lua? ( ${LUA_DEPS} )
	sys-libs/zlib
	virtual/httpd-cgi
"
# ebuilds without WEBAPP_MANUAL_SLOT="yes" are broken
DEPEND="${RDEPEND}"
BDEPEND="
	doc? (
		app-text/docbook-xsl-stylesheets
		>=app-text/asciidoc-8.5.1
	)
"

pkg_setup() {
	python_setup
	webapp_pkg_setup
	use lua && lua-single_pkg_setup
}

src_configure() {
	if ! [[ ${PV} =~ 9999* ]]; then
		rmdir git || die
		mv "${WORKDIR}"/git-"${GIT_V}" git || die
	fi

	# bug #951555
	append-cflags -std=gnu17

	echo "prefix = ${EPREFIX}/usr" >> cgit.conf || die "echo prefix failed"
	echo "libdir = ${EPREFIX}/usr/$(get_libdir)" >> cgit.conf || die "echo libdir failed"
	echo "CGIT_SCRIPT_PATH = ${MY_CGIBINDIR}" >> cgit.conf || die "echo CGIT_SCRIPT_PATH failed"
	echo "CGIT_DATA_PATH = ${MY_HTDOCSDIR}" >> cgit.conf || die "echo CGIT_DATA_PATH failed"
	echo "CACHE_ROOT = ${CGIT_CACHEDIR}" >> cgit.conf || die "echo CACHE_ROOT failed"
	if use lua; then
		echo "LUA_PKGCONFIG = ${ELUA}" >> cgit.conf || die "echo LUA_PKGCONFIG failed"
	else
		echo "NO_LUA = 1" >> cgit.conf || die "echo NO_LUA failed"
	fi
}

src_compile() {
	emake V=1 AR="$(tc-getAR)" CC="$(tc-getCC)" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}"
	use doc && emake V=1 doc-man
}

src_install() {
	webapp_src_preinst

	emake V=1 AR="$(tc-getAR)" CC="$(tc-getCC)" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" DESTDIR="${D}" install

	insinto /etc
	doins "${FILESDIR}"/cgitrc

	dodoc README
	use doc && doman cgitrc.5

	webapp_postinst_txt en "${FILESDIR}"/postinstall-en.txt
	webapp_src_install

	cat > cgit.conf <<-EOT || die
		d ${CGIT_CACHEDIR} 0700 cgit cgit -
	EOT
	dotmpfiles cgit.conf

	python_fix_shebang .
}

src_test() {
	emake V=1 AR="$(tc-getAR)" CC="$(tc-getCC)" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" test
}

pkg_postinst() {
	webapp_pkg_postinst
	tmpfiles_process cgit.conf
	ewarn "The cgit cache is enabled using the cache-size setting in cgitrc."
	ewarn "If enabling the cache and running cgit using the web server's user"
	ewarn "you should copy ${EROOT}/usr/lib/tmpfiles.d/cgit.conf"
	ewarn "to ${EROOT}/etc/tmpfiles.d/ and edit, changing the ownership fields."
	ewarn "If you use the cache-root setting in cgitrc to specify a cache directory"
	ewarn "other than ${CGIT_CACHEDIR} edit the path in cgit.conf."
}
