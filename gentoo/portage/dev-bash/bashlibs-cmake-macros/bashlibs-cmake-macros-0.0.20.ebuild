# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit bashlibs

DESCRIPTION="Generic Cmake macros"
HOMEPAGE="https://github.com/kfirlavi/bashlibs"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="
	|| ( dev-util/cmake dev-build/cmake )
	>=dev-util/cmake-macros-0.0.12
"
RDEPEND=""
