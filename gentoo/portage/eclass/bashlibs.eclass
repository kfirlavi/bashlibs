# @ECLASS: bashlibs.eclass
# @MAINTAINER:
# lavi.kfir@gmail.com
# @SUPPORTED_EAPIS: 5
# @BLURB: Support eclass for bashlibs
# @DESCRIPTION:
# library routins for simple ebuilds

inherit cmake-utils flag-o-matic 

MY_P="${P}-Source"
SRC_URI="${MY_P}.tar.bz2"
S="${WORKDIR}/${MY_P}"

src_configure() {
	local mycmakeargs=(-DCMAKE_INSTALL_PREFIX=/)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
}

bashlibs_binary_exist() {
	which bashlibs
}

pkg_postinst() {
	bashlibs_binary_exist \
		&& _LIBRARIES_INCLUDED= \
            bashlibs --test ${PN}
}
