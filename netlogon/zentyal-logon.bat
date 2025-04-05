@echo off
REM ===================================================================
REM Windows Client Domain Join and Network Drive Mapping Script
REM ===================================================================
REM
REM Purpose:
REM   - Join the Windows client to the Zentyal domain.
REM   - Map network drives based on user credentials.
REM
REM Usage:
REM   - Run this script with administrative privileges on the Windows client.
REM
REM Author:  Dmitry Troshenkov (troshenkov.d@gmail.com)
REM ===================================================================

REM Set domain and server variables
SET DOMAIN=yourdomain.local
SET SERVER=\\your-zentyal-server
SET USERNAME=%USERNAME%

REM Join the Windows client to the Zentyal domain
echo Joining domain %DOMAIN%...
netdom join %COMPUTERNAME% /domain:%DOMAIN% /userD:Administrator /passwordD:YourAdminPassword
if %ERRORLEVEL% neq 0 (
    echo Failed to join domain. Please check your network connection and credentials.
    exit /b %ERRORLEVEL%
)

REM Map network drives based on user credentials
echo Mapping network drives for user %USERNAME%...
net use Z: %SERVER%\%USERNAME%
if %ERRORLEVEL% neq 0 (
    echo Failed to map network drive Z:. Please check your network connection and permissions.
    exit /b %ERRORLEVEL%
)

echo Script executed successfully.
exit /b 0
