#!/bin/bash

# Copyright (c) 2015-present, salesforce.com, inc. All rights reserved.
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
# Script to keep Package.swift in sync when Swift or Objective-C source files are added or removed.
# Run as a post-build script from an Xcode project, or manually after adding/removing source files.
#
# Usage:
#   update_package_swift.sh -l <LibraryName> [--check]
#
# Where <LibraryName> is one of: SalesforceSDKCommon, SalesforceAnalytics, SalesforceSDKCore,
#                                 SmartStore, MobileSync
#
# Options:
#   --check   Dry-run mode. Exits 0 if Package.swift is already in sync, exits 1 if it
#             would be changed. Useful in CI to catch forgotten updates.
#
# The script:
#   1. Scans the library's Classes/ directory for .swift files.
#   2. Computes which .swift files belong in the ObjC target's `exclude:` list
#      and which belong in the paired Swift target's `sources:` list.
#   3. Rewrites both sections in Package.swift (between sentinel comments).
#
# The Package.swift must contain sentinel comments of the form:
#   // BEGIN_SWIFT_EXCLUDE <LibraryName>
#   // END_SWIFT_EXCLUDE <LibraryName>
#   // BEGIN_SWIFT_SOURCES <LibraryName>
#   // END_SWIFT_SOURCES <LibraryName>
#

set -e

LIBRARY_NAME=""
CHECK_MODE=0

function usage() {
    local appName
    appName=$(basename "$0")
    echo "Usage:"
    echo "  $appName -l <LibraryName> [--check]"
    echo ""
    echo "LibraryName must be one of: SalesforceSDKCommon, SalesforceAnalytics,"
    echo "  SalesforceSDKCore, SmartStore, MobileSync"
    echo ""
    echo "Options:"
    echo "  --check   Dry-run mode. Exit 0 if in sync, exit 1 if update needed."
}

function parseOpts() {
    # Extract --check before getopts (which doesn't handle long options)
    local args=()
    for arg in "$@"; do
        if [ "$arg" = "--check" ]; then
            CHECK_MODE=1
        else
            args+=("$arg")
        fi
    done
    set -- "${args[@]}"

    while getopts :l: commandLineOpt; do
        case ${commandLineOpt} in
            l)
                LIBRARY_NAME=${OPTARG};;
            ?)
                echo "Unknown option '-${OPTARG}'."
                usage
                exit 1
        esac
    done

    if [ -z "${LIBRARY_NAME}" ]; then
        echo "No library name specified."
        usage
        exit 2
    fi
}

parseOpts "$@"

# Resolve repo root (four levels up from this script's location)
REPO_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../../../.. && pwd)
PACKAGE_FILE="${REPO_DIR}/Package.swift"
LIB_CLASSES_DIR="${REPO_DIR}/libs/${LIBRARY_NAME}/${LIBRARY_NAME}/Classes"

if [ ! -f "${PACKAGE_FILE}" ]; then
    echo "Package.swift not found at ${PACKAGE_FILE}"
    exit 3
fi

if [ ! -d "${LIB_CLASSES_DIR}" ]; then
    echo "Classes directory not found: ${LIB_CLASSES_DIR}"
    exit 4
fi

# Collect all .swift files relative to the Classes/ directory, excluding SPM/ wrappers
SWIFT_FILES=$(find "${LIB_CLASSES_DIR}" -name "*.swift" -not -path "*/SPM/*" | \
    sed "s|${LIB_CLASSES_DIR}/||" | \
    sort)

if [ -z "${SWIFT_FILES}" ]; then
    echo "No Swift files found in ${LIB_CLASSES_DIR} — nothing to update."
    exit 0
fi

# Build the exclude list (paths relative to the library source root, prefixed with Classes/)
EXCLUDE_LINES=""
while IFS= read -r f; do
    EXCLUDE_LINES="${EXCLUDE_LINES}                \"Classes/${f}\","$'\n'
done <<< "${SWIFT_FILES}"
# Remove trailing comma+newline from last entry
EXCLUDE_LINES=$(echo "${EXCLUDE_LINES}" | sed '$ s/,$//')

# Build the sources list (paths prefixed with Classes/)
SOURCE_LINES=""
while IFS= read -r f; do
    SOURCE_LINES="${SOURCE_LINES}                \"Classes/${f}\","$'\n'
done <<< "${SWIFT_FILES}"
SOURCE_LINES=$(echo "${SOURCE_LINES}" | sed '$ s/,$//')

# Replace the section between sentinel comments using awk
replace_section() {
    local begin_sentinel="$1"
    local end_sentinel="$2"
    local new_content="$3"
    local file="$4"
    local output="$5"
    local content_file
    content_file=$(mktemp)
    printf '%s' "${new_content}" > "${content_file}"

    awk -v begin="${begin_sentinel}" -v end="${end_sentinel}" -v cfile="${content_file}" '
        $0 ~ begin { print; in_section=1; while ((getline line < cfile) > 0) print line; close(cfile); next }
        $0 ~ end   { in_section=0 }
        !in_section { print }
    ' "${file}" > "${output}"
    rm -f "${content_file}"
}

SWIFT_FILE_COUNT=$(echo "${SWIFT_FILES}" | wc -l | tr -d ' ')

if [ ${CHECK_MODE} -eq 1 ]; then
    # Dry-run: generate into a temp file and compare
    TEMP_FILE=$(mktemp)
    trap 'rm -f "${TEMP_FILE}" "${TEMP_FILE}.2"' EXIT

    replace_section \
        "// BEGIN_SWIFT_EXCLUDE ${LIBRARY_NAME}" \
        "// END_SWIFT_EXCLUDE ${LIBRARY_NAME}" \
        "${EXCLUDE_LINES}" \
        "${PACKAGE_FILE}" \
        "${TEMP_FILE}"

    replace_section \
        "// BEGIN_SWIFT_SOURCES ${LIBRARY_NAME}" \
        "// END_SWIFT_SOURCES ${LIBRARY_NAME}" \
        "${SOURCE_LINES}" \
        "${TEMP_FILE}" \
        "${TEMP_FILE}.2"

    if diff -q "${PACKAGE_FILE}" "${TEMP_FILE}.2" > /dev/null 2>&1; then
        echo "Package.swift is in sync for ${LIBRARY_NAME} (${SWIFT_FILE_COUNT} Swift files)"
        exit 0
    else
        echo "Package.swift is OUT OF SYNC for ${LIBRARY_NAME}. Run without --check to fix."
        diff "${PACKAGE_FILE}" "${TEMP_FILE}.2" || true
        exit 1
    fi
else
    replace_section \
        "// BEGIN_SWIFT_EXCLUDE ${LIBRARY_NAME}" \
        "// END_SWIFT_EXCLUDE ${LIBRARY_NAME}" \
        "${EXCLUDE_LINES}" \
        "${PACKAGE_FILE}" \
        "${PACKAGE_FILE}.tmp"

    mv "${PACKAGE_FILE}.tmp" "${PACKAGE_FILE}"

    replace_section \
        "// BEGIN_SWIFT_SOURCES ${LIBRARY_NAME}" \
        "// END_SWIFT_SOURCES ${LIBRARY_NAME}" \
        "${SOURCE_LINES}" \
        "${PACKAGE_FILE}" \
        "${PACKAGE_FILE}.tmp"

    mv "${PACKAGE_FILE}.tmp" "${PACKAGE_FILE}"

    echo "Package.swift updated for ${LIBRARY_NAME} (${SWIFT_FILE_COUNT} Swift files)"
fi
