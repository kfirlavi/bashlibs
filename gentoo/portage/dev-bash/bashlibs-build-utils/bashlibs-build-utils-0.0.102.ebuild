# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cmake-utils flag-o-matic

MY_P="${P}-Source"
DESCRIPTION="bashlibs build utils for building bashlibs packages"
HOMEPAGE="https://github.com/kfirlavi/bashlibs"
SRC_URI="${MY_P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="
	>=dev-bash/bashlibs-base-0.0.10
	dev-bash/bashlibs-os-detection
	>=dev-bash/bashlibs-utils-0.0.11
	>=dev-bash/bashlibs-usage-0.0.12
	>=dev-bash/bashlibs-verbose-0.0.25
	>=dev-bash/bashlibs-ssh-0.0.13
	dev-bash/bashlibs-cmdline
	>=dev-bash/bashlibs-shunit2-enhancements-0.0.11
	>=dev-bash/bashlibs-directories-0.0.4
	app-arch/dpkg
	app-text/tree
"

DEPEND="
	>=dev-bash/bashlibs-cmake-macros-0.0.5
"

S="${WORKDIR}/${MY_P}"

src_configure() {
	local mycmakeargs=(-DCMAKE_INSTALL_PREFIX=/)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
}

pkg_info() {
	bashlibs --verbose --test test_bake_test.sh
	bashlibs --verbose --test test_bake_cmake.sh
	bashlibs --verbose --test test_deb_repository.sh
	bashlibs --verbose --test test_bake_debian.sh
	bashlibs --verbose --test test_package_build.sh
	bashlibs --verbose --test test_bake_config.sh
	bashlibs --verbose --test test_bake_gentoo.sh
}
