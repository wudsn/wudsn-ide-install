#!/bin/bash
#
# Update script for test-wudsn-clean-install.sh.
#

cd ~/jac || exit
SCRIPT=test-wudsn-clean-install.sh
echo Updating $SCRIPT
wget "https://github.com/peterdell/wudsn-ide-install/raw/main/test/${SCRIPT}" -O "${SCRIPT}"
chmod a+x "${SCRIPT}"
bash "${SCRIPT}"
sleep 1
