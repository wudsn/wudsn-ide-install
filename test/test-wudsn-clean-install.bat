@echo off
setlocal
cd C:\jac
set INSTALLER_URL=https://github.com/peterdell/wudsn-ide-install/raw/main
rem set SITE_URL=http://localhost:8080

:check_site_url
if NOT "%SITE_URL%" == "" (
  curl -sf %SITE_URL% > nul
  IF ERRORLEVEL 1 (
    echo ERROR: %SITE_URL% not reachable. Ensure XAMPP is active.
    pause
    goto :check_site_url
  )
)

set WUDSN_EXE=wudsn.exe

set WUDSN_VERSION=daily
call :install_wudsn
set WUDSN_VERSION=stable
call :install_wudsn
goto :eof

:install_wudsn
echo Installing WUDSN version %WUDSN_VERSION%.
set WUDSN_DIR=wudsn\%WUDSN_VERSION%
if exist %WUDSN_DIR% rmdir /S/Q %WUDSN_DIR%
mkdir %WUDSN_DIR%
pushd %WUDSN_DIR%

if exist %WUDSN_EXE%. (
  set TIME_COND=--time-cond %WUDSN_EXE%
) else (
  set TIME_COND=
)
curl --show-error --location %INSTALLER_URL%/%WUDSN_EXE% %TIME_COND% --output %WUDSN_EXE%
echo Starting WUDSN IDE as new process.
%WUDSN_EXE%%
popd
goto :eof