# Copyright 2016-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Avoid circular dependency
JAVA_DISABLE_DEPEND_ON_JAVA_DEP_CHECK="true"

inherit java-pkg-2 java-pkg-simple

DESCRIPTION="Java Dependency checker"
HOMEPAGE="https://wiki.gentoo.org/wiki/Project:Java"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"

CP_DEPEND="
	dev-java/commons-cli:0
	>=dev-java/asm-9.8:0"
RDEPEND=">=virtual/jre-1.8:*
	${CP_DEPEND}"
DEPEND=">=virtual/jdk-1.8:*
	${CP_DEPEND}"

JAVA_MAIN_CLASS="javadepchecker.Main"

src_unpack() {
	cp "${FILESDIR}/Main-${PV}.java" Main.java || die
}
