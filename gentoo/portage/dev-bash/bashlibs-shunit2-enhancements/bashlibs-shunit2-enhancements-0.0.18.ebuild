EAPI="5"

inherit cmake-utils flag-o-matic

MY_P="${P}-Source"
DESCRIPTION="bash library extending shunit2 functionality"
SRC_URI="${MY_P}.tar.bz2"


LICENSE="BSD"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

RDEPEND="
	dev-util/shunit2
	>=dev-bash/bashlibs-utils-0.0.6
	dev-bash/bashlibs-checks
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
