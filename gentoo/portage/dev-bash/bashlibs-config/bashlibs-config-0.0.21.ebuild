# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit bashlibs

DESCRIPTION="configuration library"
HOMEPAGE="https://github.com/kfirlavi/bashlibs"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="
	>=dev-bash/bashlibs-utils-0.0.6
	dev-bash/bashlibs-verbose
	>=dev-bash/bashlibs-shunit2-enhancements-0.0.16
	>=dev-bash/bashlibs-string-0.0.8
	>=dev-bash/bashlibs-checks-0.0.3
"

DEPEND="
	dev-bash/bashlibs-cmake-macros
"
