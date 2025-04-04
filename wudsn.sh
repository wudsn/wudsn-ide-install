#!/bin/bash
#
# WUDSN IDE Installer - Version 2025-01-03 for macOS and Linux, 64-bit.
# Visit https://www.wudsn.com for the latest version.
# Use https://www.shellcheck.net to validate the .sh script source.
#

#
# Check if string $1 contains string $2
#
# Returns 0 if the specified string contains the specified substring, otherwise returns 1.
#
contains() {
    string="$1"
    substring="$2"
    if test "${string#*"${substring}"}" != "${string}"
    then
        return 0    # $substring is in $string
    else
        return 1    # $substring is not in $string
    fi
}

#
# Print the quoted string "$1" on the screen.
#
print(){
  echo "$1"
}

#
# Display logged error messages and exit the shell.
#
error(){
  echo "ERROR: See messages above and in ${LOG}."
  more <"${LOG}"
  exit 1
}

#
# Append message "$1" to the log.
#
log_message(){
  echo "$1" >>"${LOG}"

}

#
# Display progress activity "$1".
#
begin_progress(){
  echo "$1"
  log_message "$1"
}


#
# Display progress message "$1".
#
display_progress(){
  log_message "$1"
}

#
# Create the folder "$1" including intermediate folders.
#
create_folder(){
  mkdir -p "$1"
}

#
# Remove the folder "$1" and its contents if it exists.
#
remove_folder(){
  if [ -d "$1" ]; then
    display_progress "Removing folder $1."
    rm -rf "$1"
    if [ -d "$1" ]; then
      display_progress "ERROR: Cannot remove folder $1"
      error
    fi
  fi
}

#
# Install package $1.
#
install_package(){
  local REQUIRED_PKG=$1
  local PKG_OK
  set +e
  PKG_OK=$(dpkg-query -W --showformat='${Status}\n' "${REQUIRED_PKG}"|grep "install ok installed")
  set -
  display_progress "Checking for package ${REQUIRED_PKG}: ${PKG_OK}"
  if [ "" = "${PKG_OK}" ]; then
    display_progress "Installing required package ${REQUIRED_PKG}."
    sudo apt-get --yes install "${REQUIRED_PKG}"
  fi
}

#
# Install missing commands.
#
install_commands(){
  if ! command -v curl &> /dev/null
  then
    install_package curl
  fi
}

#
# Download a .zip file and unpack to target folder.
# Usage: download repo <filename> <url> <folder> <target_folder> <FAIL|IGNORE>
#
download(){
  local FILE=$1
  local URL=$2
  local FOLDER=$3
  local TARGET_FOLDER=$4
  local TARGET=${TARGET_FOLDER}/${FOLDER}
  # MODE is currently unused
  # local MODE=$5

  if [ ! -f "${FILE}" ]; then
    display_progress "Downloading ${FILE} from ${URL}."
    curl --silent --show-error  --location "${URL}" --output "${FILE}"
  else
    display_progress "File ${FILE} is present."
  fi

  if [ -d "${TARGET}" ]; then
    remove_folder "${TARGET}"
  fi
  create_folder "${TARGET_FOLDER}"

  case "${FILE}" in
    *.tar.gz )
      display_progress "Unpacking ${FILE} to ${TARGET_FOLDER}."
      tar -xf "${FILE}" -C "${TARGET_FOLDER}" >>"${LOG}" 2>>"${LOG}"
      ;;

    *.zip )
      display_progress "Unpacking ${FILE} to ${TARGET_FOLDER}."
      unzip -q "${FILE}" -d "${TARGET_FOLDER}" >>"${LOG}" 2>>"${LOG}"
      ;;
  esac 
}




