@echo off
rem
rem WUDSN IDE Installer - Version 2022-12-26
rem Visit https://www.wudsn.com for the latest version.
rem

setlocal
setlocal enableextensions enabledelayedexpansion
call :main %1
goto :eof

rem
rem Display error message and exit current call stack frame.
rem
:error

echo ERROR: See messages above and in %LOG%.
exit /b 1
goto :eof

rem
rem Append message to log
rem
:log_message
echo | set /p=%1 >>%LOG%
echo. >>%LOG%
goto :eof

rem
rem Display progress activity.
rem
:begin_progress
echo | set /p=%1
echo.
call :log_message %1
goto :eof


rem
rem Display progress message
rem
:display_progress
call :log_message %1
goto :eof

rem
rem Remove a folder and its contents if it exists.
rem
:remove_folder
if exist %1. (
  call :display_progress "Removing folder %1."
  rmdir /S/Q %1
  if exist %1. (
    call :display_progress "ERROR: Cannot remove folder %1"
    pause
    goto :error
  )
)
exit /b 0

rem
rem Download a .zip file and unpack to target folder.
rem Usage: download repo <filename> <url> <folder> <target_folder> <FAIL|IGNORE>
rem
:download

set FILE=%1
set URL=%2
set FOLDER=%3
set TARGET_FOLDER=%4
set TARGET=%TARGET_FOLDER%\%FOLDER%
set MODE=%5

if not exist %FILE% (
  call :display_progress "Downloading %FILE% from %URL%."
  curl -silent --show-error -L %URL% --output %FILE%
) else (
  call :display_progress "File %FILE% is present."
)

if exist %TARGET%. (
  call :remove_folder %TARGET%
)
if not exist %TARGET_FOLDER%. mkdir %TARGET_FOLDER%

call :display_progress "Unpacking %FILE% to %TARGET_FOLDER%."
tar -xf %FILE% -C %TARGET_FOLDER% 2>>%LOG%
if ERRORLEVEL 1 (
   if %MODE%==FAIL goto :error
)
goto :eof

rem
rem Download a git repo main branch and unpack to target folder.
rem Usage: download repo <repo> <target_folder>
rem
:download_repo

set REPO=%1
set BRANCH=main
set REPO_BRANCH=%REPO%-%BRANCH%
set REPO_FILE=%REPO_BRANCH%.zip
set REPO_URL=https://github.com/peterdell/%REPO%/archive/refs/heads/%BRANCH%.zip
set REPO_TARGET_FOLDER=%2
call :display_progress "Downloading repo %REPO% to %REPO_TARGET_FOLDER%."
call :download %REPO_FILE% %REPO_URL% %REPO_BRANCH% %INSTALL_FOLDER% IGNORE
rem if ERRORLEVEL 1 goto :error
call :display_progress "Copying files to %REPO_TARGET_FOLDER%."
if not exist %REPO_TARGET_FOLDER%. mkdir %REPO_TARGET_FOLDER%
xcopy /E /R /Y /Q %REPO_BRANCH%\*.* %REPO_TARGET_FOLDER% >>%LOG%
call :remove_folder %REPO_BRANCH%
goto :eof


rem 
rem Check that the workspace is unlocked.
rem
echo on
:check_workspace_lock
set WORKSPACE_LOCK=%WORKSPACE_FOLDER%\.metadata\.lock
if exist %WORKSPACE_LOCK%. del %WORKSPACE_LOCK% 2>>%LOG%
:workspace_locked
if exist %WORKSPACE_LOCK%. (
  echo ERROR: Workspace %WORKSPACE_FOLDER% is locked. Close Eclipse first.
  pause
  goto :workspace_locked
)
goto :eof

rem
rem Select install mode.
rem
:select_install_mode
set INSTALL_MODE=%1

if not exist %PROJECTS_FOLDER%. set INSTALL_MODE=--install-all-from-server
if "%INSTALL_MODE%"=="--install-all-from-server" goto :install_mode_selected

if not exist %INSTALL_FOLDER%. set INSTALL_MODE=--install
if "%INSTALL_MODE%"=="--install-ide-from-cache"  goto :install_mode_selected
if "%INSTALL_MODE%"=="--install-ide-from-server" goto :install_mode_selected
if "%INSTALL_MODE%"=="--install-workspace"       goto :install_mode_selected

if "%INSTALL_MODE%"=="--install" goto :display_install_menu
if not "%INSTALL_MODE%"=="" (
   echo ERROR: Invalid install mode "%INSTALL_MODE%". Use on of these options.
   echo wudsn.exe --install-ide-from-cache^|--install-ide-from-server^|--install-all-from-server^|-install-workspace
   echo.
   goto :display_install_menu
)

