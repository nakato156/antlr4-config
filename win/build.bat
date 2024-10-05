@echo off

@REM set "antlrRuntimePath=%userprofile%\antlr-runtime"
@REM set "ANTLRRUNTIMEH=%antlrRuntimePath%\runtime\src"
@REM set "ANTLRRUNTIMEDLL=%antlrRuntimePath%\runtime\bin\vs-2022\x64\Debug DLL\antlr4-runtime.dll"
@REM set "ANTLRRUNTIMELIB=%antlrRuntimePath%\runtime\bin\vs-2022\x64\Debug DLL"

echo Antlr4 runtime h: %ANTLRRUNTIMEH%
echo Antlr4 runtime dll: %ANTLRRUNTIMEDLL%
echo Antlr4 runtime lib: %ANTLRRUNTIMELIB%

REM Eliminar el directorio "build" si existe
if exist build (
    rmdir /s /q build
)

REM Crear el directorio "build" y cambiarse a él
mkdir build
cd build

:: Ejecuta devenv para obtener la versión completa de Visual Studio
for /f "tokens=*" %%i in ('devenv -version') do set VS_VERSION=%%i

:: Extrae el número principal de la versión (16, 17, 18, etc.) y el año (2019, 2022, etc.)
for /f "tokens=3,5 delims=. " %%j in ("%VS_VERSION%") do (
    set MAJOR_VERSION=%%j
    set VS_YEAR=%%k
)

:: Muestra la versión extraída
echo Visual Studio Version: %MAJOR_VERSION%
echo Visual Studio Year: %VS_YEAR%

set VS=Visual Studio %MAJOR_VERSION% %VS_YEAR%

cmake .. -G "%VS%"
cmake --build . --config Release