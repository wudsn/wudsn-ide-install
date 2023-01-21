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
  chmod a+x $WUDSN_EXECUTABLE

# The following call must not be started in a new window, so sudo password inputs work and exits are ignored
  nohup gnome-terminal -- ./$WUDSN_EXECUTABLE &
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