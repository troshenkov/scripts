@echo off
REM ===================================================================
REM Script to Synchronize Time, Execute VBScript, Import Registry File,
REM and Modify Autorun.inf Settings
REM ===================================================================
REM
REM Purpose:
REM   - Synchronize system time with a specified network time server.
REM   - Execute a VBScript located on a network share.
REM   - Import a registry file to configure system settings.
REM   - Modify autorun.inf settings to enhance security by preventing
REM     unauthorized execution from external drives.
REM
REM Usage:
REM   - Ensure the script is executed with administrative privileges.
REM   - Place this script in the appropriate startup folder or configure
REM     it to run at startup via Group Policy or Task Scheduler.
REM
REM Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
REM ===================================================================

REM Set variables
SET SERVER=\\server
SET SCRIPT_PATH=%SERVER%\netlogon\Drv_Ren.vbs
SET REG_FILE=%SERVER%\netlogon\proxy-nimb-nnov-ru.reg
SET DRIVE_LETTER=Z:
SET USERNAME=%USERNAME%

REM Synchronize system time with the network server
echo Synchronizing system time with %SERVER%...
net time %SERVER% /set /yes
if %ERRORLEVEL% neq 0 (
    echo Failed to synchronize time. Ensure you have network connectivity and appropriate permissions.
    exit /b %ERRORLEVEL%
)

REM Execute the VBScript
echo Executing VBScript %SCRIPT_PATH%...
cscript //B %SCRIPT_PATH% //D %DRIVE_LETTER% %USERNAME%
if %ERRORLEVEL% neq 0 (
    echo Failed to execute VBScript. Ensure the script exists and you have execute permissions.
    exit /b %ERRORLEVEL%
)

REM Import the registry file
echo Importing registry file %REG_FILE%...
reg import %REG_FILE%
if %ERRORLEVEL% neq 0 (
    echo Failed to import registry file. Ensure the file exists and you have appropriate permissions.
    exit /b %ERRORLEVEL%
)

REM Modify autorun.inf settings to enhance security
echo Modifying autorun.inf settings for enhanced security...
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\IniFileMapping\Autorun.inf" /ve /d "@SYS:DoesNotExist" /f
if %ERRORLEVEL% neq 0 (
    echo Failed to modify autorun.inf settings. Ensure you have administrative privileges.
    exit /b %ERRORLEVEL%
)

echo Script executed successfully.
exit /b 0
