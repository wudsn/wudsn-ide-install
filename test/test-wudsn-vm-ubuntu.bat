@echo off
cd /D "%~dp0"
echo Creating Clean Virtual Box Image from Template
set TO=Ubuntu 22.04 (64bit)
set FROM=%TO% - Template
rmdir /Q/S "%TO%
mkdir "%TO%"
copy /B "%FROM%\*" "%TO%"
attrib -r "%TO%" /S /D
start "%TO%" "%TO%\%TO%.vbox"
