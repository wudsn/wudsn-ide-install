@echo off
rem
rem WUDSN IDE Installer - Version 2023-01-29 for Windows, 64-bit.
rem Visit https://www.wudsn.com for the latest version.
rem Use https://www.shellcheck.net to validate the .sh script source.
rem

goto :main_script

rem
rem Print the quoted string %1 on the screen.
rem
:print
  echo %~1
  goto :eof
  
rem
rem Display logged error messages and exit the shell.
rem
:error
  call :print "ERROR: See messages above and in %LOG%."
  start notepad.exe "%LOG%"
  pause
  exit 1

rem
rem  Append message %1 to the log.
rem
:log_message
  echo | set /p=%1 >>%LOG%
  echo. >>%LOG%
  goto :eof

rem
rem Display progress activity %1.
rem
:begin_progress
  echo | set /p=%1
  echo.
  call :log_message "%1"
  goto :eof

rem
rem Display progress message %1.
rem
:display_progress
  call :log_message "%1"
  goto :eof

rem
rem Create the folder %1 including intermediate folders.
rem
:create_folder
  if not exist "%1" (
    mkdir "%1"
  )
  goto :eof

rem
rem Remove the folder %1 and its contents if it exists.
rem
:remove_folder
  if exist "%1" (
    call :display_progress "Removing folder %1."
    rmdir /S/Q "%1"
    if exist "%1" (
      call :display_progress "ERROR: Cannot remove folder %1."
      call :error
    )
  )
  goto :eof

rem
rem Install missing commands.
rem
:install_commands
rem curl and tar are part of the standard Windows installation starting with Windows 10.
set SYSTEM32=https://wudsn.com/productions/java/ide/downloads/windows-system32.zip

where curl >NUL
if ERRORLEVEL 1 (
  call :print "The program curl.exe is missing in your %WINDIR%\System32 folder."
  call :print "Download %SYSTEM32% and extract the contents to that folder."
  goto :error
)

