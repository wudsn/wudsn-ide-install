@echo on
cd /D "%~dp0"
set SITE_URL=http://localhost:8080
call test-wudsn-clean-install.bat
