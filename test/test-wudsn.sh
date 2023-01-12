#!/bin/bash

TEST_DIR=../out/wudsn

if [[ "$OSTYPE" == "darwin"* ]]; then
  PROGRAM=wudsn.sh
else
  PROGRAM=wudsn-linux.sh
fi

mkdir -p $TEST_DIR

cp ../$PROGRAM $TEST_DIR
pushd $TEST_DIR >/dev/null

# SITE_URL=http://localhost:8080
# WUDSN_VERSION=daily
./$PROGRAM $@

popd >/dev/null
