@echo off
rem Check all .sh scripts for consistency using shellcheck.
rem See https://www.shellcheck.net/ for the web version.
setlocal
cd /D "%~dp0"
cd ..
set FOLDER=%CD%
set FILE=%FOLDER%\wudsn.bat.sh
for /R %%I in (*.sh) do (
  call :check %%I

)
goto :eof

:check
  if not %1==%FILE% (
    echo Checking %1
    build\shellcheck\shellcheck %1
  )
goto :eof
