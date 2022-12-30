#!/bin/bash

TEST_DIR=../out/wudsn
PROGRAM=wudsn.sh

mkdir -p $TEST_DIR

cp ../$PROGRAM $TEST_DIR
pushd $TEST_DIR >/dev/null

# SITE_URL=http://localhost:8080
# WUDSN_VERSION=daily
./$PROGRAM $@

popd >/dev/null
