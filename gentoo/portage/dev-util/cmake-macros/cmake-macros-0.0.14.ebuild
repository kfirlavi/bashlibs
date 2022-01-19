# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit bashlibs

DESCRIPTION="Generic Cmake macros"
HOMEPAGE="https://github.com/kfirlavi/bashlibs"

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
