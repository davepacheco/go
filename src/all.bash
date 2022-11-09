#!/usr/bin/env bash
# Copyright 2009 The Go Authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -e
if [ ! -f make.bash ]; then
	echo 'all.bash must be run from $GOROOT/src' 1>&2
	exit 1
fi
OLDPATH="$PATH"

# XXX-dap: dump information about what we're running
# We want this to go to stdout rather than stderr because that's where all the
# other useful output from this script goes.
echo "*** ENVIRONMENT INFORMATION ***"
(
    BASH_XTRACEFD=1;
    set -o xtrace;
    git describe --tags --dirty
    git status
    git clean -nxd
    env
)
echo "*** END OF ENVIRONMENT ***"

. ./make.bash "$@" --no-banner
bash run.bash --no-rebuild
PATH="$OLDPATH"
$GOTOOLDIR/dist banner  # print build info
