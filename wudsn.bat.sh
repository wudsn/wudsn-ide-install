@echo off
#
# WUDSN IDE Installer - Version 2022-12-28
# Visit https://www.wudsn.com for the latest version.
#

setlocal
setlocal enableextensions enabledelayedexpansion
main $1
}

#
# Display error message and exit current call stack frame.
#
error

echo ERROR: See messages above and in $LOG.
exit /b 1
}

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
# Remove a folder and its contents if it exists.
#
remove_folder
if [ -f $1 {
  display_progress "Removing folder $1."
  rmdir /S/Q $1
  if [ -f $1 {
    display_progress "ERROR: Cannot remove folder $1"
    pause
    goto error
  }
}
exit /b 0

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
} else {
  display_progress "File $FILE$ is present."
}

if [ -f $TARGET {
  remove_folder $TARGET
}
if [ ! -f $TARGET_FOLDER. mkdir $TARGET_FOLDER

display_progress "Unpacking $FILE$ to $TARGET_FOLDER."
tar -xf $FILE$ -C $TARGET_FOLDER$ 2>>$LOG
if ERRORLEVEL 1 {
   if $MODE$==FAIL goto error
}
}

#
# Download a git repo main branch and unpack to target folder.
# Usage: download repo <repo> <target_folder>
#
download_repo

REPO=$1
BRANCH=main
REPO_BRANCH=$REPO$-$BRANCH
REPO_FILE=$REPO_BRANCH.zip
REPO_URL=https://github.com/peterdell/$REPO/archive/refs/heads/$BRANCH.zip
REPO_TARGET_FOLDER=$2
display_progress "Downloading repo $REPO$ to $REPO_TARGET_FOLDER."
download $REPO_FILE$ $REPO_URL$ $REPO_BRANCH$ $INSTALL_FOLDER$ IGNORE
# if ERRORLEVEL 1 goto error
display_progress "Copying files to $REPO_TARGET_FOLDER."
if [ ! -f $REPO_TARGET_FOLDER. mkdir $REPO_TARGET_FOLDER
xcopy /E /R /Y /Q $REPO_BRANCH/*.* $REPO_TARGET_FOLDER$ >>$LOG
remove_folder $REPO_BRANCH
}


# 
# Check that the workspace is unlocked.
#
check_workspace_lock
WORKSPACE_LOCK=$WORKSPACE_FOLDER/.metadata/.lock
if [ -f $WORKSPACE_LOCK. del $WORKSPACE_LOCK$ 2>>$LOG
workspace_locked
if [ -f $WORKSPACE_LOCK {
  echo ERROR: Workspace $WORKSPACE_FOLDER$ is locked. Close Eclipse first.
  pause
  goto workspace_locked
}
}

#
# Select install mode.
#
select_install_mode
INSTALL_MODE=$1

if "$WUDSN_VERSION$" == "" {
  WUDSN_VERSION=stable
}

if [ ! -f $PROJECTS_FOLDER. INSTALL_MODE=--install-all-from-server
if "$INSTALL_MODE$"=="--install-all-from-server" goto install_mode_selected

if [ ! -f $INSTALL_FOLDER. INSTALL_MODE=--install
if "$INSTALL_MODE$"=="--install-ide-from-cache"  goto install_mode_selected
if "$INSTALL_MODE$"=="--install-ide-from-server" goto install_mode_selected
if "$INSTALL_MODE$"=="--install-workspace"       goto install_mode_selected

if "$INSTALL_MODE$"=="--install" goto display_install_menu
if not "$INSTALL_MODE$"=="" {
   echo ERROR: Invalid install mode "$INSTALL_MODE$". Use on of these options.
   echo wudsn.exe --install-ide-from-cache^|--install-ide-from-server^|--install-all-from-server^|-install-workspace
   echo.
   goto display_install_menu
}

if [ -f $ECLIPSE_APP {
  INSTALL_MODE=--start-eclipse
  goto install_mode_selected
}

display_install_menu
echo WUDSN IDE Installer
echo ===================
echo.
echo Close all open Eclipse processes.
echo Select your option to reinstall the $WUDSN_VERSION$ version of WUDSN IDE in $WUDSN_FOLDER

choose_install_mode
echo 1} Delete IDE, then install IDE from local cache
echo 2} Delete local cache and IDE, then install IDE from server
echo 3} Delete local cache, IDE, projects and workspace, then install everything from server
echo s} Start WUDSN IDE
echo x} Exit installer
ID=""
/p ID="Your choice: "
if "$ID$"=="1" {
  INSTALL_MODE=--install-ide-from-cache
  goto install_mode_selected
} else if "$ID$"=="2" {
  INSTALL_MODE=--install-ide-from-server
  goto install_mode_selected
} else if "$ID$"=="3" {
  INSTALL_MODE=--install-all-from-server
  goto install_mode_selected
} else if "$ID$"=="s" {
  goto start_eclipse
} else if "$ID$"=="x" {
  }
} else goto choose_install_mode

install_mode_selected
}

#
# Create the workspace folder and initialize its preferences
#
create_workspace_folder
echo Creating workspace folder
display_progress "Installing WUDSN defaults for workspace $WORKSPACE_FOLDER."
mkdir $WORKSPACE_FOLDER

SETTINGS_FOLDER=$WORKSPACE_FOLDER/.metadata/.plugins/org.eclipse.core.runtime/.settings
if [ ! -f $SETTINGS_FOLDER {
  mkdir $SETTINGS_FOLDER
}

PREFS=$SETTINGS_FOLDER/org.eclipse.ui.ide.prefs
RECENT_WORKSPACES=$WORKSPACE_FOLDER:/=//
echo eclipse.preferences.version=^1>$PREFS
echo MAX_RECENT_WORKSPACES=10>>$PREFS
echo RECENT_WORKSPACES=$RECENT_WORKSPACES$ >>$PREFS
echo RECENT_WORKSPACES_PROTOCOL=^3>>$PREFS
echo SHOW_RECENT_WORKSPACES=false>>$PREFS
echo SHOW_WORKSPACE_SELECTION_DIALOG=false>>$PREFS

PREFS=$SETTINGS_FOLDER/org.eclipse.ui.editors.prefs
echo eclipse.preferences.version=^1>$PREFS
echo tabWidth=^8>>$PREFS

PREFS=$SETTINGS_FOLDER/org.eclipse.ui.prefs
echo eclipse.preferences.version=^1>$PREFS
echo showIntro=false>>$PREFS

}

#
# Main script.
#
main

# Use current folder when running from .exe
# Use scipt folder when running .bat
SCRIPT_FOLDER=$CD
LOG=$SCRIPT_FOLDER/wudsn.log
date /T >$LOG
begin_progress "Checking installation in $SCRIPT_FOLDER."

WUDSN_FOLDER=$SCRIPT_FOLDER
INSTALL_FOLDER=$WUDSN_FOLDER/Install
TOOLS_FOLDER=$WUDSN_FOLDER/Tools
PROJECTS_FOLDER=$WUDSN_FOLDER/Projects
WORKSPACE_FOLDER=$WUDSN_FOLDER/Workspace

TOOLS_FILE=wudsn-ide-tools-main.zip
TOOLS_URL=https://github.com/peterdell/wudsn-ide-tools/archive/refs/heads/main.zip

if "$SITE_URL$" == "" {
  SITE_URL=https://www.wudsn.com
}
DOWNLOADS_URL=$SITE_URL/productions/java/ide/downloads
UPDATE_URL=$SITE_URL/update/$WUDSN_VERSION

ECLIPSE_FILE=eclipse-platform-4.19-win32-x86_64.zip
ECLIPSE_URL=$DOWNLOADS_URL/$ECLIPSE_FILE
ECLIPSE_FOLDER_NAME=eclipse
ECLIPSE_FOLDER=$TOOLS_FOLDER/IDE/Eclipse
ECLIPSE_RUNTIME_FOLDER=$ECLIPSE_FOLDER/$ECLIPSE_FOLDER_NAME
ECLIPSE_APP=$ECLIPSE_RUNTIME_FOLDER/eclipse.exe
ECLIPSE_SPLASH_FOLDER=$ECLIPSE_RUNTIME_FOLDER/plugins/org.eclipse.platform_4.19.0.v20210303-1800

JRE_FILE=openjdk-16.0.2_windows-x64_bin.zip
JRE_URL=$DOWNLOADS_URL/$JRE_FILE
JRE_FOLDER_NAME=jdk-16.0.2

check_workspace_lock
select_install_mode $1

if "$INSTALL_MODE$"=="--start-eclipse" {
    goto start_eclipse
} else if "$INSTALL_MODE$"=="--install-all-from-server" {
    begin_progress "Starting full installation of $WUDSN_VERSION$ version from server $SITE_URL."
    remove_folder $WORKSPACE_FOLDER
    remove_folder $PROJECTS_FOLDER
    remove_folder $INSTALL_FOLDER
    remove_folder $TOOLS_FOLDER
} else if "$INSTALL_MODE$"=="--install-ide-from-server" {
    begin_progress "Starting IDE installation $WUDSN_VERSION$ version from server $SITE_URL."
    remove_folder $INSTALL_FOLDER
    remove_folder $TOOLS_FOLDER
} else if "$INSTALL_MODE$"=="--install-ide-from-cache" {
    begin_progress "Starting IDE installation from local cache."
    remove_folder $TOOLS_FOLDER
} else if "$INSTALL_MODE$"=="--install-workspace" {
    begin_progress "Starting IDE installation from local cache."
    remove_folder $WORKSPACE_FOLDER
    remove_folder $PROJECTS_FOLDER
} else {
  display_progress "ERROR: Invalid install mode $INSTALL_MODE.".
  exit /b
}

echo Environment variables: >>$LOG
>>$LOG

if [ ! -f $INSTALL_FOLDER. mkdir $INSTALL_FOLDER
pushd $INSTALL_FOLDER
begin_progress "Installing Tools."
download_repo wudsn-ide-tools $TOOLS_FOLDER
# if ERRORLEVEL 1 goto error

begin_progress "Installing Eclipse."
download $ECLIPSE_FILE$ $ECLIPSE_URL$ $ECLIPSE_FOLDER_NAME$ $ECLIPSE_FOLDER$ FAIL
if ERRORLEVEL 1 goto error
# display_progress "Installing branding."
# copy $WUDSN_FOLDER/wudsn.bmp $ECLIPSE_SPLASH_FOLDER/splash.bmp >>$LOG
# if ERRORLEVEL 1 goto error

begin_progress "Installing Java Runtime."
download $JRE_FILE$ $JRE_URL$ $JRE_FOLDER_NAME$ $ECLIPSE_RUNTIME_FOLDER$ FAIL
if ERRORLEVEL 1 goto error
if [ -f $ECLIPSE_RUNTIME_FOLDER/jre. rmdir /S/Q $ECLIPSE_RUNTIME_FOLDER/jre
move $ECLIPSE_RUNTIME_FOLDER/$JRE_FOLDER_NAME$ $ECLIPSE_RUNTIME_FOLDER/jre >>$LOG

begin_progress "Installing WUDSN IDE feature."
display_progress "Downloading and installing feature"
# See http://help.eclipse.org/latest/index.jsp?topic=/org.eclipse.platform.doc.isv/guide/p2_director.html
$ECLIPSE_RUNTIME_FOLDER/eclipsec.exe -nosplash -application org.eclipse.equinox.p2.director -repository $UPDATE_URL$ -installIU com.wudsn.ide.feature.feature.group -destination $ECLIPSE_RUNTIME_FOLDER$ 2>>$LOG$ >>$LOG.tmp
type $LOG.tmp >>$LOG
del /Q $LOG.tmp

if [ ! -f $PROJECTS_FOLDER {
  begin_progress "Installing Projects and Workspace."
  download_repo wudsn-ide-projects $PROJECTS_FOLDER
  if ERRORLEVEL 1 goto error
}

if [ ! -f $WORKSPACE_FOLDER {
  create_workspace_folder
  WORKSPACE_CREATED=1
}

popd

start_eclipse
if "$WORKSPACE_CREATED$"=="2" {
  begin_progress "Starting WUDSN IDE for import projects from $PROJECTS_FOLDER."
  start $ECLIPSE_RUNTIME_FOLDER/eclipse.exe -noSplash -import $PROJECTS_FOLDER
} else {
  begin_progress "Starting WUDSN IDE."
  start $ECLIPSE_RUNTIME_FOLDER/eclipse.exe -noSplash -data $WORKSPACE_FOLDER
}

