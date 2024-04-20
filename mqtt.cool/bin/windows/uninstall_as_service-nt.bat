@echo off
setlocal

rem
rem NSSM mqtt.cool NT service uninstall script
rem

if "%OS%"=="Windows_NT" goto nt
echo This script only works with NT-based versions of Windows.
goto :end

:nt

echo This script must be run as Administrator.
echo Assuming nssm*.exe files have not been moved once the service was installed.
echo ...
echo Please check the output below
echo ...

rem Try to stop the service
net stop mqtt.cool

rem Remove the service
if "%PROCESSOR_ARCHITECTURE%" == "AMD64" goto amd64nssm
goto x86nssm

:x86nssm
"%~dp0\nssm.exe" remove mqtt.cool confirm
goto :end

:amd64nssm
"%~dp0\nssm_x64.exe" remove mqtt.cool confirm

:end
pause
