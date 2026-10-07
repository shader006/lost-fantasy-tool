@echo off
REM Lost Fantasy installer wrapper for cmd.exe (plain Command Prompt, no PowerShell typing needed).
REM Downloads and runs install.ps1 via Windows PowerShell under the hood.
REM Usage from cmd.exe:
REM   curl -L -o install.cmd https://raw.githubusercontent.com/shader006/lost-fantasy-tool/main/install.cmd ^&^& install.cmd
REM Custom install folder:
REM   set LF_DIR=C:\LostFantasy
REM   install.cmd
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (irm 'https://raw.githubusercontent.com/shader006/lost-fantasy-tool/main/install.ps1')"
endlocal
