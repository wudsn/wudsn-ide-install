@rem Makefile for Windows
@echo off
cd /D "%~dp0"
echo Building "wudsn.exe".
call build\build.bat
echo Building "wudsn.bat.sh" for comparison with "wudsn.sh".
call build\bat2sh.bat >%TEMP%\bat2sh.bat.log
echo Checking ".sh" scripts for correctness.
call build\check-scripts.bat
start .
echo Done.


