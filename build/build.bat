setlocal
cd /D "%~dp0"
if exist settings DEL /Q settings
cd ..
set NAME=wudsn
set PRODUCT_VERSION=1.7.2
set BAT_FILE=%NAME%.bat
set EXE_FILE=%CD%\%NAME%.exe
set ICO_FILE=%CD%\build\wudsn-64x64.ico

if exist %EXE_FILE%. del /Q %EXE_FILE%
for /f "delims=" %%# in ('powershell get-date -format "{yyyy.MM.dd.HHmm}"') do @set FILE_VERSION=%%#
for /f "delims=" %%# in ('powershell get-date -format "{yyyy}"') do @set FILE_YEAR=%%#
set COPYRIGHT=(c) %FILE_YEAR% Peter Dell

set NAME=wudsn
set BAT_FOLDER=%CD%\out\%NAME%
if exist %BAT_FOLDER% (
 rmdir /S/Q %BAT_FOLDER%
)
if exist %BAT_FOLDER% (
  echo ERROR: A process is still using folder %BAT_FOLDER%.
  goto :eof
)

mkdir %BAT_FOLDER%
set BAT_OUT_FILE=%BAT_FOLDER%\%BAT_FILE%
set BAT_HEADER_FILE=%BAT_OUT_FILE%.tmp

rem From https://www.battoexeconverter.com/
set EXE_CONVERTER=C:\Program Files (x86)\Advanced BAT to EXE Converter PRO v4.52\ab2econv452pro\aB2Econv.exe

rem Trailing 0/1/2 can be interpreted as file descriptor numbers.
rem Therefore they must be separated by a space.
echo @echo OFF>%BAT_HEADER_FILE%
echo rem BFCPEOPTIONSTART>>%BAT_HEADER_FILE%
echo rem Advanced BAT to EXE Converter www.BatToExeConverter.com>>%BAT_HEADER_FILE%
echo rem BFCPEEXE=%EXE_OUT_FILE%>>%BAT_HEADER_FILE%
echo rem BFCPEICON=%ICO_FILE%>>%BAT_HEADER_FILE%
echo rem BFCPEICONINDEX=-1 >>%BAT_HEADER_FILE%
echo rem BFCPEEMBEDDISPLAY=0 >>%BAT_HEADER_FILE%
echo rem BFCPEEMBEDDELETE=1 >>%BAT_HEADER_FILE%
echo rem BFCPEADMINEXE=0 >>%BAT_HEADER_FILE%
echo rem BFCPEINVISEXE=0 >>%BAT_HEADER_FILE%
echo rem BFCPEVERINCLUDE=1 >>%BAT_HEADER_FILE%
echo rem BFCPEVERVERSION=%FILE_VERSION% >>%BAT_HEADER_FILE%
echo rem BFCPEVERPRODUCT=WUDSN IDE Installer>>%BAT_HEADER_FILE%
echo rem BFCPEVERDESC=Visit www.wudsn.com>>%BAT_HEADER_FILE%
echo rem BFCPEVERCOMPANY=WUDSN>>%BAT_HEADER_FILE%
echo rem BFCPEVERCOPYRIGHT=%COPYRIGHT%>>%BAT_HEADER_FILE%
echo rem BFCPEWINDOWCENTER=1 >>%BAT_HEADER_FILE%
echo rem BFCPEDISABLEQE=1 >>%BAT_HEADER_FILE%
echo rem BFCPEWINDOWHEIGHT=125 >>%BAT_HEADER_FILE%
echo rem BFCPEWINDOWWIDTH=132 >>%BAT_HEADER_FILE%
echo rem BFCPEWTITLE=WUDSN IDE Installer>>%BAT_HEADER_FILE%
echo rem BFCPEOPTIONEND>>%BAT_HEADER_FILE%

copy /b %BAT_HEADER_FILE%+%BAT_FILE% %BAT_OUT_FILE% >NUL

"%EXE_CONVERTER%" %BAT_OUT_FILE%  %EXE_FILE%
if ERRORLEVEL 1 (
  echo ERROR: "%EXE_CONVERTER%" is not available.
  pause
  goto :eof
)

rem Signing is currently not relevant
rem 
rem set SIGNTOOL=C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x86\signtool.exe
rem set SIGNTOOL_PFX_FILE=build\build.pfx
rem set SIGNTOOL_PFX_PASSWORD=
rem if not defined SIGNTOOL_PFX_PASSWORD (
rem   echo Environment variable SIGNTOOL_PFX_PASSWORD is not set.
rem   exit /B 1
rem )
rem 
rem "%SIGNTOOL%" sign /f %SIGNTOOL_PFX_FILE% /p %SIGNTOOL_PFX_PASSWORD% /tr http://timestamp.digicert.com /td SHA256 /fd SHA256 %EXE_FILE%
rem goto :eof
