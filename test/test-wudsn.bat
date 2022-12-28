@echo off
cd /D "%~dp0"
set TEST_DIR=..\out\wudsn
call ..\build\build.bat
if ERRORLEVEL 1 (
  echo Build failed.
  pause
  exit /B 1
)
if not exist %TEST_DIR% mkdir %TEST_DIR%
copy ..\wudsn.exe %TEST_DIR%
pushd %TEST_DIR%

rem set SITE_URL=http://localhost:8080
rem set WUDSN_VERSION=daily
wudsn.exe %*

popd

