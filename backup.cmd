@ECHO OFF

:Vars
	SETLOCAL ENABLEDELAYEDEXPANSION

	SET INI=%~dpn0.ini
	SET LOG=%~dpn0.log
	SET BACKUPDIR=Z:\ManualBackup
	SET TO_LOG=^>^> "%LOG%"
	SET QUIETLY=^> NUL 2^>^&1
	SET COPY=%WINDIR%\system32\robocopy.exe
	SET EXCLUDES=/XJ /XF "%USERPROFILE%\NTUSER.DAT"
	SET COPYFLAGS=/MIR %EXCLUDES% /R:1 /W:5
	REM For list-only, un-comment the following line
	REM SET COPYFLAGS=%COPYFLAGS% /L

:Start
	ECHO ------------------------------------------------------------- %TO_LOG%
	CALL :Tee Starting backup...
	ECHO ------------------------------------------------------------- %TO_LOG%

	IF NOT EXIST "%BACKUPDIR%" MKDIR "%BACKUPDIR%" %QUIETLY%
	IF ERRORLEVEL 1 (
		GOTO ErrNoDir
	)

	FOR /F %%d IN (%INI%) DO (
		CALL :Backup %%d
	)
	GOTO :EOF

:Backup
	SET SRC=%*

	SET DST=%*
	SET DST=%DST:\=_%
	SET DST=%DST::=_%

	CALL :Tee Backing up from %SRC% to %BACKUPDIR%\%DST%

	IF NOT EXIST "%BACKUPDIR%\%DST%" MKDIR "%BACKUPDIR%\%DST%" %QUIETLY%
	IF ERRORLEVEL 1 (
		CALL :Tee ERROR: Could not create %BACKUPDIR%\%DST%
	)

	SET CMDLINE="%COPY%" "%SRC%" "%BACKUPDIR%\%DST%" %COPYFLAGS% %TO_LOG%

	CALL :Tee %CMDLINE%
	%CMDLINE% %TO_LOG%

	GOTO :EOF

:ErrNoDir
	CALL :Tee ERROR: Could not find or create %BACKUPDIR%
	GOTO :EOF

:Tee
	ECHO %~nx0: %*
	ECHO %~nx0: %DATE% %TIME%: %* %TO_LOG%

	GOTO :EOF

