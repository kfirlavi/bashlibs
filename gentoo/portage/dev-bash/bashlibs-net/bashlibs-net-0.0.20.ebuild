# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit bashlibs linux-info

DESCRIPTION="networking functions to create bridges, vlans, taps..."
HOMEPAGE="https://github.com/kfirlavi/bashlibs"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="
	>=dev-bash/bashlibs-utils-0.0.6
	>=dev-bash/bashlibs-shunit2-enhancements-0.0.2
	>=dev-bash/bashlibs-sysfs-0.0.11
	dev-bash/bashlibs-config
	dev-bash/bashlibs-directories
	sys-apps/iproute2
	net-misc/bridge-utils
	sys-fs/mtools
"

DEPEND="
	>=dev-bash/bashlibs-cmake-macros-0.0.17
"

pkg_pretend() {
	CONFIG_CHECK="~VLAN_8021Q ~BRIDGE ~TUN ~BRIDGE_NETFILTER"
	check_extra_config
}
