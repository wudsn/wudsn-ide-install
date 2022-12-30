#!/bin/bash

TEST_DIR=../out/wudsn
PROGRAM=wudsn.sh

if [ ! -d $TEST_DIR ];
then mkdir $TEST_DIR
fi

cp ../$PROGRAM $TEST_DIR
pushd $TEST_DIR || return

# SITE_URL=http://localhost:8080
# WUDSN_VERSION=daily
powershell.exe ./$PROGRAM %*

popd || return
