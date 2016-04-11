@echo off
REM Run this file from the CSaruEnv directory to set up your environment.

SET CSaruDir=%cd%

REM if not x%path:CSaruDir=%==x%path% echo Path is prepared

REM TODO : This doesn't find the path when it's already present.
echo "%PATH%" | findstr /C:"%CSaruDir%\bin" 1>nul

if errorlevel 1 (
	echo. CSaru bin dir wasn't already in path; added.
	SET "PATH=%PATH%%CSaruDir%\bin;"
) ELSE (
	echo. CSaru bin dir *already* in path.
)

