@echo off
cd /D "%~dp0"
cd ..
for /r %%i in (*.sh) do (
  echo Checking %%i
  if not %%I==C:\jac\system\Java\Programming\Repositories\wudsn-ide-install\wudsn.bat.sh (
    build\shellcheck\shellcheck %%i
  ) else (
    echo "WHAT"
  )
)
