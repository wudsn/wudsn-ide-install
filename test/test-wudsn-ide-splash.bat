@echo on
set TEST_FOLDER=C:\jac\wudsn
cd ..
call build/build.bat
copy wudsn.exe %TEST_FOLDER%
cd %TEST_FOLDER%
if exist wudsn.log. del wudsn.log
wudsn.exe --install-ide-from-cache
start .
if exist wudsn.log. start wudsn.log
