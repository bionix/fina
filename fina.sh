#!/bin/bash

# $Id$

# Fina v0.1 Copyright (C) 2007 Tobias Klausmann
# Released under the GPLv2. See the file COPYING for details.

# This is the place where the main config file resides.
FINACFG="/etc/fina/fina.cfg"

# If on your system, some tools are on a different PATH, you can
# configure them here
# FIND=$(which find)
# SORT=$(which sort)
# MODPROBE=$(which modprobe)
# IPTRESTORE=$(which iptables-restore)
# IPTSAVE=$(which iptables-save)

# --------------- Nothing to configure below here --------------- #

PROGNAME="$0"
DEBUG="1"

# Help function
function print_help() {
    echo "Usage: ${PROGNAME} --help|-h" >&2
    echo "   or: ${PROGNAME} -p|--pretend" >&2
    echo "" >&2
    echo "   -p, --pretend    Do not activate rules, just print them to stdout." >&2
}

# Debug printing 
function dprint() {
    if [ 1 == "${DEBUG}" ]; then
        echo "$@"
    fi
}

# Function that retrieves all rule files in lexical order
function get_rule_files () {
    dprint "Searching rules in \'"${RULESDIR}"\'"
    $FIND ${RULESDIR} -name \*.rules -a \( -type f -o -type l \)|$SORT
}

# Defaults
PRETEND=0

# Get cfg file contents
source "${FINACFG}"

# Parse cmdline
while test -n "$1"; do
    case "$1" in
        --help|-h)
            print_help
            exit 0
            ;;
        --pretend|-p)
            PRETEND=1
            ;;
        *)
            echo "Unknown option '$1'"
            print_help
            exit 1
    esac
    shift
done



# vim: tabstop=4:shiftwidth=4:smarttab:expandtab:softtabstop=4:smartindent
