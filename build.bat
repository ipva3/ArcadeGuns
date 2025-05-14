@echo off
setlocal enabledelayedexpansion

cd "%~dp0"

:: --- Check If MSVC Compiler Is Enable ---
where /q cl
if %ERRORLEVEL% == 1 (
  set VC_PATH=C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build
  if not defined LIB (if exist "!VC_PATH!" (call "!VC_PATH!\vcvarsall.bat" x64))
)

:: --- Unpack Arguments -------------------------------------------------------
for %%a in (%*) do set "%%a=1"
if not "%release%"=="1" set debug=1
if "%debug%"=="1"   set release=0 && echo [debug mode]
if "%release%"=="1" set debug=0 && echo [release mode]

:: --- Compile/Link Line Definitions ---
set common=     /I..\src /nologo -DUNICODE -D_UNICODE
set cl_debug=   call cl /Od /DBUILD_DEBUG=1 %common%
set cl_release= call cl /O2 /DBUILD_DEBUG=0 %common%
set cl_link=    /link user32.lib "main.res"
set out=        /out:.\bin\

:: --- Compile/Link Lines ---
if "%debug%"=="1" set compile=%cl_debug%
if "%release%"=="1" set compile=%cl_release%

if not exist build mkdir build

pushd build
if not exist bin mkdir bin

call rc /nologo -fo ".\main.res" "..\src\main.rc"
%compile% "..\src\main.c"  %cl_link% %out%arcadeguns.exe || exit /b 1

popd
