# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cmake-utils flag-o-matic

MY_P="${P}-Source"
DESCRIPTION="bashlibs verbose library"
HOMEPAGE="https://github.com/kfirlavi/bashlibs"
SRC_URI="${MY_P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="
	>=dev-bash/bashlibs-utils-0.0.6
	>=dev-bash/bashlibs-verbose-0.0.5
	dev-bash/bashlibs-file-manipulations
	app-arch/cpio
"

DEPEND="
	dev-bash/bashlibs-cmake-macros
"

S="${WORKDIR}/${MY_P}"

src_configure() {
	local mycmakeargs="
		-DCMAKE_INSTALL_PREFIX=/"
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
}

pkg_postinst() {
	bashlibs \
		--verbose \
		--test test_initramfs.sh
}
