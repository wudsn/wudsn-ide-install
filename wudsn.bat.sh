@echo off
#
# WUDSN IDE Installer - Version 2022-12-28
# Visit https://www.wudsn.com for the latest version.
# Use https://www.shellcheck.net to validate the .sh script source.
#

goto main_script $1

#
# Print a quoted string on the screen.
#
print
  echo $~1
  }
  
#
# Display error message and exit the shell.
#
error
  print "ERROR: See messages above and in $LOG."
  pause
  exit 1

#
# Append message to log
#
log_message
  echo | /p=$1 >>$LOG
  echo. >>$LOG
  }

#
# Display progress activity.
#
begin_progress
  echo | /p=$1
  echo.
  log_message $1
  }

#
# Display progress message
#
display_progress
  log_message $1
  }

#
# Create a folder including intermediate folders.
#
create_folder
  if [ ! -f $1. mkdir $1
  }

#
# Remove a folder and its contents if it exists.
#
remove_folder
  if [ -f $1 {
    display_progress "Removing folder $1."
    rmdir /S/Q $1
    if [ -f $1 {
      display_progress "ERROR: Cannot remove folder $1"
      error
    fi
  fi
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
  TARGET=$TARGET_FOLDER/$FOLDER
  MODE=$5
  
  if [ ! -f $FILE$ {
    display_progress "Downloading $FILE$ from $URL."
    curl --silent --show-error --location $URL$ --output $FILE
  fi else {
    display_progress "File $FILE$ is present."
  fi
  
  if [ -f $TARGET {
    remove_folder $TARGET
  fi
  create_folder $TARGET_FOLDER
  
  display_progress "Unpacking $FILE$ to $TARGET_FOLDER."
  tar -xf $FILE$ -C $TARGET_FOLDER$ 2>>$LOG
  if ERRORLEVEL 1 {
     if [ "$MODE" == "FAIL" ]; then
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
  REPO_BRANCH=$REPO-$BRANCH
  REPO_FILE=$REPO_BRANCH.zip
  REPO_URL=https://github.com/peterdell/$REPO/archive/refs/heads/$BRANCH.zip
  REPO_TARGET_FOLDER=$2

  display_progress "Downloading repo $REPO$ to $REPO_TARGET_FOLDER."
  download $REPO_FILE$ $REPO_URL$ $REPO_BRANCH$ $INSTALL_FOLDER$ IGNORE

  display_progress "Copying files to $REPO_TARGET_FOLDER."
  create_folder $REPO_TARGET_FOLDER
  xcopy /E /R /Y /Q $REPO_BRANCH/*.* $REPO_TARGET_FOLDER$ >>$LOG
  remove_folder $REPO_BRANCH
  }


# 
# Check that the workspace is unlocked.
#
check_workspace_lock
  WORKSPACE_LOCK=$WORKSPACE_FOLDER/.metadata/.lock
  workspace_locked
  if [ -f $WORKSPACE_LOCK. del $WORKSPACE_LOCK$ 2>>$LOG
  if [ -f $WORKSPACE_LOCK {
    print "ERROR: Workspace $WORKSPACE_FOLDER$ is locked. Close Eclipse first."
    pause
    goto workspace_locked
  fi
  }



#
# Select install mode.
#
select_install_mode
  INSTALL_MODE=$1
  
  if [ ! -f $PROJECTS_FOLDER$ {
    INSTALL_MODE=--install-all-from-server
  fi

  if [ "$INSTALL_MODE" == "--install-all-from-server" ]; then
    return
  fi
  
  if [ ! -f $INSTALL_FOLDER$ {
    INSTALL_MODE=--install
    return
  fi

  if [ "$INSTALL_MODE" == "--install-ide-from-cache" ]; then
    return
  fi
  if [ "$INSTALL_MODE" == "--install-ide-from-server" ]; then
    return
  fi
  if [ "$INSTALL_MODE" == "--install-workspace" ]; then
    return
  fi
  
  if [ "$INSTALL_MODE" == "--install" ]; then
    display_install_menu
    return
  fi
  
  if not "$INSTALL_MODE" == "" ]; then
     print "ERROR: Invalid install mode '$INSTALL_MODE$'. Use one of these options."
     echo wudsn.exe --install-ide-from-cache^|--install-ide-from-server^|--install-all-from-server^|-install-workspace
     echo.
     display_install_menu
     return
  fi
  
  if [ -f $ECLIPSE_APP_EXE {
    INSTALL_MODE=--start-eclipse
  fi

  }

#
# Display the installer menu and prompt the user for selection.
#
display_install_menu
  print "WUDSN IDE Installer"
  print "==================="
  echo.
  print "Close all open Eclipse processes."
  print "Select your option to reinstall the $WUDSN_VERSION$ version of WUDSN IDE in $WUDSN_FOLDER"
  
  choose_install_mode
  print "1) Delete IDE, then install IDE from local cache"
  print "2) Delete local cache and IDE, then install IDE from server"
  print "3) Delete local cache, IDE, projects and workspace, then install everything from server"
  print "s) Start WUDSN IDE"
  print "x) Exit installer"
  ID=
  /p ID="Your choice: "
  if [ "$ID" == "1" ]; then
    INSTALL_MODE=--install-ide-from-cache
    return

  elif [ "$ID" == "2" ]; then
    INSTALL_MODE=--install-ide-from-server
    return

  elif [ "$ID" == "3" ]; then
    INSTALL_MODE=--install-all-from-server
    return

  elif [ "$ID" == "s" ]; then
    INSTALL_MODE=--start_eclipse
    return

  elif [ "$ID" == "x" ]; then
    exit 0
  fi
  goto choose_install_mode





#
# Install tools.
#
install_tools
  begin_progress "Installing Tools."
  TOOLS_FOLDER=$1
  download_repo wudsn-ide-tools $TOOLS_FOLDER
  }

#
# Install Eclipse.
#
install_eclipse
  ECLIPSE_FOLDER=$1
  if [ -f $ECLIPSE_FOLDER {
    return
  fi
  begin_progress "Installing Eclipse."
  download $ECLIPSE_FILE$ $ECLIPSE_URL$ $ECLIPSE_FOLDER_NAME$ $ECLIPSE_FOLDER$ FAIL
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
  download $JRE_FILE$ $JRE_URL$ $JRE_FOLDER_NAME$ $ECLIPSE_RUNTIME_FOLDER$ FAIL
  if ERRORLEVEL 1 {
    error
  fi
  if [ -f $ECLIPSE_RUNTIME_FOLDER/jre. rmdir /S/Q $ECLIPSE_RUNTIME_FOLDER/jre
  move $ECLIPSE_RUNTIME_FOLDER/$JRE_FOLDER_NAME$ $ECLIPSE_RUNTIME_FOLDER/jre >>$LOG
  }












#
# Install WUDSN IDE feature.
#
install_wudsn_ide_feature
  begin_progress "Installing WUDSN IDE feature."
  # See http://help.eclipse.org/latest/index.jsp?topic=/org.eclipse.platform.doc.isv/guide/p2_director.html
  $ECLIPSE_RUNTIME_FOLDER/eclipsec.exe -nosplash -application org.eclipse.equinox.p2.director -repository $UPDATE_URL$ -installIU com.wudsn.ide.feature.feature.group -destination $ECLIPSE_RUNTIME_FOLDER$ 2>>$LOG$ >>$LOG.tmp
  type $LOG.tmp >>$LOG
  del /Q $LOG.tmp
  }

#
# Install projects.
#
install_projects
  PROJECTS_FOLDER=$1
  if [ ! -f $PROJECTS_FOLDER {
    begin_progress "Installing Projects."
    download_repo wudsn-ide-projects $PROJECTS_FOLDER
  fi
  }

#
# Create an Eclipse preferences file.
#
create_prefs
  PREFS=$SETTINGS_FOLDER/$1
  echo eclipse.preferences.version=^1>$PREFS
  }

#
# Create the workspace folder and initialize its preferences.
#
create_workspace_folder
  WORKSPACE_FOLDER=$1
  if [ -f $WORKSPACE_FOLDER {
    return
  fi
  display_progress "Installing WUDSN defaults for workspace $WORKSPACE_FOLDER."
  create_folder $WORKSPACE_FOLDER

  SETTINGS_FOLDER=$WORKSPACE_FOLDER/.metadata/.plugins/org.eclipse.core.runtime/.settings
  create_folder $SETTINGS_FOLDER

  create_prefs org.eclipse.ui.ide.prefs
  RECENT_WORKSPACES=$WORKSPACE_FOLDER:/=//
  echo MAX_RECENT_WORKSPACES=10>>$PREFS
  echo RECENT_WORKSPACES=$RECENT_WORKSPACES$ >>$PREFS
  echo RECENT_WORKSPACES_PROTOCOL=^3>>$PREFS
  echo SHOW_RECENT_WORKSPACES=false>>$PREFS
  echo SHOW_WORKSPACE_SELECTION_DIALOG=false>>$PREFS
  
  create_prefs org.eclipse.ui.editors.prefs
  echo tabWidth=^8>>$PREFS
  
  create_prefs org.eclipse.ui.prefs
  echo showIntro=false>>$PREFS

  WORKSPACE_CREATED=1
  }

#
# Start Eclipse in new process.
#
start_eclipse
  if [ "$WORKSPACE_CREATED" == "2" ]; then
    begin_progress "Starting WUDSN IDE for import projects from $PROJECTS_FOLDER."
    start $ECLIPSE_RUNTIME_FOLDER/eclipse.exe -noSplash -import $PROJECTS_FOLDER
  fi else {
    begin_progress "Starting WUDSN IDE in new window."
    start $ECLIPSE_RUNTIME_FOLDER/eclipse.exe -noSplash -data $WORKSPACE_FOLDER
  fi
  }

#
# Handle install mode. 
#
handle_install_mode
  display_progress "Selected install mode is '$INSTALL_MODE$'."
  if [ "$INSTALL_MODE" == "--start_eclipse" ]; then
      start_eclipse
      exit 0
  elif [ "$INSTALL_MODE" == "--install-all-from-server" ]; then
      begin_progress "Starting full installation of $WUDSN_VERSION$ version from server $SITE_URL."
      remove_folder $WORKSPACE_FOLDER
      remove_folder $PROJECTS_FOLDER
      remove_folder $INSTALL_FOLDER
      remove_folder $TOOLS_FOLDER
  elif [ "$INSTALL_MODE" == "--install-ide-from-server" ]; then
      begin_progress "Starting IDE installation $WUDSN_VERSION$ version from server $SITE_URL."
      remove_folder $INSTALL_FOLDER
      remove_folder $TOOLS_FOLDER
  elif [ "$INSTALL_MODE" == "--install-ide-from-cache" ]; then
      begin_progress "Starting IDE installation from local cache."
      remove_folder $TOOLS_FOLDER
  elif [ "$INSTALL_MODE" == "--install-workspace" ]; then
      begin_progress "Starting workspace installation."
      remove_folder $WORKSPACE_FOLDER
      remove_folder $PROJECTS_FOLDER
  fi else {
    display_progress "ERROR: Invalid install mode '$INSTALL_MODE$'.".
    error
  fi
  }

#
# Main function.
#
main

  # https://www.eclipse.org/downloads/download.php?file=/eclipse/downloads/drops4/R-4.20-202106111600
  ECLIPSE_VERSION=4.26
  ECLIPSE_FILES[0]=eclipse-platform-$ECLIPSE_VERSION-win32-x86_64.zip

  # https://jdk.java.net/archive/
  JRE_VERSION=19.0.1
  JRE_FILES[0]=openjdk-$JRE_VERSION_windows-x64_bin.zip
  
  OS_INDEX=0

  SCRIPT_FOLDER=$CD
  LOG=$SCRIPT_FOLDER/wudsn.log
  date /T >$LOG
  time /T >>$LOG
  begin_progress "Checking installation in $SCRIPT_FOLDER."
  
  WUDSN_FOLDER=$SCRIPT_FOLDER
  INSTALL_FOLDER=$WUDSN_FOLDER/Install
  TOOLS_FOLDER=$WUDSN_FOLDER/Tools
  PROJECTS_FOLDER=$WUDSN_FOLDER/Projects
  WORKSPACE_FOLDER=$WUDSN_FOLDER/Workspace
  
  TOOLS_FILE=wudsn-ide-tools-main.zip
  TOOLS_URL=https://github.com/peterdell/wudsn-ide-tools/archive/refs/heads/main.zip
  
  if [ "$SITE_URL" == "" ]; then
    SITE_URL=https://www.wudsn.com
  fi

  if [ "$WUDSN_VERSION" == "" ]; then
    WUDSN_VERSION=stable
  fi

  DOWNLOADS_URL=$SITE_URL/productions/java/ide/downloads
  UPDATE_URL=$SITE_URL/update/$WUDSN_VERSION
  
  ECLIPSE_FILE=ECLIPSE_FILES[$OS_INDEX$]
  ECLIPSE_URL=$DOWNLOADS_URL/$ECLIPSE_FILE
  ECLIPSE_FOLDER_NAME=eclipse
  ECLIPSE_FOLDER=$TOOLS_FOLDER/IDE/Eclipse
  ECLIPSE_RUNTIME_FOLDER=$ECLIPSE_FOLDER/$ECLIPSE_FOLDER_NAME
  ECLIPSE_APP_NAME=Eclipse.exe
  ECLIPSE_APP_EXE=$ECLIPSE_RUNTIME_FOLDER/$ECLIPSE_APP_NAME
  
  JRE_FILE=$JRE_FILES[$OS_INDEX$]
  JRE_URL=$DOWNLOADS_URL/$JRE_FILE
  JRE_FOLDER_NAME=jdk-$JRE_VERSION
  
  check_workspace_lock
  select_install_mode $1
  handle_install_mode
  
  log_message "Environment variables:"
  >>$LOG
  
  create_folder $INSTALL_FOLDER
  pushd $INSTALL_FOLDER

  install_tools $TOOLS_FOLDER
  install_eclipse $ECLIPSE_FOLDER
  install_projects $PROJECTS_FOLDER
  create_workspace_folder $WORKSPACE_FOLDER

  popd
  
  start_eclipse
  }

#
# Main script
#
main_script
  setlocal
  setlocal enableextensions enabledelayedexpansion
  main $1
  }