if exist %ECLIPSE_APP%. (
  set INSTALL_MODE=--start-eclipse
  goto :install_mode_selected
)

:display_install_menu
echo WUDSN IDE Installer
echo ===================
echo.
echo Close all open Eclipse processes.
echo Select your option to reinstall the stable version of WUDSN IDE in %WUDSN_FOLDER%

:choose_install_mode
echo 1) Delete IDE, then install IDE from local cache
echo 2) Delete local cache and IDE, then install IDE from server
echo 3) Delete local cache, IDE, projects and workspace, then install everything from server
echo x) Exit installer
set ID=""
set /p ID="Your choice: "
if "%ID%"=="1" (
  set INSTALL_MODE=--install-ide-from-cache
  goto :install_mode_selected
) else if "%ID%"=="2" (
  set INSTALL_MODE=--install-ide-from-server
  goto :install_mode_selected
) else if "%ID%"=="3" (
  set INSTALL_MODE=--install-all-from-server
  goto :install_mode_selected
) else if "%ID%"=="x" (
  goto :eof
)else goto :choose_install_mode

:install_mode_selected
goto :eof

rem
rem Create the workspace folder and initialize its preferences
rem
:create_workspace_folder
echo Creating workspace folder
call :display_progress "Installing WUDSN defaults for workspace %WORKSPACE_FOLDER%."
mkdir %WORKSPACE_FOLDER%

set SETTINGS_FOLDER=%WORKSPACE_FOLDER%\.metadata\.plugins\org.eclipse.core.runtime\.settings
if not exist %SETTINGS_FOLDER%. (
  mkdir %SETTINGS_FOLDER%
)

set PREFS=%SETTINGS_FOLDER%\org.eclipse.ui.ide.prefs
set RECENT_WORKSPACES=%WORKSPACE_FOLDER:\=\\%
echo eclipse.preferences.version=^1>%PREFS%
echo MAX_RECENT_WORKSPACES=10>>%PREFS%
echo RECENT_WORKSPACES=%RECENT_WORKSPACES% >>%PREFS%
echo RECENT_WORKSPACES_PROTOCOL=^3>>%PREFS%
echo SHOW_RECENT_WORKSPACES=false>>%PREFS%
echo SHOW_WORKSPACE_SELECTION_DIALOG=false>>%PREFS%

set PREFS=%SETTINGS_FOLDER%\org.eclipse.ui.editors.prefs
echo eclipse.preferences.version=^1>%PREFS%
echo tabWidth=^8>>%PREFS%

set PREFS=%SETTINGS_FOLDER%\org.eclipse.ui.prefs
echo eclipse.preferences.version=^1>%PREFS%
echo showIntro=false>>%PREFS%

goto :eof

rem
rem Main script.
rem
:main

rem Use current folder when running from .exe
rem Use scipt folder when running .bat
set SCRIPT_FOLDER=%CD%
set LOG=%SCRIPT_FOLDER%\wudsn.log
date /T >%LOG%
call :begin_progress "Checking installation in %SCRIPT_FOLDER%."

set WUDSN_FOLDER=%SCRIPT_FOLDER%
set INSTALL_FOLDER=%WUDSN_FOLDER%\Install
set TOOLS_FOLDER=%WUDSN_FOLDER%\Tools
set PROJECTS_FOLDER=%WUDSN_FOLDER%\Projects
set WORKSPACE_FOLDER=%WUDSN_FOLDER%\Workspace

set TOOLS_FILE=wudsn-ide-tools-main.zip
set TOOLS_URL=https://github.com/peterdell/wudsn-ide-tools/archive/refs/heads/main.zip

if "%SITE_URL%" == "" (
  set SITE_URL=https://www.wudsn.com
)
set DOWNLOADS_URL=%SITE_URL%/productions/java/ide/downloads
set UPDATE_URL=%SITE_URL%/update/stable

set ECLIPSE_FILE=eclipse-platform-4.19-win32-x86_64.zip
set ECLIPSE_URL=%DOWNLOADS_URL%/%ECLIPSE_FILE%
set ECLIPSE_FOLDER_NAME=eclipse
set ECLIPSE_FOLDER=%TOOLS_FOLDER%\IDE\Eclipse
set ECLIPSE_RUNTIME_FOLDER=%ECLIPSE_FOLDER%\%ECLIPSE_FOLDER_NAME%
set ECLIPSE_APP=%ECLIPSE_RUNTIME_FOLDER%\eclipse.exe
set ECLIPSE_SPLASH_FOLDER=%ECLIPSE_RUNTIME_FOLDER%\plugins\org.eclipse.platform_4.19.0.v20210303-1800

