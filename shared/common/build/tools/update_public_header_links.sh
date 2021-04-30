#!/bin/bash

# Copyright (c) 2021-present, salesforce.com, inc. All rights reserved.
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
# Script to add links to public headers in include directory of each library.
# This is needed for Swift Package Manager.
#

# set -x
set -e

repoDir=$(cd "$(dirname ${BASH_SOURCE[0]})" && cd ../../../.. && pwd)
publicHeaderDirectory="${TARGET_BUILD_DIR}/${PUBLIC_HEADERS_FOLDER_PATH}"
includeDir="${repoDir}/libs/${PROJECT_NAME}/${PROJECT_NAME}/include/${PROJECT_NAME}"
projectDir=`echo "${PROJECT_DIR}" | sed "s#${repoDir}/##g"`

cd "$repoDir"

# Updating links
for file in $(find $includeDir -type l); do
    rm "${file}"
done

for headerFile in `ls -1 "${publicHeaderDirectory}"`; do
	repoHeaderFile=`find ${projectDir} -name $headerFile -not -path "*/include/*"`
	if [ "$repoHeaderFile" != "" ]; then
        ln -s "../../../../../${repoHeaderFile}" "${includeDir}/"
	fi
done


