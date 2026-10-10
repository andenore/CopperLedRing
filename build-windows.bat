 @echo off
 setlocal EnableExtensions

 rem Windows launcher for the repository Makefile. Override these environment variables when needed.
 if not defined KICAD_CLI if exist "%ProgramFiles%\KiCad\10.0\bin\kicad-cli.exe" set "KICAD_CLI=%ProgramFiles%\KiCad\10.0\bin\kicad-cli.exe"
 if not defined FOOTPRINT_ROOT if exist "%ProgramFiles%\KiCad\10.0\share\kicad\footprints" set "FOOTPRINT_ROOT=%ProgramFiles%\KiCad\10.0\share\kicad\footprints"

 where make >nul 2>nul
 if errorlevel 1 (
     echo GNU Make was not found on PATH. Install GNU Make or use WSL/MSYS2.
     exit /b 1
 )

 make %*
 exit /b %ERRORLEVEL%
