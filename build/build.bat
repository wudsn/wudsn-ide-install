@echo off
cd "%~dp0"

set MSBUILD="C:\Program Files\Microsoft Visual Studio\2022\Community\Msbuild\Current\Bin\MSBuild.exe"
set RELEASE_DIR=..\cpp\wudsn
set RELEASE_NAME=wudsn
set SLN=%RELEASE_DIR%\%RELEASE_NAME%.sln
set EXE_FILENAME=%RELEASE_NAME%.exe

set PLATFORM=x64
set CONFIGURATION=Release
call :build_configuration
copy  %OUTPUT_FILE% ..\%EXE_FILENAME%
goto :eof

:build_configuration
set OUTPUT_DIR=%RELEASE_DIR%\out\%PLATFORM%\%CONFIGURATION%\output
set OUTPUT_FILE=%OUTPUT_DIR%\%EXE_FILENAME%
echo Building %OUTPUT_FILE%.
if exist %OUTPUT_FILE% del %OUTPUT_FILE%
%MSBUILD% %SLN% /property:Configuration=%CONFIGURATION% -verbosity:quiet -fl -flp:logfile=%OUTPUT_DIR%\msbuild.log
if not exist %OUTPUT_FILE% goto :error
goto :eof

rem Signing is currently not relevant
:sign_executable
rem set SIGNTOOL=C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x86\signtool.exe
rem set SIGNTOOL_PFX_FILE=build\build.pfx
rem set SIGNTOOL_PFX_PASSWORD=
rem if not defined SIGNTOOL_PFX_PASSWORD (
rem   echo Environment variable SIGNTOOL_PFX_PASSWORD is not set.
rem   exit /B 1
rem )
rem 
rem "%SIGNTOOL%" sign /f %SIGNTOOL_PFX_FILE% /p %SIGNTOOL_PFX_PASSWORD% /tr http://timestamp.digicert.com /td SHA256 /fd SHA256 %EXE_FILE%
goto :eof

:error
echo ERROR: See error messages above.
pause
exit

