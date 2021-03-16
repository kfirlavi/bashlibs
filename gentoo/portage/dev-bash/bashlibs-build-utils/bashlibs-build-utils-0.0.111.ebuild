# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit bashlibs

DESCRIPTION="bashlibs build utils for building bashlibs packages"
HOMEPAGE="https://github.com/kfirlavi/bashlibs"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="
	>=dev-bash/bashlibs-base-0.0.10
	dev-bash/bashlibs-os-detection
	>=dev-bash/bashlibs-utils-0.0.11
	>=dev-bash/bashlibs-checks-0.0.11
	>=dev-bash/bashlibs-usage-0.0.12
	>=dev-bash/bashlibs-verbose-0.0.25
	>=dev-bash/bashlibs-ssh-0.0.13
	dev-bash/bashlibs-cmdline
	>=dev-bash/bashlibs-shunit2-enhancements-0.0.20
	>=dev-bash/bashlibs-directories-0.0.4
	app-arch/dpkg
	app-text/tree
"

DEPEND="
	>=dev-bash/bashlibs-cmake-macros-0.0.5
"
