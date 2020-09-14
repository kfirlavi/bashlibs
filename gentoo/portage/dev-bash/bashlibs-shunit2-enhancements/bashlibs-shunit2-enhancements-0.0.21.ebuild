# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit bashlibs

DESCRIPTION="bash library extending shunit2 functionality"
HOMEPAGE="https://github.com/kfirlavi/bashlibs"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="
	dev-util/shunit2
	>=dev-bash/bashlibs-utils-0.0.6
	dev-bash/bashlibs-checks
"

DEPEND="
	dev-bash/bashlibs-cmake-macros
"
