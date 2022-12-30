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
              /x64 /workdir 0 /overwrite /upx ^
              /fileversion %FILE_VERSION%  /productname "WUDSN IDE" /productversion %PRODUCT_VERSION% /copyright %COPYRIGHT% /company WUDSN
              
set SIGNTOOL=C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x86\signtool.exe
set SIGNTOOL_PFX_FILE=build\build.pfx
rem set SIGNTOOL_PFX_PASSWORD=
if not defined SIGNTOOL_PFX_PASSWORD (
  echo Environment variable SIGNTOOL_PFX_PASSWORD is not set.
  exit /B 1
)

"%SIGNTOOL%" sign /f %SIGNTOOL_PFX_FILE% /p %SIGNTOOL_PFX_PASSWORD% /tr http://timestamp.digicert.com /td SHA256 /fd SHA256 %EXE_FILE%
