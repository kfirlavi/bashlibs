EAPI="4"

inherit cmake-utils flag-o-matic

MY_P="${P}-Source"
DESCRIPTION="BASH libs utilities for managing the libraries"
SRC_URI="${MY_P}.tar.bz2"


LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~amd64"
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
