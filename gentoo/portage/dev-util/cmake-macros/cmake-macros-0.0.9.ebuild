# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cmake-utils flag-o-matic

MY_P="${P}-Source"
DESCRIPTION="Generic Cmake macros"
HOMEPAGE="https://github.com/kfirlavi/bashlibs"
SRC_URI="${MY_P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

PDEPEND="
	dev-bash/bashlibs-os-detection
"
DEPEND="
	>=dev-util/cmake-2.6
"
RDEPEND=""

S="${WORKDIR}/${MY_P}"

src_configure() {
	local mycmakeargs="
		-DCMAKE_INSTALL_PREFIX=/"
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
}
