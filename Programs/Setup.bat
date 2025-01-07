@echo off
setlocal enabledelayedexpansion

set OUTPUT=../DK.exe
set INCLUDE_DIR=DK/LuaApi/Include
set SOURCE_DIR=DK/LuaApi
set CFLAGS=-Wall -O2 -I%INCLUDE_DIR%
set SOURCES=

for %%f in (%SOURCE_DIR%\*.c) do (
    set SOURCES=!SOURCES! "%%f"
)

where clang >nul 2>nul
if %ERRORLEVEL% equ 0 (
    set COMPILER=clang
    echo Using clang to compile.
) else (
    set COMPILER=gcc
    echo Using gcc to compile.
)

echo Starting Build: Development-Kit
%COMPILER% DK/DK.c !SOURCES! -o %OUTPUT% %CFLAGS%

if %ERRORLEVEL% neq 0 (
    echo Build Failed!
    pause
    exit /b %ERRORLEVEL%
)

echo Build Success: %OUTPUT%
pause

