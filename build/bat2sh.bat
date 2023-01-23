@echo on
rem Simply hack conversion from .bat to .bat-sh for Eclipse comparison with .sh.
setlocal
cd /D "%~dp0"
set FILE=..\wudsn.bat.sh
copy ..\wudsn.bat %FILE%

fart.exe --c-style %FILE% "\r\n" "\n"
fart.exe --remove %FILE% "set "
fart.exe --c-style %FILE% "rem\n" "#\n"
fart.exe --c-style %FILE% "rem " "# "
fart.exe --remove %FILE% "call :"
fart.exe %FILE% "   goto :eof" "   return"
fart.exe %FILE% "goto :eof" "}"
fart.exe --c-style %FILE% "%%\n" "}\n"

rem %% is the % literal
fart.exe %FILE% " %%1" " \"$1\""
fart.exe %FILE% "%%1" "$1"
fart.exe %FILE% "%%2" "$2"
fart.exe %FILE% "%%3" "$3"
fart.exe %FILE% "%%4" "$4"
fart.exe %FILE% "%%5" "$5"

echo on
rem backslash to slash
fart.exe --c-style %FILE% \\ "\x2F"

fart.exe %FILE% "=%%" "=${"

rem /x25 is the percent sign

rem /x20 is the space
call :replace 20
rem /x22 is the double quote
call :replace 22
rem /x2d is the minus
call :replace 2d
rem /x2e is the period
call :replace 2e
rem /x2f is the forward slash
call :replace 2f
rem /x3e is the greater sign
call :replace 3e

fart.exe %FILE% ".%%" ".${"
fart.exe %FILE% "%%." "}."

fart.exe %FILE% ". (" " ("
fart.exe %FILE% " (" " {"
fart.exe %FILE% ") else if" "elif"
fart.exe %FILE% "  )" "  fi"

fart.exe %FILE% ":a" "a"
fart.exe %FILE% ":b" "b"
fart.exe %FILE% ":c" "c"
fart.exe %FILE% ":d" "d"
fart.exe %FILE% ":e" "e"
fart.exe %FILE% ":f" "f"
fart.exe %FILE% ":g" "g"
fart.exe %FILE% ":h" "h"
fart.exe %FILE% ":i" "i"
fart.exe %FILE% ":j" "j"
fart.exe %FILE% ":k" "k"
fart.exe %FILE% ":l" "l"
fart.exe %FILE% ":m" "m"
fart.exe %FILE% ":n" "n"
fart.exe %FILE% ":o" "o"
fart.exe %FILE% ":p" "p"
fart.exe %FILE% ":q" "q"
fart.exe %FILE% ":r" "r"
fart.exe %FILE% ":s" "s"
fart.exe %FILE% ":t" "t"
fart.exe %FILE% ":u" "u"
fart.exe %FILE% ":v" "v"
fart.exe %FILE% ":w" "w"
fart.exe %FILE% ":x" "x"
fart.exe %FILE% ":y" "y"
fart.exe %FILE% ":z" "z"

fart.exe %FILE% " == " " = "
fart.exe %FILE% "if exist" "if [ -f"
fart.exe %FILE% "if not exist" "if [ ! -f"
fart.exe --c-style %FILE% "if \x22" "if [ \x22"
fart.exe --c-style %FILE% "\x22 {" "\x22 ]; then"

fart.exe %FILE% "echo." "echo"
goto :eof

:replace
rem /x2f is the forward slash
fart.exe --c-style %FILE% "\x%1\x25" "\x%1${"
fart.exe --c-style %FILE% "\x25\x%1" "}\x%1"
goto :eof
