# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit bashlibs

DESCRIPTION="bashlibs grub manipulation library"
HOMEPAGE="https://github.com/kfirlavi/bashlibs"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="
	>=dev-bash/bashlibs-utils-0.0.6
	dev-bash/bashlibs-file-manipulations
	>=dev-bash/bashlibs-shunit2-enhancements-0.0.2
"

DEPEND="
	dev-bash/bashlibs-cmake-macros
"