where tar >NUL
if ERRORLEVEL 1 (
  call :print "The program tar.exe is missing in your %WINDIR%\System32 folder."
  call :print "Download %SYSTEM32% and extract the contents to that folder."
  goto :error
)

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
  
  if not exist "%FILE%" (
    call :display_progress "Downloading %FILE% from %URL%."
    curl --silent --show-error --location %URL% --output %FILE%
  ) else (
    call :display_progress "File %FILE% is present."
  )
  
  if exist "%TARGET%" (
    call :remove_folder %TARGET%
  )
  call :create_folder %TARGET_FOLDER%
  
  call :display_progress "Unpacking %FILE% to %TARGET_FOLDER%."
  tar -xf %FILE% -C %TARGET_FOLDER% 2>>%LOG%
  if ERRORLEVEL 1 (
     if "%MODE%" == "FAIL" (
       call :error
     )
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

  set REPO_BRANCH_FOLDER=%INSTALL_FOLDER%\%REPO_BRANCH%

  call :display_progress "Copying files to %REPO_TARGET_FOLDER%."
  call :create_folder %REPO_TARGET_FOLDER%
  xcopy /E /R /Y /Q %REPO_BRANCH%\*.* %REPO_TARGET_FOLDER% >>%LOG%
  call :remove_folder %REPO_BRANCH_FOLDER%
  goto :eof


rem 
rem Check that the workspace is unlocked.
rem
:check_workspace_lock
  set WORKSPACE_LOCK=%WORKSPACE_FOLDER%\.metadata\.lock
  :workspace_locked
  if exist %WORKSPACE_LOCK%. del %WORKSPACE_LOCK% 2>>%LOG%
  if exist %WORKSPACE_LOCK% (
    call :print "ERROR: Workspace %WORKSPACE_FOLDER% is locked. Close Eclipse first."
    pause
    goto :workspace_locked
  )
  goto :eof



rem
rem Select install mode.
rem
:select_install_mode
  set INSTALL_MODE=%1

  if "%INSTALL_MODE%" == "--install-all-from-server" (
    goto :eof
  )

  if "%INSTALL_MODE%" == "" (
    if not exist "%PROJECTS_FOLDER%" (
      set INSTALL_MODE=--install-all-from-server
      goto :eof
    ) else if not exist "%INSTALL_FOLDER%" (
      set INSTALL_MODE=--install
      goto :eof
    )
  )

  if "%INSTALL_MODE%" == "--install-ide-from-cache" (
    goto :eof
  )
  if "%INSTALL_MODE%" == "--install-ide-from-server" (
    goto :eof
  )
  if "%INSTALL_MODE%" == "--install-workspace" (
    goto :eof
  )

  if exist "%ECLIPSE_APP_FOLDER%" (
    if "%INSTALL_MODE%" == "--start-eclipse" (
      goto :eof
    )
  )

  if "%INSTALL_MODE%" == "--install" (
    call :display_install_menu
    goto :eof
  )
  
  if not "%INSTALL_MODE%" == "" (
     call :print "ERROR: Invalid install mode '%INSTALL_MODE%'. Use one of these options."
     echo wudsn.exe --install-ide-from-cache^|--install-ide-from-server^|--install-all-from-server^|--install-workspace^|--start-eclipse
     echo.
     call :display_install_menu
     goto :eof
  )
  
  if exist "%ECLIPSE_APP_FOLDER%" (
    set INSTALL_MODE=--start-eclipse
  )

  goto :eof

rem
rem Display the installer menu and prompt the user for selection.
rem
:display_install_menu
  call :print "WUDSN IDE Installer"
  call :print "==================="
  echo.
  call :print "Close all open Eclipse processes."
  call :print "Select your option to reinstall the %WUDSN_VERSION% version of WUDSN IDE in %WUDSN_FOLDER%"
  
  :choose_install_mode
  call :print "1) Delete IDE, then install IDE from local cache"
  call :print "2) Delete local cache and IDE, then install IDE from server"
  call :print "3) Delete local cache, IDE, projects and workspace, then install everything from server"
  call :print "s) Start WUDSN IDE"
  call :print "x) Exit installer"
  set ID=
  set /p ID="Your choice: "
  if "%ID%" == "1" (
    set INSTALL_MODE=--install-ide-from-cache
    goto :eof

  ) else if "%ID%" == "2" (
    set INSTALL_MODE=--install-ide-from-server
    goto :eof

  ) else if "%ID%" == "3" (
    set INSTALL_MODE=--install-all-from-server
    goto :eof

  ) else if "%ID%" == "s" (
    set INSTALL_MODE=--start_eclipse
    goto :eof

  ) else if "%ID%" == "x" (
    exit 0
  )
  goto :choose_install_mode




rem
rem Install tools.
rem
:install_tools
  call :begin_progress "Installing Tools."
  set TOOLS_FOLDER=%1
  call :download_repo wudsn-ide-tools %TOOLS_FOLDER%
  goto :eof

rem
rem Install Eclipse.
rem
:install_eclipse
  set ECLIPSE_APP_FOLDER=%1
  if exist "%ECLIPSE_APP_FOLDER%" (
    goto :eof
  )
  call :begin_progress "Installing Eclipse."
  call :download %ECLIPSE_FILE% %ECLIPSE_URL% %ECLIPSE_FOLDER_NAME% %ECLIPSE_APP_FOLDER% FAIL
  if ERRORLEVEL 1 (
    call :error
  )
  call :install_java
  call :install_wudsn_ide_feature
  goto :eof


























rem
rem Install Java.
rem
:install_java
  call :begin_progress "Installing Java."
  call :download %JRE_FILE% %JRE_URL% %JRE_FOLDER_NAME% %ECLIPSE_RUNTIME_FOLDER% FAIL
  if ERRORLEVEL 1 (
    call :error
  )
  if exist %ECLIPSE_RUNTIME_FOLDER%\jre. rmdir /S/Q %ECLIPSE_RUNTIME_FOLDER%\jre
  move %ECLIPSE_RUNTIME_FOLDER%\%JRE_FOLDER_NAME% %ECLIPSE_RUNTIME_FOLDER%\jre >>%LOG%
  goto :eof












rem
rem Install WUDSN IDE feature.
rem
:install_wudsn_ide_feature
  call :begin_progress "Installing WUDSN IDE feature."
  rem See http://help.eclipse.org/latest/index.jsp?topic=/org.eclipse.platform.doc.isv/guide/p2_director.html
  %ECLIPSE_RUNTIME_FOLDER%\eclipsec.exe -nosplash -application org.eclipse.equinox.p2.director -repository %UPDATE_URL% -installIU com.wudsn.ide.feature.feature.group -destination %ECLIPSE_RUNTIME_FOLDER% 2>>%LOG% >>%LOG%.tmp
  type %LOG%.tmp >>%LOG%
  del /Q %LOG%.tmp
  goto :eof

rem
rem Install projects.
rem
:install_projects
  set PROJECTS_FOLDER=%1
  if not exist "%PROJECTS_FOLDER%" (
    call :begin_progress "Installing Projects."
    call :download_repo wudsn-ide-projects %PROJECTS_FOLDER%
  )
  goto :eof

rem
rem Create an Eclipse preferences file.
rem
:create_prefs
  set PREFS=%SETTINGS_FOLDER%\%1
  echo eclipse.preferences.version=^1>%PREFS%
  goto :eof

rem
rem Create the workspace folder and initialize its preferences.
rem
:create_workspace_folder
  set WORKSPACE_FOLDER=%1
  if exist %WORKSPACE_FOLDER% (
    goto :eof
  )
  call :display_progress "Installing WUDSN defaults for workspace %WORKSPACE_FOLDER%."
  call :create_folder %WORKSPACE_FOLDER%

  set SETTINGS_FOLDER=%WORKSPACE_FOLDER%\.metadata\.plugins\org.eclipse.core.runtime\.settings
  call :create_folder %SETTINGS_FOLDER%

  call :create_prefs org.eclipse.ui.ide.prefs
  set RECENT_WORKSPACES=%WORKSPACE_FOLDER:\=\\%
  echo MAX_RECENT_WORKSPACES=10>>%PREFS%
  echo RECENT_WORKSPACES=%RECENT_WORKSPACES% >>%PREFS%
  echo RECENT_WORKSPACES_PROTOCOL=^3>>%PREFS%
  echo SHOW_RECENT_WORKSPACES=false>>%PREFS%
  echo SHOW_WORKSPACE_SELECTION_DIALOG=false>>%PREFS%
  
  call :create_prefs org.eclipse.ui.editors.prefs
  echo tabWidth=^8>>%PREFS%
  
  call :create_prefs org.eclipse.ui.prefs
  echo showIntro=false>>%PREFS%

  set WORKSPACE_CREATED=1
  goto :eof

rem
rem Start Eclipse in new process.
rem
:start_eclipse
  if "%WORKSPACE_CREATED%" == "2" (
    call :begin_progress "Starting WUDSN IDE for import projects from %PROJECTS_FOLDER%."
    start %ECLIPSE_EXECUTABLE% -noSplash -import %PROJECTS_FOLDER%
  ) else (
    call :begin_progress "Starting WUDSN IDE in new window."
    start %ECLIPSE_EXECUTABLE% -noSplash -data %WORKSPACE_FOLDER%
  )
  goto :eof

rem
rem Handle install mode. 
rem
:handle_install_mode
  call :display_progress "Selected install mode is '%INSTALL_MODE%'."
  if "%INSTALL_MODE%" == "--start-eclipse" (
      call :start_eclipse
      exit 0
  ) else if "%INSTALL_MODE%" == "--install-all-from-server" (
      call :begin_progress "Starting full installation of %WUDSN_VERSION% version from server %SITE_URL%."
      call :remove_folder %WORKSPACE_FOLDER%
      call :remove_folder %PROJECTS_FOLDER%
      call :remove_folder %INSTALL_FOLDER%
      call :remove_folder %TOOLS_FOLDER%
  ) else if "%INSTALL_MODE%" == "--install-ide-from-server" (
      call :begin_progress "Starting IDE installation %WUDSN_VERSION% version from server %SITE_URL%."
      call :remove_folder %INSTALL_FOLDER%
      call :remove_folder %TOOLS_FOLDER%
  ) else if "%INSTALL_MODE%" == "--install-ide-from-cache" (
      call :begin_progress "Starting IDE installation from local cache."
      call :remove_folder %TOOLS_FOLDER%
  ) else if "%INSTALL_MODE%" == "--install-workspace" (
      call :begin_progress "Starting workspace installation."
      call :remove_folder %WORKSPACE_FOLDER%
      call :remove_folder %PROJECTS_FOLDER%
  ) else (
    call :display_progress "ERROR: Invalid install mode '%INSTALL_MODE%'."
    call :error
  )
  goto :eof

rem
rem Detect the OS type and architecture and set dependent variables.
rem
:detect_os_type
  rem https://archive.eclipse.org/eclipse/downloads/drops4/R-4.26-202211231800/
  set ECLIPSE_VERSION=4.26
  set ECLIPSE_FILES[0]=eclipse-platform-%ECLIPSE_VERSION%-win32-x86_64.zip
  rem set ECLIPSE_FILES[1]=eclipse-platform-%ECLIPSE_VERSION%-win32-aarch64.zip

  rem https://jdk.java.net/archive/
  set JRE_VERSION=19.0.1
  set JRE_FILES[0]=openjdk-%JRE_VERSION%_windows-x64_bin.zip
  rem set JRE_FILES[1]=openjdk-%JRE_VERSION%_windows-aarch64.bin.zip
  
  set OS_INDEX=0

  setlocal enableDelayedExpansion
    set ECLIPSE_FILE=!ECLIPSE_FILES[%OS_INDEX%]!
  endlocal & set ECLIPSE_FILE=%ECLIPSE_FILE%
  set ECLIPSE_URL=%DOWNLOADS_URL%/%ECLIPSE_FILE%
  set ECLIPSE_FOLDER_NAME=eclipse
  set ECLIPSE_FOLDER=%TOOLS_FOLDER%\IDE\Eclipse
  set ECLIPSE_APP_FOLDER=%ECLIPSE_FOLDER%
  set ECLIPSE_RUNTIME_FOLDER=%ECLIPSE_FOLDER%\%ECLIPSE_FOLDER_NAME%
  set ECLIPSE_APP_NAME=eclipse.exe
  set ECLIPSE_EXECUTABLE=%ECLIPSE_RUNTIME_FOLDER%\%ECLIPSE_APP_NAME%
  
  setlocal enableDelayedExpansion
    set JRE_FILE=!JRE_FILES[%OS_INDEX%]!
  endlocal & set JRE_FILE=%JRE_FILE%
  set JRE_URL=%DOWNLOADS_URL%/%JRE_FILE%
  set JRE_FOLDER_NAME=jdk-%JRE_VERSION%

goto :eof

rem
rem Main function.
rem
:main
  set SCRIPT_FOLDER=%CD%
  set LOG=%SCRIPT_FOLDER%\wudsn.log
  date /T >%LOG%
  time /T >>%LOG%
  call :display_progress %1

  call :begin_progress "Checking installation in %SCRIPT_FOLDER%."
  echo.

  set WUDSN_FOLDER=%SCRIPT_FOLDER%
  set INSTALL_FOLDER=%WUDSN_FOLDER%\Install
  set TOOLS_FOLDER=%WUDSN_FOLDER%\Tools
  set PROJECTS_FOLDER=%WUDSN_FOLDER%\Projects
  set WORKSPACE_FOLDER=%WUDSN_FOLDER%\Workspace
  
  if "%SITE_URL%" == "" (
    set SITE_URL=https://www.wudsn.com
  )

  if "%WUDSN_VERSION%" == "" (
    set WUDSN_VERSION=stable
  )

  set DOWNLOADS_URL=%SITE_URL%/productions/java/ide/downloads
  set UPDATE_URL=%SITE_URL%/update/%WUDSN_VERSION%
  
  call :detect_os_type
  call :check_workspace_lock
  call :select_install_mode %1
  call :handle_install_mode
  
  call :log_message "Environment variables:"
  set >>%LOG%
  
  call :create_folder %INSTALL_FOLDER%
  pushd %INSTALL_FOLDER%

  call :install_commands
  call :install_tools %TOOLS_FOLDER%
  call :install_eclipse %ECLIPSE_APP_FOLDER%
  call :install_projects %PROJECTS_FOLDER%
  call :create_workspace_folder %WORKSPACE_FOLDER%

  popd
  
  call :start_eclipse
  goto :eof

rem
rem Main script
rem
:main_script
  pushd "%~dp0"
  setlocal
  setlocal enableextensions enabledelayedexpansion
  call :main %1
  popd
  goto :eof
