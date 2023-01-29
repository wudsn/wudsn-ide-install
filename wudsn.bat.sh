@echo off
#
# WUDSN IDE Installer - Version 2023-01-23 for Windows, 64-bit.
# Visit https://www.wudsn.com for the latest version.
# Use https://www.shellcheck.net to validate the .sh script source.
#

goto main_script

#
# Print the quoted string "$1" on the screen.
#
print
  echo ${~1
  }
  
#
# Display logged error messages and exit the shell.
#
error
  print "ERROR: See messages above and in ${LOG}."
  start notepad.exe "${LOG}"
  pause
  exit 1

#
#  Append message "$1" to the log.
#
log_message
  echo | /p=$1 >>${LOG}
  echo >>${LOG}
  }

#
# Display progress activity "$1".
#
begin_progress
  echo | /p=$1
  echo
  log_message "$1"
  }

#
# Display progress message "$1".
#
display_progress
  log_message "$1"
  }

#
# Create the folder "$1" including intermediate folders.
#
create_folder
  if [ ! -f "$1" ]; then
    mkdir "$1"
  fi
  }

#
# Remove the folder "$1" and its contents if it exists.
#
remove_folder
  if [ -f "$1" ]; then
    display_progress "Removing folder "$1"."
    rmdir /S/Q "$1"
    if [ -f "$1" ]; then
      display_progress "ERROR: Cannot remove folder "$1"."
      error
    fi
  fi
  }

#
# Install missing commands.
#
install_commands
# curl is part of the standard Windows installation.

}

