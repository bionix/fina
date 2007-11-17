#!/bin/bash

# $Id$

# Fina v0.1 Copyright (C) 2007 Tobias Klausmann
# Released under the GPLv2. See the file COPYING for details.

# This is the place where the main config file resides.
FINACFG="/etc/fina/fina.cfg"

# If on your system, some tools are on a different PATH, you can
# configure them here
FIND=$(which find)
SORT=$(which sort)
MODPROBE=$(which modprobe)
IPTRESTORE=$(which iptables-restore)
IPTSAVE=$(which iptables-save)
# --------------- Nothing to configure below here --------------- #

PROGNAME="$0"
VERSION="0.1"
DEBUG="1"

# Help function
function print_help() {
    echo "Usage: ${PROGNAME} --help|-h" >&2
    echo "   or: ${PROGNAME} [OPTIONS]" >&2
    echo "" >&2
    echo "Options:" >&2
    echo "   -p, --pretend    Don't load rules, just print them to stdout." >&2
    echo "   -k, --keep       Keep files generated in /tmp" >&2
    echo "" >&2
}

# Debug printing 
function dprint() {
    if [[ $DEBUG == 1 ]]; then
        echo  -e "$@" >&2
    fi
}

# Error printing 
function eprint() {
    echo  -e "$@" >&2
}

# Function that retrieves all rule files in lexical order
function get_rule_files () {
    # The trailing / is necessary in case ${RULESDIR} is a symlink
    $FIND ${RULESDIR}/ -name \*.rules -a \( -type f -o -type l \) -print|$SORT
}

# Function to create a temporary space for the file(s) we create
function get_tmpdir () {
    local UMASK=$(umask) # So we can restore it
    local OK=1
    local TRIES=3
    local TMPDIR=''
    umask 0077
    while [[ $OK != 0 && "$TRIES" -gt 0 ]]; do
        TMPDIR=/tmp/fina-$RANDOM$RANDOM
        TRIES=$(($TRIES-1))
        dprint "Trying to create $TMPDIR (tries left: $TRIES)" >&2
        mkdir "$TMPDIR" && OK=0
    done
    if [[ $OK != 0 ]]; then
        echo "Could not create TMPDIR."
        exit -1
    fi
    echo "${TMPDIR}"
    umask "$UMASK"
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
        --keep|-k)
            KEEPTEMP=1
            ;;
        *)
            echo "Unknown option '$1'"
            print_help
            exit 1
    esac
    shift
done

dprint "After cmdline. Programs are:"
dprint "FIND='$FIND'"
dprint "SORT='$SORT'"
dprint "MODPROBE='$MODPROBE'"
dprint "IPTRESTORE='$IPTRESTORE'"
dprint "IPTSAVE='$IPTSAVE'"
dprint ""
dprint "Program mode: PRETEND=$PRETEND KEEPTEMP=$KEEPTEMP"

# Now, lets get the rule files
dprint "Searching rules in '${RULESDIR}'"
RULEFILES=$(get_rule_files)
dprint "Found:\n$RULEFILES"

# Get a tmpfile to put assembled rules in
TMPDIR=$(get_tmpdir)

# Save the old rules if we're not pretending
if [[ $PRETEND != 1 ]]; then
    $IPTSAVE > $TMPDIR/rules.old
fi


# Generate the new rule file
{
    echo -n "#Fina# Generated by Fina v${VERSION} on "
    date -Is
    echo 
    for RULEFILE in $RULEFILES; do
        echo "#Fina# BEGIN of file '$RULEFILE'"
        cat "$RULEFILE"
        echo "#Fina# END of file '$RULEFILE'"
    done
    echo -n "#Fina# Generation complete on "
    date -Is 
} > "$TMPDIR/rules.new"

if [[ $PRETEND == 1 ]]; then
    cat "$TMPDIR/rules.new"
else
    dprint "Loading rules from file $TMPDIR/rules.new"
    MESG=$(iptables-restore < "$TMPDIR/rules.new" 2>&1)
    RETVAL=$?
    if [[ $RETVAL != 0 ]]; then
        eprint "Something went wrong (retval $RETVAL). Message:"
        eprint "$MESG"
        eprint "Loading old ruleset from $TMPDIR/rules.old"
        MESG=$(iptables-restore < "$TMPDIR/rules.old" 2>&1)
        RETVAL=$?
        if [[ $RETVAL != 0 ]]; then
            eprint "Even the old ruleset could not be loaded. Message:"
            eprint "$MESG"
        fi
        eprint "I have left all the files I generated in $TMPDIR"
        exit -1
    fi
fi

if [[ $KEEPTEMP != 1 ]]; then
    rm -rf $TMPDIR
fi

# vim: tabstop=4:shiftwidth=4:smarttab:expandtab:softtabstop=4:smartindent
