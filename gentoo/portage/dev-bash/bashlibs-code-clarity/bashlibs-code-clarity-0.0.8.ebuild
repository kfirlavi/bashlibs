EAPI="4"

inherit cmake-utils flag-o-matic

MY_P="${P}-Source"
DESCRIPTION="bashlibs library for creating cleaner code"
SRC_URI="${MY_P}.tar.bz2"


LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND="
	>=dev-bash/bashlibs-utils-0.0.6
	>=dev-bash/bashlibs-shunit2-enhancements-0.0.2
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

pkg_postinst()
{
	if use test; then
		blibs --test ${P}.sh
	fi
}
