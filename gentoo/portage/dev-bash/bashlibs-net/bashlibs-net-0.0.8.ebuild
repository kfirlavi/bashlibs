# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cmake-utils flag-o-matic linux-info

MY_P="${P}-Source"
DESCRIPTION="networking functions to create bridges, vlans, taps..."
HOMEPAGE="https://github.com/kfirlavi/bashlibs"
SRC_URI="${MY_P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="
	>=dev-bash/bashlibs-utils-0.0.6
	>=dev-bash/bashlibs-shunit2-enhancements-0.0.2
	dev-bash/bashlibs-sysfs
	sys-apps/iproute2
	net-misc/bridge-utils
"

DEPEND="
	dev-bash/bashlibs-cmake-macros
"

S="${WORKDIR}/${MY_P}"

pkg_pretend() {
	CONFIG_CHECK="VLAN_8021Q BRIDGE TUN"
	check_extra_config
}

src_configure() {
	local mycmakeargs="
		-DCMAKE_INSTALL_PREFIX=/"
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
}

pkg_postinst() {
	bashlibs \
		--verbose \
		--test test_net.sh
}
