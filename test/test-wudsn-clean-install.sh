#!/bin/bash
#
# Test script to install both standard versions on macOS or inside a Linux VM.
# Use update-test-wudsn-clean-install.sh to update this script from the server.
#

# Download executable file from URL $1 to $2.
download_executable(){
  if test -f "$2";
  then
  	rm -f "$2"
  fi
  if command -v curl &>/dev/null
  then
    curl --location "$1" --output "$2"
  else
    if command -v wget &>/dev/null
    then
      wget --no-cache "$1" -O "$2"
    else
      echo ERROR: Neither curl nor wget are installed.
      exit 1
    fi
  fi
  chmod a+x "$2"
}

# Install the version in ${WUDSN_VERSION}.
install_wudsn(){
  echo Installing WUDSN IDE Version ${WUDSN_VERSION}.
  rm -rf "${WUDSN_VERSION}"
  mkdir "${WUDSN_VERSION}"
  pushd "${WUDSN_VERSION}"

  echo Downloading Installer.
  download_executable "${INSTALLER_URL}" "${WUDSN_EXECUTABLE}"

# The following call must not be started in a new window, so sudo password inputs work and exits are ignored
  if command -v gnome-terminal &>/dev/null
  then
    gnome-terminal --wait --title "Installing WUDSN version ${WUDSN_VERSION}" -- ./${WUDSN_EXECUTABLE} &
  else
  	open -a Terminal.app -W ${WUDSN_EXECUTABLE}
  fi
  popd

}

install_wudsn_versions(){
  cd ~/jac || exit

  WUDSN_EXECUTABLE=wudsn.sh
  INSTALLER_URL=https://github.com/peterdell/wudsn-ide-install/raw/main/${WUDSN_EXECUTABLE}

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
