setlocal

if "%2" == "" (
  echo USAGE:   %~nx0 ^<depot path^> ^<enlistment root path^> [shortcut name]
  echo EXAMPLE: %~nx0 //depot/teams/hosted/online d:\p4\hosted_online
  exit /b 1
)

set DEPOT_PATH=%1
set SRCROOT=%2
set ENLIST_NAME=%~nx2
set SHORTCUT_NAME=%3
set CONFIG_PATH=%SRCROOT%\.p4config
if "%P4PORT%" == "" set P4PORT=kr-p4fwdrpl02:1667
if "%P4USER%" == "" set P4USER=%USERNAME%

if exist %SRCROOT% goto :SRCROOT_exists
md %SRCROOT%
if not "%ERRORLEVEL%" == "0" goto :abort
:SRCROOT_exists

set CLIENT_NAME=%USERNAME%_%ENLIST_NAME%

rem Creating client template
set TEMPLATE=%TEMP%\p4_client_template_%CLIENT_NAME%.tmp
echo Client:	%CLIENT_NAME%>%TEMPLATE%
echo Owner:	%USERNAME%>>%TEMPLATE%
echo Host:	%COMPUTERNAME%>>%TEMPLATE%
echo Description:>>%TEMPLATE%
echo 	Created by %USERNAME%.>>%TEMPLATE%
echo Root:	%SRCROOT:\=/%>>%TEMPLATE%
echo Options:	noallwrite noclobber nocompress unlocked nomodtime rmdir>>%TEMPLATE%
echo SubmitOptions:	revertunchanged>>%TEMPLATE%
echo LineEnd:	unix>>%TEMPLATE%
if not "%STREAM%" == "" echo Stream:	//depot/main>>%TEMPLATE%
echo View:>>%TEMPLATE%
echo 	%DEPOT_PATH%/... //%CLIENT_NAME%/...>>%TEMPLATE%

p4 client -i<%TEMPLATE%
if not "%ERRORLEVEL%" == "0" goto :abort
del /q %TEMPLATE%
if not "%ERRORLEVEL%" == "0" echo Error deleting temporary file.
echo P4CLIENT=%CLIENT_NAME%>%CONFIG_PATH%
echo P4PORT=%P4PORT%>>%CONFIG_PATH%
echo P4USER=%P4USER%>>%CONFIG_PATH%
if not "%ERRORLEVEL%" == "0" goto :abort

if "%SHORTCUT_NAME%" == "" goto :skip_shortcut
create_desktop_shortcut.vbs /name:%SHORTCUT_NAME% /target:%COMSPEC% /args:"/K cd /d %SRCROOT% & workgroup\bin\wgenv.cmd" /workingdir:%SRCROOT% /icon:\\filesrv01\Development\CommandPromptIcons\CommandPrompt.ico
if not "%ERRORLEVEL%" == "0" echo Error creating shortcut: %ERRORLEVEL%.

rem Configuring TCP/IP connections
regedit /s %SRCROOT%\workgroup\tools\wgunit_tcpip.reg
if not "%ERRORLEVEL%" == "0" echo Error configuring TCP connections: %ERRORLEVEL%.

:skip_shortcut
set /P DO_SYNC=Sync enlistmen now? (Y/N)
if /I not "%DO_SYNC%" == "Y" goto :skip_sync
start "Syncing %ENLIST_NAME%..." /D %SRCROOT% p4 sync ...
if not "%ERRORLEVEL%" == "0" echo Error starting sync: %ERRORLEVEL%.
:skip_sync

rem Script finished.
goto :eof


:abort
echo Aborting execution. Last error code: %ERRORLOEVEL%
exit /b %ERRORLOEVEL%