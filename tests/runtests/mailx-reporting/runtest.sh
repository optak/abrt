#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of mailx-reporting
#   Description: Tests abrt-action-mailx
#   Author: Michal Nowak <mnowak@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2011 Red Hat, Inc. All rights reserved.
#
#   This copyrighted material is made available to anyone wishing
#   to use, modify, copy, or redistribute it subject to the terms
#   and conditions of the GNU General Public License version 2.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE. See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public
#   License along with this program; if not, write to the Free
#   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#   Boston, MA 02110-1301, USA.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

. /usr/share/beakerlib/beakerlib.sh
. ../aux/lib.sh

TEST="mailx-reporting"
PACKAGE="abrt"

rlJournalStart
    rlPhaseStartSetup
        check_prior_crashes

        TmpDir=$(mktemp -d)
        cp mailx.conf $TmpDir
        rlRun "pushd $TmpDir"

        generate_crash
        get_crash_path
        wait_for_hooks
    rlPhaseEnd

    rlPhaseStartTest
        rlRun "reporter-mailx -v -d $crash_PATH -c mailx.conf" 0 "Report via mailx"
        sleep 10
        rlRun "mailx -H -u root | tail -n1 > mail.out"
        rlAssertGrep "abrt@" mail.out
        rlAssertGrep "abrt@" /var/spool/mail/root
        rlAssertGrep "\[abrt\] crash" mail.out
        rlLog "$(cat mail.out)"
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "popd"
        rlRun "echo 'delete *' | mailx -u root" 0 "Delete mail"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
        rlRun "abrt-cli rm $crash_PATH" 0 "Remove crash directory"
    rlPhaseEnd
    rlJournalPrintText
rlJournalEnd
