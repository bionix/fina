# Note that this file has to be renamed to fina-<version>.ebuild to
# work properly. For v0.2.3, the name would be fina-0.2.3.ebuild.
# Also, it needs to be in an overlay directory, for example 
# /usr/local/portage/net-firewall/fina/

DESCRIPTION="Fina is a Netfilter script for admins who know what they're doing."
HOMEPAGE="http://www.schwarzvogel.de/software-fina.shtml"
SRC_URI="http://www.schwarzvogel.de/pkgs/fina-${PV}.tar.gz"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="ipv6"

DEPEND="net-firewall/iptables"
RDEPEND="${DEPEND}"

src_install() {
	dodir /etc/fina/
	insinto /etc/fina
	doins fina.cfg 
	exeinto /etc/fina
	doexe post-up.sh pre-up.sh
	use ipv6 && doexe post6-up.sh pre6-up.sh 
	dodir /etc/fina/rules.d
	use ipv6 && dodir /etc/fina/rules6.d
	dosbin fina 
	use ipv6 && dosbin fina6
	newinitd fina.init.gentoo fina
	use ipv6 && newinitd fina6.init.gentoo fina6
	dodoc README
	docinto examples/
	dodoc example-rules.d/*
}