set JRE_FILE=openjdk-16.0.2_windows-x64_bin.zip
set JRE_URL=%DOWNLOADS_URL%/%JRE_FILE%
set JRE_FOLDER_NAME=jdk-16.0.2

call :check_workspace_lock
call :select_install_mode %1

if "%INSTALL_MODE%"=="--start-eclipse" (
    goto :start_eclipse
) else if "%INSTALL_MODE%"=="--install-all-from-server" (
    call :begin_progress "Starting full installation from server %SITE_URL%."
    call :remove_folder %WORKSPACE_FOLDER%
    call :remove_folder %PROJECTS_FOLDER%
    call :remove_folder %INSTALL_FOLDER%
    call :remove_folder %TOOLS_FOLDER%
) else if "%INSTALL_MODE%"=="--install-ide-from-server" (
    call :begin_progress "Starting IDE installation from server %SITE_URL%."
    call :remove_folder %INSTALL_FOLDER%
    call :remove_folder %TOOLS_FOLDER%
) else if "%INSTALL_MODE%"=="--install-ide-from-cache" (
    call :begin_progress "Starting IDE installation from local cache."
    call :remove_folder %TOOLS_FOLDER%
) else if "%INSTALL_MODE%"=="--install-workspace" (
    call :begin_progress "Starting IDE installation from local cache."
    call :remove_folder %WORKSPACE_FOLDER%
    call :remove_folder %PROJECTS_FOLDER%
) else (
  call :display_progress "ERROR: Invalid install mode %INSTALL_MODE%.".
  exit /b
)

echo Environment variables: >>%LOG%
set >>%LOG%

if not exist %INSTALL_FOLDER%. mkdir %INSTALL_FOLDER%
pushd %INSTALL_FOLDER%
call :begin_progress "Installing Tools."
call :download_repo wudsn-ide-tools %TOOLS_FOLDER%
rem if ERRORLEVEL 1 goto :error

call :begin_progress "Installing Eclipse."
call :download %ECLIPSE_FILE% %ECLIPSE_URL% %ECLIPSE_FOLDER_NAME% %ECLIPSE_FOLDER% FAIL
if ERRORLEVEL 1 goto :error
rem call :display_progress "Installing branding."
rem copy %WUDSN_FOLDER%\wudsn.bmp %ECLIPSE_SPLASH_FOLDER%\splash.bmp >>%LOG%
rem if ERRORLEVEL 1 goto :error

call :begin_progress "Installing Java Runtime."
call :download %JRE_FILE% %JRE_URL% %JRE_FOLDER_NAME% %ECLIPSE_RUNTIME_FOLDER% FAIL
if ERRORLEVEL 1 goto :error
if exist %ECLIPSE_RUNTIME_FOLDER%\jre. rmdir /S/Q %ECLIPSE_RUNTIME_FOLDER%\jre
move %ECLIPSE_RUNTIME_FOLDER%\%JRE_FOLDER_NAME% %ECLIPSE_RUNTIME_FOLDER%\jre >>%LOG%

call :begin_progress "Installing WUDSN IDE feature."
call :display_progress "Downloading and installing feature"
rem See http://help.eclipse.org/latest/index.jsp?topic=/org.eclipse.platform.doc.isv/guide/p2_director.html
%ECLIPSE_RUNTIME_FOLDER%\eclipsec.exe -nosplash -application org.eclipse.equinox.p2.director -repository %UPDATE_URL% -installIU com.wudsn.ide.feature.feature.group -destination %ECLIPSE_RUNTIME_FOLDER% 2>>%LOG% >>%LOG%.tmp
type %LOG%.tmp >>%LOG%
del /Q %LOG%.tmp

if not exist %PROJECTS_FOLDER%. (
  call :begin_progress "Installing Projects and Workspace."
  call :download_repo wudsn-ide-projects %PROJECTS_FOLDER%
  if ERRORLEVEL 1 goto :error
)

if not exist %WORKSPACE_FOLDER%. (
  call :create_workspace_folder
  set WORKSPACE_CREATED=1
)

popd

:start_eclipse
if "%WORKSPACE_CREATED%"=="2" (
  call :begin_progress "Starting WUDSN IDE for import projects from %PROJECTS_FOLDER%."
  start %ECLIPSE_RUNTIME_FOLDER%\eclipse.exe -noSplash -import %PROJECTS_FOLDER%
) else (
  call :begin_progress "Starting WUDSN IDE."
  start %ECLIPSE_RUNTIME_FOLDER%\eclipse.exe -noSplash -data %WORKSPACE_FOLDER%
)

