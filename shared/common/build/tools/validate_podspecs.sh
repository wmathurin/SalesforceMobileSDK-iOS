#!/bin/bash

# Copyright (c) 2026-present, salesforce.com, inc. All rights reserved.
#
# Redistribution and use of this software in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# * Redistributions of source code must retain the above copyright notice, this list of conditions
# and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice, this list of
# conditions and the following disclaimer in the documentation and/or other materials provided
# with the distribution.
# * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
# endorse or promote products derived from this software without specific prior written
# permission of salesforce.com, inc.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
# WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#
# Validates that all podspecs in the repository are syntactically correct.
# Checks Ruby syntax and verifies public_header_files quoting is well-formed.
#
# Usage:
#   validate_podspecs.sh
#
# Run from anywhere — the script finds the repo root automatically.
#

set -e

REPO_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../../../.. && pwd)
PODSPECS=(
    "SalesforceSDKCommon.podspec"
    "SalesforceAnalytics.podspec"
    "SalesforceSDKCore.podspec"
    "SmartStore.podspec"
    "MobileSync.podspec"
)

FAILURES=0

for spec in "${PODSPECS[@]}"; do
    spec_path="${REPO_DIR}/${spec}"
    if [ ! -f "${spec_path}" ]; then
        echo "SKIP: ${spec} not found"
        continue
    fi

    # Check Ruby syntax
    if ! ruby -c "${spec_path}" > /dev/null 2>&1; then
        echo "FAIL: ${spec} — Ruby syntax error"
        ruby -c "${spec_path}" 2>&1 | head -5
        FAILURES=$((FAILURES + 1))
        continue
    fi

    # Check that public_header_files quoting is balanced (each path wrapped in single quotes)
    header_line=$(grep '\.public_header_files' "${spec_path}" 2>/dev/null || true)
    if [ -n "${header_line}" ]; then
        # Count opening and closing single quotes — they should be equal
        open_quotes=$(echo "${header_line}" | tr -cd "'" | wc -c | tr -d ' ')
        if [ $((open_quotes % 2)) -ne 0 ]; then
            echo "FAIL: ${spec} — unbalanced quotes in public_header_files"
            echo "  ${header_line}"
            FAILURES=$((FAILURES + 1))
            continue
        fi
    fi

    echo "OK:   ${spec}"
done

if [ ${FAILURES} -gt 0 ]; then
    echo ""
    echo "${FAILURES} podspec(s) failed validation."
    exit 1
else
    echo ""
    echo "All podspecs passed validation."
fi
