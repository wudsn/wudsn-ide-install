@echo off
rem
rem The template was downloaded from https://www.osboxes.org/ubuntu/.
rem Changes:
rem - Change password of user osboxes using sudo passwd osboxes password
rem - Enable auto-login for user osboxes in "users" settings
rem - Install German keyboard layout
rem - Add default aliases to /etc/profile
rem - Remove not required apps from favorites
rem - Favouries: Files, Termina, Firefox, Texteditor
rem - Install VM ware guest extensions
rem - Enable bidirectional clipboard
rem - Install Github Desktop from Github Desktop from https://gist.github.com/berkorbay/6feda478a00b0432d13f1fc0a50467f1
rem - Add Github Desktop to favorites
rem - Create folder ~/jac
rem - Shutdown VM image and set read-only attribute in template

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
