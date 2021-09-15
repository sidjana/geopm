#!/bin/bash
#  Copyright (c) 2015 - 2021, Intel Corporation
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions
#  are met:
#
#      * Redistributions of source code must retain the above copyright
#        notice, this list of conditions and the following disclaimer.
#
#      * Redistributions in binary form must reproduce the above copyright
#        notice, this list of conditions and the following disclaimer in
#        the documentation and/or other materials provided with the
#        distribution.
#
#      * Neither the name of Intel Corporation nor the names of its
#        contributors may be used to endorse or promote products derived
#        from this software without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
#  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY LOG OF THE USE
#  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

# Simple script that will build and test both the base and the service.
# Example invocation:
#   git clean -ffdx && RUN_TESTS=yes ./build.sh

set -e

# This script must be run from the root of the GEOPM repo.
source integration/config/build_env.sh

# Clear out old builds
if [ -d "${GEOPM_INSTALL}" ]; then
    echo "Removing old build located at ${GEOPM_INSTALL}"
    rm -rf ${GEOPM_INSTALL}
fi

# e.g. To do a debug build, add --enable-debug to this env var
GEOPM_GLOBAL_CONFIG_OPTIONS="${GEOPM_GLOBAL_CONFIG_OPTIONS} --prefix=${GEOPM_INSTALL}"

# Set this variable to append configure options for base build
GEOPM_BASE_CONFIG_OPTIONS="${GEOPM_GLOBAL_CONFIG_OPTIONS}"

# Set this variable to append configure options for service build
GEOPM_SERVICE_CONFIG_OPTIONS="${GEOPM_GLOBAL_CONFIG_OPTIONS}"

NUM_THREAD=${NUM_THREAD:-9}

build(){
    if [ ! -f "configure" ]; then
        ./autogen.sh
    fi

    mkdir -p build # Objects created at configure time will go here
    cd build

    if [ ! -f "Makefile" ]; then
        ../configure ${1}
    fi
    make -j${NUM_THREAD}

    # By default, the tests are skipped
    if [ ! -z ${RUN_TESTS+x} ]; then
        make -j${NUM_THREAD} checkprogs
        make check
    fi

    # By default, make install is called
    if [ -z ${SKIP_INSTALL+x} ]; then
        make install
    fi
}


# Run the service build
cd service
CC=gcc CXX=g++ build ${GEOPM_SERVICE_CONFIG_OPTIONS}

# Run the base build
cd ../.. # PWD here is service/build
if [ -z ${SKIP_INSTALL+x} ]; then
    build "--with-geopmd=${GEOPM_INSTALL} ${GEOPM_BASE_CONFIG_OPTIONS}"
else
    build "--with-geopmd-lib=../service/build/.libs \
           --with-geopmd-include=../service/src \
           ${GEOPM_BASE_CONFIG_OPTIONS}"
fi
