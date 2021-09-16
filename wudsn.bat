@echo off
rem
rem WUDSN IDE Installer
rem Visit https://www.wudsn.com for the latest version.
rem
goto :main


rem
rem Display error message and exit current call stack frame.
rem
:error

echo ERROR: See messages above.
exit /b 1
goto :eof

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
  echo Downloading %FILE% from %URL%.
  curl -L %URL% --output %FILE%
) else (
  echo File %FILE% is present.
)

if exist %TARGET% (
  echo Removing target folder %TARGET%.
  rmdir /S/Q %TARGET%
)
mkdir %TARGET_FOLDER%

echo Unpacking %FILE% to %TARGET_FOLDER%.
tar -xf %FILE% -C %TARGET_FOLDER%
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
echo Download repo %REPO% to %REPO_TARGET_FOLDER%.
call :download %REPO_FILE% %REPO_URL% %REPO_BRANCH% %INSTALL_FOLDER% IGNORE
rem if ERRORLEVEL 1 goto :error
echo Copying files to %REPO_TARGET_FOLDER%.
if not exist %REPO_TARGET_FOLDER% mkdir %REPO_TARGET_FOLDER%
xcopy /E /R /Y /Q %REPO_BRANCH%\*.* %REPO_TARGET_FOLDER%
rmdir /S/Q %REPO_BRANCH%
goto :eof

rem
rem Main script.
rem
:main

echo Defining installation paths.
set SCRIPT_FOLDER=%~dp0
set WUDSN_FOLDER=%SCRIPT_FOLDER%
set INSTALL_FOLDER=%WUDSN_FOLDER%Install
set TOOLS_FOLDER=%WUDSN_FOLDER%Tools
set WORKSPACE_FOLDER=%WUDSN_FOLDER%Workspace

set TOOLS_FILE=wudsn-ide-tools-main.zip
set TOOLS_URL=https://github.com/peterdell/wudsn-ide-tools/archive/refs/heads/main.zip

set DOWNLOADS_URL=https://www.wudsn.com/productions/java/ide/downloads

set ECLIPSE_FILE=eclipse-platform-4.19-win32-x86_64.zip
set ECLIPSE_URL=%DOWNLOADS_URL%/%ECLIPSE_FILE%
set ECLIPSE_FOLDER_NAME=eclipse
set ECLIPSE_FOLDER=%WUDSN_FOLDER%\Tools\IDE\Eclipse
set ECLIPSE_RUNTIME_FOLDER=%ECLIPSE_FOLDER%\eclipse
set ECLIPSE_APP=%ECLIPSE_RUNTIME_FOLDER%\eclipse.exe

set JRE_FILE=openjdk-16.0.2_windows-x64_bin.zip
set JRE_URL=%DOWNLOADS_URL%/%JRE_FILE%
set JRE_FOLDER_NAME=jdk-16.0.2

if exist %ECLIPSE_APP% goto :start_eclipse

echo Press RETURN to install WUDSN IDE in %WUDSN_FOLDER%
pause
if not exist %INSTALL_FOLDER% mkdir %INSTALL_FOLDER%
pushd %INSTALL_FOLDER%
echo on
call :download_repo wudsn-ide-tools %TOOLS_FOLDER%
rem if ERRORLEVEL 1 goto :error

call :download %ECLIPSE_FILE% %ECLIPSE_URL% %ECLIPSE_FOLDER_NAME% %ECLIPSE_FOLDER% FAIL
if ERRORLEVEL 1 goto :error

call :download %JRE_FILE%     %JRE_URL%     %JRE_FOLDER_NAME%     %ECLIPSE_RUNTIME_FOLDER% FAIL
if ERRORLEVEL 1 goto :error
rmdir /S/Q %ECLIPSE_RUNTIME_FOLDER%\jre
move %ECLIPSE_RUNTIME_FOLDER%\%JRE_FOLDER_NAME% %ECLIPSE_RUNTIME_FOLDER%\jre

echo Installing WUDSN IDE feature.
rem See http://help.eclipse.org/latest/index.jsp?topic=/org.eclipse.platform.doc.isv/guide/p2_director.html
%ECLIPSE_RUNTIME_FOLDER%\eclipsec.exe -nosplash -application org.eclipse.equinox.p2.director -repository https://www.wudsn.com/update -installIU com.wudsn.ide.feature.feature.group -destination %ECLIPSE_RUNTIME_FOLDER%

call :download_repo wudsn-ide-workspace %WORKSPACE_FOLDER%.
if ERRORLEVEL 1 goto :error

echo Installing WUDSN defaults for workspace %WORKSPACE_FOLDER%.
set SETTINGS_FOLDER=%ECLIPSE_RUNTIME_FOLDER%\configuration\.settings
set PREFS=%SETTINGS_FOLDER%\org.eclipse.ui.ide.prefs
if not exist %SETTINGS_FOLDER% mkdir %SETTINGS_FOLDER%

set RECENT_WORKSPACES=%WORKSPACE_FOLDER:\=\\%
echo MAX_RECENT_WORKSPACES=10>%PREFS%
echo RECENT_WORKSPACES=%RECENT_WORKSPACES%>>%PREFS%
echo RECENT_WORKSPACES_PROTOCOL=^3>>%PREFS%
echo SHOW_RECENT_WORKSPACES=false>>%PREFS%
echo SHOW_WORKSPACE_SELECTION_DIALOG=false>>%PREFS%
echo eclipse.preferences.version=^1>>%PREFS%

popd

:start_eclipse
echo Starting WUDSN IDE.
start %ECLIPSE_RUNTIME_FOLDER%\eclipse.exe
