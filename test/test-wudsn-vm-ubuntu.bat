@echo off
rem
rem The template was downloaded from https://www.osboxes.org/ubuntu/.
rem Changes:
rem - Install German keyboard layout
rem - Add default aliases to /etc/profile
rem - Remove not required apps from favorites

echo Creating Clean Virtual Box Image from Template
set TO=Ubuntu 22.04 (64bit)
set FROM=%TO% - Template
if not exist "%FROM%" (
  chdir
  echo ERROR: Folder "%FROM%" is not present in the current folder.
  echo Make sure to run the script with the correct working directory.
  pause
  exit
)

rmdir /Q/S "%TO%
mkdir "%TO%"
copy /B "%FROM%\*" "%TO%"
attrib -r "%TO%" /S /D
start "%TO%" "%TO%\%TO%.vbox"
