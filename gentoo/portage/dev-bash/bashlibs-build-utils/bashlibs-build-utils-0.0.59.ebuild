EAPI="4"

inherit cmake-utils flag-o-matic

MY_P="${P}-Source"
DESCRIPTION="bashlibs build utils for building bashlibs packages"
SRC_URI="${MY_P}.tar.bz2"


LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND="
	>=dev-bash/bashlibs-base-0.0.10
	>=dev-bash/bashlibs-utils-0.0.11
	>=dev-bash/bashlibs-usage-0.0.12
	>=dev-bash/bashlibs-verbose-0.0.16
	>=dev-bash/bashlibs-shunit2-enhancements-0.0.11
	>=dev-bash/bashlibs-directories-0.0.4
	app-arch/dpkg
"

DEPEND="
	dev-bash/bashlibs-cmake-macros
"

S="${WORKDIR}/${MY_P}"

src_configure() {
	local mycmakeargs="
		-DCMAKE_INSTALL_PREFIX=/"
	append-ldflags $(no-as-needed)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
}

