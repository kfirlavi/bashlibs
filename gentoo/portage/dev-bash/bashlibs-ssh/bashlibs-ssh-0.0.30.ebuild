# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit bashlibs

DESCRIPTION="ssh procedures to create passwordless connection"
HOMEPAGE="https://github.com/kfirlavi/bashlibs"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="
	>=dev-bash/bashlibs-utils-0.0.6
	>=dev-bash/bashlibs-verbose-0.0.32
	>=dev-bash/bashlibs-shunit2-enhancements-0.0.2
	>=dev-bash/bashlibs-directories-0.0.18
	net-analyzer/nmap
	net-misc/sshpass
"

DEPEND="
	dev-bash/bashlibs-cmake-macros
"
