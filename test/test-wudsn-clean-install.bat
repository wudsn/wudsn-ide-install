@echo off
setlocal
cd C:\jac
set INSTALLER_URL=https://github.com/peterdell/wudsn-ide-install/raw/main
set SITE_URL=http://localhost:8080
echo Ensure XAMPP is active at %SITE_URL%.
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
curl --show-error --location %INSTALLER_URL%/%WUDSN_EXE% --time-cond %WUDSN_EXE% --output %WUDSN_EXE%
echo Starting WUDSN IDE as new process.
%WUDSN_EXE%%
popd
goto :eof