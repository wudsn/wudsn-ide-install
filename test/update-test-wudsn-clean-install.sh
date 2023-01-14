#/usr/bin/bash
#
# Update script for test-wudsn-clean-install.sh.
#

SCRIPT=test-wudsn-clean-install.sh
echo Updating $SCRIPT
wget https://raw.githubusercontent.com/peterdell/wudsn-ide-install/main/$SCRIPT -O $SCRIPT
chmod u+x $SCRIPT
./$SCRIPT
