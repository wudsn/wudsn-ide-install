#/usr/bin/bash
#
# Update script for test-wudsn-clean-install.sh.
#

SCRIPT=test-wudsn-clean-install.sh
echo Updating $SCRIPT
wget https://github.com/peterdell/wudsn-ide-install/raw/main/test/$SCRIPT -O $SCRIPT
chmod u+x $SCRIPT
./$SCRIPT
