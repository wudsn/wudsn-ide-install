@echo off
cd /D "%~dp0"
set TEST_DIR=..\out\wudsn
set PROGRAM=wudsn.exe
call ..\build\build.bat
if ERRORLEVEL 1 (
  echo Build failed.
  pause
  exit /B 1
)
if not exist %TEST_DIR%. mkdir %TEST_DIR%
copy ..\%PROGRAM% %TEST_DIR% >NUL
pushd %TEST_DIR%
echo.

rem set SITE_URL=http://localhost:8080
rem set WUDSN_VERSION=daily
%PROGRAM% %*

popd

