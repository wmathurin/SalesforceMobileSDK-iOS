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
# CI validation script for the SPM source-build Package.swift.
# Runs all checks to ensure Package.swift and podspecs are in sync with source.
#
# Usage:
#   ci_validate_spm.sh
#
# Exit codes:
#   0 — all checks pass
#   1 — one or more checks failed
#

set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_DIR=$(cd "${SCRIPT_DIR}/../../../.." && pwd)

FAILURES=0

echo "=== SPM Source-Build CI Validation ==="
echo ""

# Step 1: Verify Package.swift file lists are in sync
echo "--- Step 1: Checking Package.swift file lists ---"
for lib in SalesforceSDKCommon SalesforceSDKCore SmartStore MobileSync; do
    if ! "${SCRIPT_DIR}/update_package_swift.sh" -l "$lib" --check; then
        FAILURES=$((FAILURES + 1))
    fi
done
echo ""

# Step 2: Verify Package.swift manifest parses
echo "--- Step 2: Verifying Package.swift parses ---"
cd "${REPO_DIR}"
if swift package dump-package > /dev/null 2>&1; then
    echo "OK: Package.swift parses successfully"
    PRODUCTS=$(swift package dump-package 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(', '.join(p['name'] for p in d['products']))" 2>/dev/null || echo "UNKNOWN")
    echo "    Products: ${PRODUCTS}"
else
    echo "FAIL: Package.swift failed to parse"
    swift package dump-package 2>&1 | tail -5
    FAILURES=$((FAILURES + 1))
fi
echo ""

# Step 3: Validate podspec syntax
echo "--- Step 3: Validating podspecs ---"
if ! "${SCRIPT_DIR}/validate_podspecs.sh"; then
    FAILURES=$((FAILURES + 1))
fi
echo ""

# Summary
echo "=== Summary ==="
if [ ${FAILURES} -eq 0 ]; then
    echo "All checks passed."
    exit 0
else
    echo "${FAILURES} check(s) failed."
    exit 1
fi
