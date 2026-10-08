@echo off
REM Lost Fantasy installer wrapper for cmd.exe (plain Command Prompt, no PowerShell typing needed).
REM Downloads and runs install.ps1 via Windows PowerShell under the hood.
REM Usage from cmd.exe:
REM   curl -L -o install.cmd https://raw.githubusercontent.com/shader006/lost-fantasy-tool/main/install.cmd ^&^& install.cmd
REM Install folder: mac dinh = chinh thu muc chua install.cmd (de lost_fantasy_cli.exe nam canh file nay).
REM Muon cai cho khac:
REM   set LF_DIR=C:\LostFantasy
REM   install.cmd
setlocal
if not defined LF_DIR set "LF_DIR=%~dp0"
if "%LF_DIR:~-1%"=="\" set "LF_DIR=%LF_DIR:~0,-1%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (irm 'https://raw.githubusercontent.com/shader006/lost-fantasy-tool/main/install.ps1')"
endlocal