#
# Download a git repo main branch and unpack to target folder.
# Usage: download repo <repo> <target_folder>
#
download_repo(){
  local REPO=$1
  local BRANCH=main
  local REPO_BRANCH=${REPO}-${BRANCH}
  local REPO_FILE=${REPO_BRANCH}.zip
  local REPO_URL=https://github.com/wudsn/${REPO}/archive/refs/heads/${BRANCH}.zip
  local REPO_TARGET_FOLDER=$2
  
  display_progress "Downloading repository ${REPO} to ${REPO_TARGET_FOLDER}."
  download "${REPO_FILE}" "${REPO_URL}" "${REPO_BRANCH}" "${INSTALL_FOLDER}" IGNORE

  local REPO_BRANCH_FOLDER=${INSTALL_FOLDER}/${REPO_BRANCH}

  display_progress "Copying files to ${REPO_TARGET_FOLDER}."
  create_folder "${REPO_TARGET_FOLDER}"
  cp -p -R "${REPO_BRANCH_FOLDER}"/* "${REPO_TARGET_FOLDER}" >>"${LOG}" 2>>"${LOG}"
  remove_folder "${REPO_BRANCH_FOLDER}"
}

# 
# Check that the workspace is unlocked.
#
check_workspace_lock(){
  local WORKSPACE_LOCK=${WORKSPACE_FOLDER}/.metadata/.lock
  if [ -f "${WORKSPACE_LOCK}" ]; then
     rm "${WORKSPACE_LOCK}" 2>>"${LOG}"
  fi
  while [ -f "${WORKSPACE_LOCK}" ]
  do
    echo "ERROR: Workspace ${WORKSPACE_FOLDER} is locked. Close Eclipse first."
    read -r
  done
}

#
# Select install mode.
#
select_install_mode(){
  INSTALL_MODE=$1
  
  if [ "${INSTALL_MODE}" = "--install-all-from-server" ]; then
    return
  fi

  if [ "${INSTALL_MODE}" = "" ]; then
    if [ ! -d "${PROJECTS_FOLDER}" ]; then
      INSTALL_MODE="--install-all-from-server"
      return
    fi

    if [ ! -d "${INSTALL_FOLDER}" ]; then
      INSTALL_MODE="--install"
      return
    fi
  fi
  
  if [ "${INSTALL_MODE}" = "--install-ide-from-cache" ]; then
    return
  fi
  if [ "${INSTALL_MODE}" = "--install-ide-from-server" ]; then
    return
  fi
  if [ "${INSTALL_MODE}" = "--install-workspace" ]; then
    return
  fi
  if [ -d "${ECLIPSE_APP_FOLDER}" ] && [ "${INSTALL_MODE}" = "--start-eclipse" ]; then
    return
  fi

  if [ "${INSTALL_MODE}" = "--install" ]; then
    display_install_menu
    return
  fi
  
  if [ ! "${INSTALL_MODE}" = "" ]; then
     print "ERROR: Invalid install mode '${INSTALL_MODE}'. Use on of these options."
     print "wudsn.sh --install-ide-from-cache|--install-ide-from-server|--install-all-from-server|--install-workspace|--start-eclipse"
     echo 
     display_install_menu
     return
  fi
  
  if [ -d "${ECLIPSE_APP_FOLDER}" ]; then
    INSTALL_MODE="--start-eclipse"
  fi
}

#
# Display the installer menu and prompt the user for selection.
#
display_install_menu(){
  print "WUDSN IDE Installer"
  print "==================="
  echo
  print "Close all open Eclipse processes."
  print "Select your option to reinstall the ${WUDSN_VERSION} version of WUDSN IDE in ${WUDSN_FOLDER}"

  while(true)
  do
    echo "1) Delete IDE, then install IDE from local cache"
    echo "2) Delete local cache and IDE, then install IDE from server"
    echo "3) Delete local cache, IDE, projects and workspace, then install everything from server"
    echo "s) Start WUDSN IDE"
    echo "x) Exit installer"
    echo
    echo -n "Your choice: "
    read -r ID
    case ${ID} in
    
      "1")
      INSTALL_MODE="--install-ide-from-cache"
      return;;
      
      "2")
      INSTALL_MODE="--install-ide-from-server"
      return;;
    
      "3")
      INSTALL_MODE="--install-all-from-server"
      return ;;
      
      "s")
      INSTALL_MODE="--start-eclipse"
      return ;;
    
      "x")
      exit 0
    esac
  done
}

#
# Install tools.
#
install_tools(){
  begin_progress "Installing Tools."
  TOOLS_FOLDER=$1
  download_repo wudsn-ide-tools "${TOOLS_FOLDER}"
}

#
# Install Eclipse.
#
install_eclipse(){
  local ECLIPSE_FILE=$1
  local ECLIPSE_URL=$2
  local ECLIPSE_APP_FOLDER=$3
  local ECLIPSE_MOUNT_FOLDER=$4
  local ECLIPSE_APP_NAME=$5

  if [ -d "${ECLIPSE_APP_FOLDER}" ]; then
    return
  fi

  begin_progress "Installing Eclipse."
  download "${ECLIPSE_FILE}" "${ECLIPSE_URL}" eclipse "${ECLIPSE_APP_FOLDER}" FAIL

  if [ ! "${ECLIPSE_MOUNT_FOLDER}" = "none" ]; then
    display_progress "Mounting ${ECLIPSE_FILE}."
    set +e
    
    if ! hdiutil mount "${ECLIPSE_FILE}" -quiet; then
      hdiutil detach "${ECLIPSE_FILE}"
      exit 1
    fi
    set -e
    rsync -az "${ECLIPSE_MOUNT_FOLDER}"/"${ECLIPSE_APP_NAME}" "${ECLIPSE_APP_FOLDER}"/..
    
    display_progress "Unmounting ${ECLIPSE_FILE}."
    set +e
   
    if ! hdiutil detach "${ECLIPSE_MOUNT_FOLDER}" -force -quiet; then
      hdiutil detach "${ECLIPSE_MOUNT_FOLDER}" -force
      exit 1
    fi
    set -e
    
    # Check is codesign is completely installed.
    if command -v "codesign_allocate" &> /dev/null; then
      # Remove code signing information and add it again to prevent issues when changing files in the folder.
      codesign --remove "${ECLIPSE_APP_FOLDER}"
      xattr -rd com.apple.quarantine "${ECLIPSE_APP_FOLDER}"
      codesign --force --deep --sign - "${ECLIPSE_APP_FOLDER}"
    fi
  fi

  install_wudsn_ide_feature
}

#
# Install Java globally.
#
install_java_globally(){
  JRE_FILE=$1
  JRE_URL=$2
  JRE_FOLDER_NAME=$3
  INSTALL_FOLDER=$4

  begin_progress "Installing Java."
  if [ "${OS_TYPE}" = "linux-gnu"  ]; then
    install_package openjdk-17-jre-headless
  elif [ "${OS_TYPE}" = "darwin"  ]; then
    JRE_JVM_FOLDER=/Library/Java/JavaVirtualMachines
    JRE_TARGET_FOLDER=${JRE_JVM_FOLDER}/${JRE_FOLDER_NAME}
    if [ ! -d "${JRE_TARGET_FOLDER}" ]; then
      download "${JRE_FILE}" "${JRE_URL}" "${JRE_FOLDER_NAME}" "${INSTALL_FOLDER}" FAIL
      begin_progress "Enter the admin password to install Java version ${JRE_FOLDER_NAME} in ${JRE_TARGET_FOLDER}."
      sudo mv "${JRE_FOLDER_NAME}" ${JRE_JVM_FOLDER}
    else
      begin_progress "Java version ${JRE_FOLDER_NAME} is already installed in ${JRE_TARGET_FOLDER}."
    fi

  else
    display_progress "ERROR: Unsupported operating system '${OS_TYPE}'"
    exit 1
  fi
}

#
# Install WUDSN IDE feature.
#
install_wudsn_ide_feature(){
  begin_progress "Installing WUDSN IDE feature."
  # See http://help.eclipse.org/latest/index.jsp?topic=/org.eclipse.platform.doc.isv/guide/p2_director.html
  ${ECLIPSE_EXECUTABLE} -nosplash -application org.eclipse.equinox.p2.director -repository "${UPDATE_URL}" -installIU com.wudsn.ide.feature.feature.group -destination "$ECLIPSE_DESTINATION_FOLDER" >>"${LOG}" 2>>"${LOG}"
}



#
# Install projects.
#
install_projects(){
  PROJECTS_FOLDER=$1
  if [ ! -d "${PROJECTS_FOLDER}" ]; then
    begin_progress "Installing Projects."
    download_repo wudsn-ide-projects "${PROJECTS_FOLDER}"
  fi
}

#
# Create an Eclipse preferences file.
#
create_prefs(){
  PREFS=${SETTINGS_FOLDER}/$1
  echo eclipse.preferences.version=1>"${PREFS}"
}

#
# Create the workspace folder and initialize its preferences.
#
create_workspace_folder(){
  WORKSPACE_FOLDER=$1
  if [ -d "${WORKSPACE_FOLDER}" ]; then
    return
  fi
  display_progress "Installing WUDSN defaults for workspace ${WORKSPACE_FOLDER}."
  create_folder "${WORKSPACE_FOLDER}"

  SETTINGS_FOLDER=${WORKSPACE_FOLDER}/.metadata/.plugins/org.eclipse.core.runtime/.settings
  create_folder "${SETTINGS_FOLDER}"

  create_prefs org.eclipse.ui.ide.prefs
  RECENT_WORKSPACES=${WORKSPACE_FOLDER}
  { echo "MAX_RECENT_WORKSPACES=10"
  echo "RECENT_WORKSPACES=${RECENT_WORKSPACES}"
  echo "RECENT_WORKSPACES_PROTOCOL=3"
  echo "SHOW_RECENT_WORKSPACES=false"
  echo "SHOW_WORKSPACE_SELECTION_DIALOG=false"
  } >>"${PREFS}"
  
  create_prefs org.eclipse.ui.editors.prefs
  echo "tabWidth=8">>"${PREFS}"
  
  create_prefs org.eclipse.ui.prefs
  echo "showIntro=false">>"${PREFS}"

  # WORKSPACE_CREATED is currently unused
  # WORKSPACE_CREATED=1
}


#
# Start Eclipse in new process.
#
start_eclipse(){
  trap "" EXIT
  begin_progress "Starting WUDSN IDE. Close this window when starting has finished."
  echo "Starting ${ECLIPSE_EXECUTABLE}" >"${ECLIPSE_LOG}"
  "${ECLIPSE_EXECUTABLE}" -data "${WORKSPACE_FOLDER}" </dev/null >>"${ECLIPSE_LOG}" 2>>"${ECLIPSE_LOG}" &
  sleep 30
}






#
# Handle install mode. 
#
handle_install_mode(){
  if [ "${INSTALL_MODE}" = "--start-eclipse" ]; then
      start_eclipse
      exit 0
  elif [ "${INSTALL_MODE}" = "--install-all-from-server" ]; then
      begin_progress "Starting full installation of ${WUDSN_VERSION} version from server ${SITE_URL}."
      remove_folder "${WORKSPACE_FOLDER}"
      remove_folder "${PROJECTS_FOLDER}"
      remove_folder "${INSTALL_FOLDER}"
      remove_folder "${TOOLS_FOLDER}"
  elif [ "${INSTALL_MODE}" = "--install-ide-from-server" ]; then
      begin_progress "Starting IDE installation ${WUDSN_VERSION} version from server ${SITE_URL}."
      remove_folder "${INSTALL_FOLDER}"
      remove_folder "${TOOLS_FOLDER}"
  elif [ "${INSTALL_MODE}" = "--install-ide-from-cache" ]; then
      begin_progress "Starting IDE installation from local cache."
      remove_folder "${TOOLS_FOLDER}"
  elif [ "${INSTALL_MODE}" = "--install-workspace" ]; then
      begin_progress "Starting workspace installation."
      remove_folder "${WORKSPACE_FOLDER}"
      remove_folder "${PROJECTS_FOLDER}"
  else
    display_progress "ERROR: Invalid install mode '${INSTALL_MODE}'."
    exit 1
  fi
}

#
# Detect the OS type and architecture and set dependent variables.
#
detect_os_type(){

# https://archive.eclipse.org/eclipse/downloads/drops4/R-4.34-202411201800/
  ECLIPSE_VERSION=4.34
  ECLIPSE_FILES=( "eclipse-platform-${ECLIPSE_VERSION}-linux-gtk-aarch64.tar.gz"
                  "eclipse-platform-${ECLIPSE_VERSION}-linux-gtk-x86_64.tar.gz"
                  "eclipse-platform-${ECLIPSE_VERSION}-macosx-cocoa-aarch64.dmg"
                  "eclipse-platform-${ECLIPSE_VERSION}-macosx-cocoa-x86_64.dmg"
                  "eclipse-platform-${ECLIPSE_VERSION}-win32-x86_64.zip")
  
  # https://jdk.java.net/archive/
  JRE_VERSION=23.0.1
  JRE_FILES=("openjdk-${JRE_VERSION}_linux-aarch64_bin.tar.gz"
             "openjdk-${JRE_VERSION}_linux-x64_bin.tar.gz"
             "openjdk-${JRE_VERSION}_macos-aarch64_bin.tar.gz"
             "openjdk-${JRE_VERSION}_macos-x64_bin.tar.gz"
             "openjdk-${JRE_VERSION}_windows-x64_bin.zip")

  # Map OS type and host type to own codes.
  OS_TYPE="unknown"
  OS_INDEX=0
  
  case "${OSTYPE}" in
    linux-gnu)
      OS_TYPE=linux-gnu
      if [ "${HOSTTYPE}" = "x86_64" ]; then
        OS_INDEX=1
      fi
      ;;
    darwin*) 
      OS_TYPE=darwin
      if [ "${HOSTTYPE}" = "arm64" ]; then
        OS_INDEX=2
      elif [ "${HOSTTYPE}" = "x86_64" ]; then
        OS_INDEX=3
      fi
      ;;
  esac

  if [ -z "${OS_INDEX}" ]; then
    echo "ERROR: Unsupported operating system '${OSTYPE}' and host type '${HOSTTYPE}' combination."
    exit 1
  fi

  ECLIPSE_FILE=${ECLIPSE_FILES[${OS_INDEX}]}
  ECLIPSE_URL=${DOWNLOADS_URL}/${ECLIPSE_FILE}
  ECLIPSE_FOLDER=$TOOLS_FOLDER/IDE/Eclipse
  ECLIPSE_LOG=${SCRIPT_FOLDER}/eclipse.log
  if [ -f "${ECLIPSE_LOG}" ]; then
    rm "${ECLIPSE_LOG}"
  fi

  if [ "${OS_TYPE}" = "linux-gnu" ]; then
    ECLIPSE_MOUNT_FOLDER=none
    ECLIPSE_APP_NAME=eclipse
    ECLIPSE_APP_FOLDER=${ECLIPSE_FOLDER} 
    ECLIPSE_RUNTIME_FOLDER=${ECLIPSE_APP_FOLDER}/${ECLIPSE_APP_NAME}  
    ECLIPSE_EXECUTABLE=${ECLIPSE_RUNTIME_FOLDER}/${ECLIPSE_APP_NAME}
    # Folder containing the p2 repository
    ECLIPSE_DESTINATION_FOLDER=${ECLIPSE_RUNTIME_FOLDER}
  elif [ "${OS_TYPE}" = "darwin" ]; then
    ECLIPSE_MOUNT_FOLDER=/Volumes/Eclipse
    ECLIPSE_APP_NAME=Eclipse.app
    ECLIPSE_APP_FOLDER=${ECLIPSE_FOLDER}/${ECLIPSE_APP_NAME}
    ECLIPSE_RUNTIME_FOLDER=${ECLIPSE_APP_FOLDER}/Contents
    ECLIPSE_EXECUTABLE=${ECLIPSE_RUNTIME_FOLDER}/MacOS/eclipse
    # Folder containing the p2 repository
    ECLIPSE_DESTINATION_FOLDER=${ECLIPSE_RUNTIME_FOLDER}/Eclipse
  fi

  JRE_FILE=${JRE_FILES[${OS_INDEX}]}
  JRE_URL=${DOWNLOADS_URL}/${JRE_FILE}
  JRE_FOLDER_NAME=jdk-${JRE_VERSION}.jdk
}

#
# Main function.
#
main(){
  SCRIPT_FOLDER="$( cd -- "$( dirname -- "${0}" )" &> /dev/null && pwd )"
  LOG=${SCRIPT_FOLDER}/wudsn.log
  date >"${LOG}"
  begin_progress "Checking installation in ${SCRIPT_FOLDER}."
  
  WUDSN_FOLDER=${SCRIPT_FOLDER}
  INSTALL_FOLDER=${WUDSN_FOLDER}/Install
  TOOLS_FOLDER=${WUDSN_FOLDER}/Tools
  PROJECTS_FOLDER=${WUDSN_FOLDER}/Projects
  WORKSPACE_FOLDER=${WUDSN_FOLDER}/Workspace
  
  if [ "${SITE_URL}" = "" ]; then
    SITE_URL=https://www.wudsn.com
  fi
  
  if [ "${WUDSN_VERSION}" = "" ]; then
    WUDSN_VERSION=stable
  fi

  DOWNLOADS_URL=${SITE_URL}/productions/java/ide/downloads
  UPDATE_URL=${SITE_URL}/update/${WUDSN_VERSION}

  detect_os_type
  check_workspace_lock
  select_install_mode "$1"
  handle_install_mode

  log_message "Environment variables:"
  set -o posix; set >>"${LOG}"; set +o posix
  
  create_folder "${INSTALL_FOLDER}"
  pushd "${INSTALL_FOLDER}" >>"${LOG}"

  install_commands
  install_java_globally "${JRE_FILE}" "${JRE_URL}" "${JRE_FOLDER_NAME}" "${INSTALL_FOLDER}"
  install_tools "${TOOLS_FOLDER}"
  install_eclipse "${ECLIPSE_FILE}" "${ECLIPSE_URL}" "${ECLIPSE_APP_FOLDER}" "${ECLIPSE_MOUNT_FOLDER}" "${ECLIPSE_APP_NAME}" 
  install_projects "${PROJECTS_FOLDER}"
  create_workspace_folder "${WORKSPACE_FOLDER}"
  
  popd >>"${LOG}"

  start_eclipse
}

#
# Main script
#

trap "error" EXIT
set -e
#set -x
main "$@"
