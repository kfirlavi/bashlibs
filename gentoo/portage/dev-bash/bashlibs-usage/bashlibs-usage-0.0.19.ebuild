# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit bashlibs

DESCRIPTION="bashlibs usage library to support creation of usage text when using --help flag"
HOMEPAGE="https://github.com/kfirlavi/bashlibs"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="
	>=dev-bash/bashlibs-utils-0.0.6
	>=dev-bash/bashlibs-colors-0.0.7
"

DEPEND="
	dev-bash/bashlibs-cmake-macros
"
