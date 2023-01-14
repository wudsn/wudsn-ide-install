@echo off
cd /D "%~dp0"
echo Removing output files.
if exist ..\out\wudsn rmdir /S /Q ..\out\wudsn
pause