EAPI="4"

inherit cmake-utils flag-o-matic

MY_P="${P}-Source"
DESCRIPTION="Generic Cmake macros"
SRC_URI="${MY_P}.tar.bz2"


LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="
	dev-util/cmake
	>=dev-util/cmake-macros-0.0.2
"
RDEPEND=""

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
