@echo off
set TEST_DIR=..\out\wudsn
call ..\build\build.bat
copy ..\wudsn.exe %TEST_DIR%
pushd %TEST_DIR%

rem set DOWNLOADS_URL
wudsn.exe %*

popd

