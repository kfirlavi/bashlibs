# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit bashlibs

DESCRIPTION="BASH libs utilities for managing the libraries"
HOMEPAGE="https://github.com/kfirlavi/bashlibs"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

PDEPEND="
	>=dev-bash/bashlibs-shunit2-enhancements-0.0.2
	>=dev-bash/bashlibs-code-clarity-0.0.2
	>=dev-bash/bashlibs-verbose-0.0.5
	>=dev-bash/bashlibs-usage-0.0.2
	>=dev-bash/bashlibs-base-0.0.7
"

DEPEND="
	>=dev-bash/bashlibs-cmake-macros-0.0.5
"
