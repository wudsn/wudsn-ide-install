@echo off
setlocal
cd /D "%~dp0"
if exist settings DEL /Q settings
cd ..
set NAME=wudsn
set PRODUCT_VERSION=1.7.2
set BAT_FILE=%NAME%.bat
set EXE_FILE=%NAME%.exe

if exist %EXE_FILE%. del /Q %EXE_FILE%
for /f "delims=" %%# in ('powershell get-date -format "{yyyy.MM.dd.HHmm}"') do @set FILE_VERSION=%%#
for /f "delims=" %%# in ('powershell get-date -format "{yyyy}"') do @set FILE_YEAR=%%#
set COPYRIGHT="(c) %FILE_YEAR% Peter Dell"
build\bat2exe /bat %BAT_FILE% /exe %EXE_FILE% /icon build\wudsn.ico ^
              /x64 /workdir 0 /overwrite ^
              /fileversion %FILE_VERSION%  /productname "WUDSN IDE" /productversion %PRODUCT_VERSION% /copyright %COPYRIGHT% /company WUDSN 
