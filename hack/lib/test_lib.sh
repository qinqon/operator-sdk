#!/usr/bin/env bash

source hack/lib/common.sh

function listPkgDirs() {
	go list -f '{{.Dir}}' ./cmd/... ./pkg/... ./test/... ./internal/... | grep -v generated
}

function listFiles() {
	# pipeline is much faster than for loop
	listPkgDirs | xargs -I {} find {} -name '*.go' | grep -v generated
}

#===================================================================
# FUNCTION trap_add ()
#
# Purpose:  prepends a command to a trap
#
# - 1st arg:  code to add
# - remaining args:  names of traps to modify
#
# Example:  trap_add 'echo "in trap DEBUG"' DEBUG
#
# See: http://stackoverflow.com/questions/3338030/multiple-bash-traps-for-the-same-signal
#===================================================================
function trap_add() {
    trap_add_cmd=$1; shift || fatal "${FUNCNAME} usage error"
    new_cmd=
    for trap_add_name in "$@"; do
        # Grab the currently defined trap commands for this trap
        existing_cmd=`trap -p "${trap_add_name}" |  awk -F"'" '{print $2}'`

        # Define default command
        [ -z "${existing_cmd}" ] && existing_cmd="echo exiting @ `date`"

        # Generate the new command
        new_cmd="${trap_add_cmd};${existing_cmd}"

        # Assign the test
         trap   "${new_cmd}" "${trap_add_name}" || \
                fatal "unable to add to trap ${trap_add_name}"
    done
}
