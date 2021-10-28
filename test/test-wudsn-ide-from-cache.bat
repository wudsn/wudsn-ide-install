@echo off
cd ..
call build/build.bat
copy wudsn.exe C:\jac\wudsn\wudsn.exe
C:\jac\wudsn\wudsn.exe