#/usr/bin/bash
#
# Test script to install both standard versions inside an Linux VM.
# Use update-test-wudsn-clean-install.sh to update this script.
#

# Install the version in $WUDSN_VERSION
install_wudsn(){
  echo Installing WUDSN IDE Version $WUDSN_VERSION.
  rm -rf $WUDSN_VERSION
  mkdir $WUDSN_VERSION
  pushd $WUDSN_VERSION

  echo Downloading Installer.
  wget --no-cache $INSTALLER_URL
  chmod u+x $WUDSN_EXECUTABLE
# The following call must not be started with & as it requires password inputs for sudo
  ./$WUDSN_EXECUTABLE
  popd

}

install_wudsn_versions(){
cd ~/jac

WUDSN_EXECUTABLE=wudsn.sh
INSTALLER_URL=https://github.com/peterdell/wudsn-ide-install/raw/main/$WUDSN_EXECUTABLE

rm -rf wudsn
mkdir wudsn
pushd wudsn

WUDSN_VERSION=daily
install_wudsn
WUDSN_VERSION=stable
install_wudsn
popd

}

set -e
install_wudsn_versions