#
# Download a .zip file and unpack to target folder.
# Usage: download repo <filename> <url> <folder> <target_folder> <FAIL|IGNORE>
#
download
  FILE=$1
  URL=$2
  FOLDER=$3
  TARGET_FOLDER=$4
  TARGET=${TARGET_FOLDER}/${FOLDER}
  MODE=$5
  
  if [ ! -f "${FILE}" ]; then
    display_progress "Downloading ${FILE} from ${URL}."
    curl --silent --show-error --location ${URL} --output ${FILE}
  fi else {
    display_progress "File ${FILE} is present."
  fi
  
  if [ -f "${TARGET}" ]; then
    remove_folder ${TARGET}
  fi
  create_folder ${TARGET_FOLDER}
  
  display_progress "Unpacking ${FILE} to ${TARGET_FOLDER}."
  tar -xf ${FILE} -C ${TARGET_FOLDER} 2>>${LOG}
  if ERRORLEVEL 1 {
     if [ "${MODE}" = "FAIL" ]; then
       error
     fi
  fi
  }

#
# Download a git repo main branch and unpack to target folder.
# Usage: download repo <repo> <target_folder>
#
download_repo
  REPO=$1
  BRANCH=main
  REPO_BRANCH=${REPO}-${BRANCH}
  REPO_FILE=${REPO_BRANCH}.zip
  REPO_URL=https://github.com/peterdell/${REPO}/archive/refs/heads/${BRANCH}.zip
  REPO_TARGET_FOLDER=$2

  display_progress "Downloading repo ${REPO} to ${REPO_TARGET_FOLDER}."
  download ${REPO_FILE} ${REPO_URL} ${REPO_BRANCH} ${INSTALL_FOLDER} IGNORE

  REPO_BRANCH_FOLDER=${INSTALL_FOLDER}/${REPO_BRANCH}

  display_progress "Copying files to ${REPO_TARGET_FOLDER}."
  create_folder ${REPO_TARGET_FOLDER}
  xcopy /E /R /Y /Q ${REPO_BRANCH}/*.* ${REPO_TARGET_FOLDER} >>${LOG}
  remove_folder ${REPO_BRANCH_FOLDER}
  }


# 
# Check that the workspace is unlocked.
#
check_workspace_lock
  WORKSPACE_LOCK=${WORKSPACE_FOLDER}/.metadata/.lock
  workspace_locked
  if [ -f ${WORKSPACE_LOCK}. del ${WORKSPACE_LOCK} 2>>${LOG}
  if [ -f ${WORKSPACE_LOCK} {
    print "ERROR: Workspace ${WORKSPACE_FOLDER} is locked. Close Eclipse first."
    pause
    goto workspace_locked
  fi
  }



#
# Select install mode.
#
select_install_mode
  INSTALL_MODE=$1

  if [ "${INSTALL_MODE}" = "--install-all-from-server" ]; then
    return
  fi

  if [ "${INSTALL_MODE}" = "" ]; then
    if [ ! -f "${PROJECTS_FOLDER}" ]; then
      INSTALL_MODE=--install-all-from-server
      return
    elif [ ! -f "${INSTALL_FOLDER}" ]; then
      INSTALL_MODE=--install
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

  if [ -f "${ECLIPSE_APP_FOLDER}" ]; then
    if [ "${INSTALL_MODE}" = "--start-eclipse" ]; then
      return
    fi
  fi

  if [ "${INSTALL_MODE}" = "--install" ]; then
    display_install_menu
    return
  fi
  
  if not "${INSTALL_MODE}" = "" ]; then
     print "ERROR: Invalid install mode '%INSTALL_MODE%'. Use one of these options."
     echo wudsn.exe --install-ide-from-cache^|--install-ide-from-server^|--install-all-from-server^|--install-workspace^|--start-eclipse
     echo
     display_install_menu
     return
  fi
  
  if [ -f "${ECLIPSE_APP_FOLDER}" ]; then
    INSTALL_MODE=--start-eclipse
  fi

  }

#
# Display the installer menu and prompt the user for selection.
#
display_install_menu
  print "WUDSN IDE Installer"
  print "==================="
  echo
  print "Close all open Eclipse processes."
  print "Select your option to reinstall the ${WUDSN_VERSION} version of WUDSN IDE in ${WUDSN_FOLDER}"
  
  choose_install_mode
  print "1) Delete IDE, then install IDE from local cache"
  print "2) Delete local cache and IDE, then install IDE from server"
  print "3) Delete local cache, IDE, projects and workspace, then install everything from server"
  print "s) Start WUDSN IDE"
  print "x) Exit installer"
  ID=
  /p ID="Your choice: "
  if [ "${ID}" = "1" ]; then
    INSTALL_MODE=--install-ide-from-cache
    return

  elif [ "${ID}" = "2" ]; then
    INSTALL_MODE=--install-ide-from-server
    return

  elif [ "${ID}" = "3" ]; then
    INSTALL_MODE=--install-all-from-server
    return

  elif [ "${ID}" = "s" ]; then
    INSTALL_MODE=--start_eclipse
    return

  elif [ "${ID}" = "x" ]; then
    exit 0
  fi
  goto choose_install_mode




#
# Install tools.
#
install_tools
  begin_progress "Installing Tools."
  TOOLS_FOLDER=$1
  download_repo wudsn-ide-tools ${TOOLS_FOLDER}
  }

#
# Install Eclipse.
#
install_eclipse
  ECLIPSE_APP_FOLDER=$1
  if [ -f "${ECLIPSE_APP_FOLDER}" ]; then
    return
  fi
  begin_progress "Installing Eclipse."
  download ${ECLIPSE_FILE} ${ECLIPSE_URL} ${ECLIPSE_FOLDER_NAME} ${ECLIPSE_APP_FOLDER} FAIL
  if ERRORLEVEL 1 {
    error
  fi
  install_java
  install_wudsn_ide_feature
  }


























#
# Install Java.
#
install_java
  begin_progress "Installing Java."
  download ${JRE_FILE} ${JRE_URL} ${JRE_FOLDER_NAME} ${ECLIPSE_RUNTIME_FOLDER} FAIL
  if ERRORLEVEL 1 {
    error
  fi
  if [ -f ${ECLIPSE_RUNTIME_FOLDER}/jre. rmdir /S/Q ${ECLIPSE_RUNTIME_FOLDER}/jre
  move ${ECLIPSE_RUNTIME_FOLDER}/${JRE_FOLDER_NAME} ${ECLIPSE_RUNTIME_FOLDER}/jre >>${LOG}
  }












#
# Install WUDSN IDE feature.
#
install_wudsn_ide_feature
  begin_progress "Installing WUDSN IDE feature."
  # See http://help.eclipse.org/latest/index.jsp?topic=/org.eclipse.platform.doc.isv/guide/p2_director.html
  ${ECLIPSE_RUNTIME_FOLDER}/eclipsec.exe -nosplash -application org.eclipse.equinox.p2.director -repository ${UPDATE_URL} -installIU com.wudsn.ide.feature.feature.group -destination ${ECLIPSE_RUNTIME_FOLDER} 2>>${LOG} >>${LOG}.tmp
  type ${LOG}.tmp >>${LOG}
  del /Q ${LOG}.tmp
  }

#
# Install projects.
#
install_projects
  PROJECTS_FOLDER=$1
  if [ ! -f "${PROJECTS_FOLDER}" ]; then
    begin_progress "Installing Projects."
    download_repo wudsn-ide-projects ${PROJECTS_FOLDER}
  fi
  }

#
# Create an Eclipse preferences file.
#
create_prefs
  PREFS=${SETTINGS_FOLDER}/$1
  echo eclipse.preferences.version=^1>${PREFS}
  }

#
# Create the workspace folder and initialize its preferences.
#
create_workspace_folder
  WORKSPACE_FOLDER=$1
  if [ -f ${WORKSPACE_FOLDER} {
    return
  fi
  display_progress "Installing WUDSN defaults for workspace ${WORKSPACE_FOLDER}."
  create_folder ${WORKSPACE_FOLDER}

  SETTINGS_FOLDER=${WORKSPACE_FOLDER}/.metadata/.plugins/org.eclipse.core.runtime/.settings
  create_folder ${SETTINGS_FOLDER}

  create_prefs org.eclipse.ui.ide.prefs
  RECENT_WORKSPACES=${WORKSPACE_FOLDER:/=//}
  echo MAX_RECENT_WORKSPACES=10>>${PREFS}
  echo RECENT_WORKSPACES=${RECENT_WORKSPACES} >>${PREFS}
  echo RECENT_WORKSPACES_PROTOCOL=^3>>${PREFS}
  echo SHOW_RECENT_WORKSPACES=false>>${PREFS}
  echo SHOW_WORKSPACE_SELECTION_DIALOG=false>>${PREFS}
  
  create_prefs org.eclipse.ui.editors.prefs
  echo tabWidth=^8>>${PREFS}
  
  create_prefs org.eclipse.ui.prefs
  echo showIntro=false>>${PREFS}

  WORKSPACE_CREATED=1
  }

#
# Start Eclipse in new process.
#
start_eclipse
  if [ "${WORKSPACE_CREATED}" = "2" ]; then
    begin_progress "Starting WUDSN IDE for import projects from ${PROJECTS_FOLDER}."
    start ${ECLIPSE_EXECUTABLE} -noSplash -import ${PROJECTS_FOLDER}
  fi else {
    begin_progress "Starting WUDSN IDE in new window."
    start ${ECLIPSE_EXECUTABLE} -noSplash -data ${WORKSPACE_FOLDER}
  fi
  }

#
# Handle install mode. 
#
handle_install_mode
  display_progress "Selected install mode is '%INSTALL_MODE%'."
  if [ "${INSTALL_MODE}" = "--start-eclipse" ]; then
      start_eclipse
      exit 0
  elif [ "${INSTALL_MODE}" = "--install-all-from-server" ]; then
      begin_progress "Starting full installation of ${WUDSN_VERSION} version from server ${SITE_URL}."
      remove_folder ${WORKSPACE_FOLDER}
      remove_folder ${PROJECTS_FOLDER}
      remove_folder ${INSTALL_FOLDER}
      remove_folder ${TOOLS_FOLDER}
  elif [ "${INSTALL_MODE}" = "--install-ide-from-server" ]; then
      begin_progress "Starting IDE installation ${WUDSN_VERSION} version from server ${SITE_URL}."
      remove_folder ${INSTALL_FOLDER}
      remove_folder ${TOOLS_FOLDER}
  elif [ "${INSTALL_MODE}" = "--install-ide-from-cache" ]; then
      begin_progress "Starting IDE installation from local cache."
      remove_folder ${TOOLS_FOLDER}
  elif [ "${INSTALL_MODE}" = "--install-workspace" ]; then
      begin_progress "Starting workspace installation."
      remove_folder ${WORKSPACE_FOLDER}
      remove_folder ${PROJECTS_FOLDER}
  fi else {
    display_progress "ERROR: Invalid install mode '%INSTALL_MODE%'."
    error
  fi
  }

#
# Detect the OS type and architecture and dependent variables.
#
detect_os_type
  # https://archive.eclipse.org/eclipse/downloads/drops4/R-4.26-202211231800/
  ECLIPSE_VERSION=4.26
  ECLIPSE_FILES[0]=eclipse-platform-${ECLIPSE_VERSION}-win32-x86_64.zip
  # ECLIPSE_FILES[1]=eclipse-platform-${ECLIPSE_VERSION}-win32-aarch64.zip

  # https://jdk.java.net/archive/
  JRE_VERSION=19.0.1
  JRE_FILES[0]=openjdk-${JRE_VERSION%_windows-x64_bin.zip
  # JRE_FILES[1]=openjdk-${JRE_VERSION%_windows-aarch64.bin.zip
  
  OS_INDEX=0

  setlocal enableDelayedExpansion
    ECLIPSE_FILE=!ECLIPSE_FILES[%OS_INDEX%]!
  endlocal & ECLIPSE_FILE=${ECLIPSE_FILE}
  ECLIPSE_URL=${DOWNLOADS_URL}/${ECLIPSE_FILE}
  ECLIPSE_FOLDER_NAME=eclipse
  ECLIPSE_FOLDER=${TOOLS_FOLDER}/IDE/Eclipse
  ECLIPSE_APP_FOLDER=${ECLIPSE_FOLDER}
  ECLIPSE_RUNTIME_FOLDER=${ECLIPSE_FOLDER}/${ECLIPSE_FOLDER_NAME}
  ECLIPSE_APP_NAME=eclipse.exe
  ECLIPSE_EXECUTABLE=${ECLIPSE_RUNTIME_FOLDER}/${ECLIPSE_APP_NAME}
  
  setlocal enableDelayedExpansion
    JRE_FILE=!JRE_FILES[%OS_INDEX%]!
  endlocal & JRE_FILE=${JRE_FILE}
  JRE_URL=${DOWNLOADS_URL}/${JRE_FILE}
  JRE_FOLDER_NAME=jdk-${JRE_VERSION}

}

#
# Main function.
#
main
  SCRIPT_FOLDER=${CD}
  LOG=${SCRIPT_FOLDER}/wudsn.log
  date /T >${LOG}
  time /T >>${LOG}
  display_progress "$1"

  begin_progress "Checking installation in ${SCRIPT_FOLDER}."
  echo

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
  >>${LOG}
  
  create_folder ${INSTALL_FOLDER}
  pushd ${INSTALL_FOLDER}

  install_commands
  install_tools ${TOOLS_FOLDER}
  install_eclipse ${ECLIPSE_APP_FOLDER}
  install_projects ${PROJECTS_FOLDER}
  create_workspace_folder ${WORKSPACE_FOLDER}

  popd
  
  start_eclipse
  }

#
# Main script
#
main_script
  pushd "${~dp0"
  setlocal
  setlocal enableextensions enabledelayedexpansion
  main "$1"
  popd
  }
