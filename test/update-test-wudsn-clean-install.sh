#!/bin/bash
#
# Update script for test-wudsn-clean-install.sh.
# Installation steps of wudsn-ide-install is locally available:
# cd ~/jac
# ln -s ~/jac/system/Java/Programming/Repositories/wudsn-ide-install/test/update-test-wudsn-clean-install.sh
#

# Download executable file from URL $1 to $2.
download_executable(){
  if -f "$2";
  then
  	rm -f "$2"
  fi
  if command -v curl &> /dev/null
  then
    curl --location "$1" --output "$2"
  else
    if command -v wget &> /dev/null
    then
      wget --no-cache "$1" -O "$2"
    else
      echo ERROR: Neither curl nor wget are installed.
      exit 1
    fi
  fi
  chmod a+x "$2"
}

set -e
cd ~/jac || exit
SCRIPT=test-wudsn-clean-install.sh
URL=https://github.com/peterdell/wudsn-ide-install/raw/main/test/${SCRIPT}

echo Updating ${SCRIPT} from ${URL}.

if command -v curl &> /dev/null
then
  curl --location "${URL}" --output "${SCRIPT}"
else
  if command -v wget &> /dev/null
  then
    wget --no-cache "${URL}" -O "${SCRIPT}"
  else
    echo ERROR: Neither curl nor wget are installed.
    exit 1
  fi
fi
chmod a+x "${SCRIPT}"
bash "${SCRIPT}"
sleep 1
