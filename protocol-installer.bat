@echo off
REM Created by AlienDrew thealiendrew@gmail.com
REM PUT ME IN THE "Tor Browser" FOLDER

setlocal
:: BatchGotAdmin
::-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"="
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
::--------------------------------------

set "file_dir=%~dp0"
cd "%file_dir%"

if exist "%cd%\opentor.bat" (
	set "type_action=uninstall"
) else (
	set "type_action=install"
)

if "%type_action%"=="install" (
	if not exist "%cd%\Browser\firefox.exe" goto error_install
)

choice /n /c YE /m "Do you wish to %type_action% the Tor Browser? ([Y]es, [E]xit)"
if errorlevel 2 goto end_it
echo.

:install
REM create protocol script
if exist "%cd%\opentor.bat" del /f "%cd%\opentor.bat"
echo @echo off > "%cd%\opentor.bat"
echo if [%%1] == [] goto :eof >> "%cd%\opentor.bat"
echo set "browser_dir=%%userprofile%%\Desktop\Tor Browser\Browser\firefox.exe" >> "%cd%\opentor.bat"
echo set "url=%%1" >> "%cd%\opentor.bat"
echo echo %%1 ^| find "tor-browser://" ^> nul >> "%cd%\opentor.bat"
echo if errorlevel 0 set "url=%%url:~15,-1%%" >> "%cd%\opentor.bat"
echo tasklist /fi "imagename eq firefox.exe" ^| find ":" ^> nul >> "%cd%\opentor.bat"
echo if errorlevel 1 ( >> "%cd%\opentor.bat"
echo start /b "" "%%browser_dir%%" --allow-remote --new-tab "%%url%%" >> "%cd%\opentor.bat"
echo exit >> "%cd%\opentor.bat"
echo ) >> "%cd%\opentor.bat"
echo start /b "" "%%browser_dir%%" --allow-remote "%%url%%" >> "%cd%\opentor.bat"
echo exit >> "%cd%\opentor.bat"
REM registry install
reg add HKCR\tor-browser /ve /d "URL:tor-browser Protocol" /f
reg add HKCR\tor-browser /v "URL Protocol" /t REG_SZ /f
reg add HKCR\tor-browser\shell\open\command /ve /d "\"%tor_dir%\opentor.bat\" \"%%1\"" /f
::--------------------
echo Installation successful.
goto end_it

:uninstall
reg delete HKCR\tor-browser /f
if exist "%cd%\opentor.bat" del /f "%cd%\opentor.bat"

:error_install
echo Error: Missing the files needed to install...
echo Please make sure this script is inside the "Tor Browser" folder

:end_it
echo. && pause
endlocal
exit