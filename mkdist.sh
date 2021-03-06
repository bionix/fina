#!/bin/bash

function die() {
    echo -e  "$@" >&2
    exit -1
}


FVERS=$(./fina --version|head -n1|sed -e 's/.*version //g') || die "Could not determine fina version"
PNAME="fina-$FVERS"
DISTDIR="dist/"
[[ -d $DISTDIR ]] || mkdir $DISTDIR

mkdir "$PNAME" || die "mkdir failed"
cp -r fina fina6 example-rules.d fina.cfg INSTALL COPYING README fina.init fina6.init fina.init.gentoo fina6.init.gentoo post-up.sh pre-up.sh post6-up.sh pre6-up.sh fina.ebuild "fina-$FVERS/" || die "cp failed"
tar czf "$DISTDIR/$PNAME".tar.gz "$PNAME" || die "tar failed"
rm -rf "$PNAME" || die "rm failed"
