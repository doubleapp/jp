@echo off
REM ============================================================================
REM Directory Shortcuts - Simple Aliases for CMD
REM ============================================================================
REM This file creates quick aliases to jump to your frequently used directories
REM
REM Usage:
REM   1. Edit this file and add your project paths below
REM   2. Run this file at the start of each CMD session
REM   3. OR run install.bat to auto-load this on every CMD session
REM
REM Example shortcuts are provided below - customize them to your needs!
REM ============================================================================

REM Define your project shortcuts here (edit these!)
doskey cdweb=cd /d e:\EProjects\doubletap\storewebsite
doskey cdhome=cd /d C:\Users\%USERNAME%

REM Add more shortcuts as needed:
REM doskey cdapi=cd /d e:\EProjects\myapi
REM doskey cddb=cd /d C:\projects\database
REM doskey cddocs=cd /d C:\Users\%USERNAME%\Documents
REM doskey cddown=cd /d C:\Users\%USERNAME%\Downloads

REM Utility shortcuts
doskey cls=cls
doskey ls=dir /b $*
doskey ll=dir $*

REM Show available shortcuts
echo.
echo ========================================
echo Directory Shortcuts Loaded!
echo ========================================
echo   cdweb   - Website project
echo   cdhome  - Home directory
echo.
echo Edit shortcuts in: %~f0
echo ========================================
echo.
