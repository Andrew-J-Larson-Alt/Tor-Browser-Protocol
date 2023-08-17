@echo off
REM This protocol allows for redirecting tor browser links to the TOR browser from inside other browsers/web based programs.
REM Copyright (C) 2020  Andrew Larson (andrew.j.larson18+github+alt@gmail.com)
REM
REM This program is free software: you can redistribute it and/or modify
REM it under the terms of the GNU General Public License as published by
REM the Free Software Foundation, either version 3 of the License, or
REM (at your option) any later version.
REM
REM This program is distributed in the hope that it will be useful,
REM but WITHOUT ANY WARRANTY; without even the implied warranty of
REM MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
REM GNU General Public License for more details.
REM
REM You should have received a copy of the GNU General Public License
REM along with this program.  If not, see <https://www.gnu.org/licenses/>.

REM PUT ME IN THE "Tor Browser" FOLDER

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
    del /q "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
::--------------------------------------

if not exist "%cd%" goto error_install
set "tor_dir=%cd%"

set "type_action=install"
if exist "%tor_dir%\opentor.bat" set "type_action=uninstall"

choice /n /c YE /m "Do you wish to %type_action% the Tor Browser protocol? ([Y]es, [E]xit)"
if errorlevel 2 goto end_it
echo.
if "%type_action%"=="uninstall" goto uninstall

:install
REM create protocol script
if not exist "%tor_dir%\Browser\firefox.exe" goto error_install
if exist "%tor_dir%\opentor.bat" del /f /q "%tor_dir%\opentor.bat"
echo @echo off > "%tor_dir%\opentor.bat"
echo if [%%1] == [] goto :eof >> "%tor_dir%\opentor.bat"
echo set "browser_dir=%tor_dir%\Browser\firefox.exe" >> "%tor_dir%\opentor.bat"
echo set "url=%%1" >> "%tor_dir%\opentor.bat"
echo echo %%1 ^| find "tor-browser://" ^> nul >> "%tor_dir%\opentor.bat"
echo if errorlevel 0 set "url=%%url:~15,-1%%" >> "%tor_dir%\opentor.bat"
echo tasklist /fi "imagename eq firefox.exe" ^| find ":" ^> nul >> "%tor_dir%\opentor.bat"
echo if errorlevel 1 ( >> "%tor_dir%\opentor.bat"
echo start /b "" "%%browser_dir%%" --allow-remote --new-tab "%%url%%" >> "%tor_dir%\opentor.bat"
echo exit >> "%tor_dir%\opentor.bat"
echo ) >> "%tor_dir%\opentor.bat"
echo start /b "" "%%browser_dir%%" --allow-remote "%%url%%" >> "%tor_dir%\opentor.bat"
echo exit >> "%tor_dir%\opentor.bat"
REM registry install
reg add HKCR\tor-browser /ve /d "URL:tor-browser Protocol" /f > nul
reg add HKCR\tor-browser /v "URL Protocol" /t REG_SZ /f > nul
reg add HKCR\tor-browser\shell\open\command /ve /d "\"%tor_dir%\opentor.bat\" \"%%1\"" /f > nul
echo Successfully installed.
goto end_it

:uninstall
reg delete HKCR\tor-browser /f > nul
if exist "%tor_dir%\opentor.bat" del /f /q "%tor_dir%\opentor.bat"
echo Successfully uninstalled.
goto end_it

:error_install
echo Error: Missing the files needed to install...
echo Please make sure this script is inside the "Tor Browser" folder
echo Unsuccessfully installed.

:end_it
echo. && pause
exit
