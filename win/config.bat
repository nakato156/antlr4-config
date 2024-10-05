@echo off

set "vsVersion="
if exist "%ProgramFiles%\Microsoft Visual Studio\2019\" (
    set "vsVersion=2019"
    call "%ProgramFiles%\Microsoft Visual Studio\2019\%vsEdition%\Common7\Tools\VsDevCmd.bat"
) else if exist "%ProgramFiles%\Microsoft Visual Studio\2022\" (
    set "vsVersion=2022"
    call "%ProgramFiles%\Microsoft Visual Studio\2022\%vsEdition%\Common7\Tools\VsDevCmd.bat"    
) else (
    echo "No se ha detectado Visual Studio 2019 0 2022"
    exit /b 1
)

:: Crear carpetas de antlr
set "antlrPath=%userprofile%\antlr"
set "antlrRuntimePath=%userprofile%\antlr-runtime"
set "zipFile=%tempPath%\antlr4-cpp-runtime-4.13.2-source.zip"

mkdir "%antlrPath%"
mkdir "%antlrRuntimePath%"

:: Inicializamos la variable para almacenar la ruta de Java
set "javaPath="

:: Comprobamos si existe jdk-21 o jdk-18
if exist "C:\Program Files\Java\jdk-21" (
    set "javaPath=C:\Program Files\Java\jdk-21"
) else if exist "C:\Program Files\Java\jdk-18" (
    set "javaPath=C:\Program Files\Java\jdk-18"
) else (
    echo No se encontraron JDK 21 o 18
    echo Descargando Java 21...

    :: Descargar Java 21 si no se encontró
    curl --ssl-no-revoke https://download.oracle.com/java/21/latest/jdk-21_windows-x64_bin.exe -o "%antlrPath%\jdk-21_windows-x64_bin.exe"
    start "" /wait "%antlrPath%\jdk-21_windows-x64_bin.exe"
    set "javaPath=C:\Program Files\Java\jdk-21"
)

:: Configuración de variables de entorno
if "%javaPath%" neq "" (
    echo Java encontrado en: %javaPath%
    setx JAVA_HOME "%javaPath%" /m
    :: Actualizar PATH en la sesión actual
    set "PATH=%javaPath%\bin;%PATH%"
    setx PATH "%PATH%"
    echo Variables de entorno actualizadas
) else (
    echo No se encontró una instalación de Java válida
)

echo Verificando Antlr...
if not exist "%antlrPath%\antlr-4.13.2-complete.jar" (
    echo Descargando Antlr...
    :: Descargar antlr
    curl --ssl-no-revoke https://www.antlr.org/download/antlr-4.13.2-complete.jar -o "%antlrPath%\antlr-4.13.2-complete.jar"
)

set "CLASSPATH=%javaPath%\lib;.;%antlrPath%\antlr-4.13.2-complete.jar"

echo Verificando Antlr Runtime Cpp...
set "deployFile=%antlrRuntimePath%\deploy-windows.cmd"

if not exist "%deployFile%" (
    if not exist "%zipFile%" (
        echo Descargando Antlr Runtime Cpp...
        curl --ssl-no-revoke https://www.antlr.org/download/antlr4-cpp-runtime-4.13.2-source.zip -o "%zipFile%"
    )

    if exist "%antlrRuntimePath%\*" (
        echo Eliminando el contenido de %antlrRuntimePath%...
        powershell -command "Remove-Item -Path '%antlrRuntimePath%\*' -Recurse -Force"
    )

    set "sevenZipPath=C:\Program Files\7-Zip\7z.exe"

    if not exist "%sevenZipPath%" (
        echo 7-Zip no encontrado. Utilizando Powershell...
    ) 
    powershell -command "Expand-Archive -Path '%zipFile%' -DestinationPath '%antlrRuntimePath%'"
    
)

setlocal
:: Ruta al ejecutable vswhere
set "vswherePath=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"

:: Verificar si vswhere.exe existe
if not exist "%vswherePath%" (
    echo vswhere.exe no encontrado
    exit /b 1
)

for /f "tokens=*" %%i in ('"%vswherePath%" -property displayName') do ( set "vsDisplayName=%%i" )
for /f "tokens=3 delims= " %%a in ("%vsDisplayName%") do ( set "vsEdition=%%a" )

call "%antlrRuntimePath%\deploy-windows.cmd" "%vsEdition%"

if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\%vsVersion%\" (
    call "%ProgramFiles(x86)%\Microsoft Visual Studio\%vsVersion%\%vsEdition%\Common7\Tools\VsDevCmd.bat"
) else (
    echo "No se a detectado la terminal de herramientas de Visual Studio. Abortando"
    exit /b 1
)

pushd runtime
msbuild "%antlrRuntimePath%\runtime\antlr4cpp-vs%vsVersion%.vcxproj" /p:configuration="Debug DLL" /p:platform=Win32
msbuild "%antlrRuntimePath%\runtime\antlr4cpp-vs%vsVersion%.vcxproj" /p:configuration="Debug DLL" /p:platform=x64
popd
endlocal

:: Establecer variable de entorno con la ruta del DLL
setx ANTLRRUNTIMEDLL "%antlrRuntimePath%\runtime\bin\vs-%vsVersion%\x64\Debug DLL\antlr4-runtime.dll"
set "ANTLRRUNTIMEDLL=%antlrRuntimePath%\runtime\bin\vs-%vsVersion%\x64\Debug DLL\antlr4-runtime.dll"

:: Establecer variable de entorno con la ruta del LIB
setx ANTLRRUNTIMELIB "%antlrRuntimePath%\runtime\bin\vs-%vsVersion%\x64\Debug DLL"
set "ANTLRRUNTIMELIB=%antlrRuntimePath%\runtime\bin\vs-%vsVersion%\x64\Debug DLL"

:: Establecer variable de entorno con la ruta de los .h del runtime
setx ANTLRRUNTIMEH "%antlrRuntimePath%\runtime\src"

:: Establecer classpath
setx CLASSPATH "%javaPath%\lib;.;%antlrPath%\antlr-4.13.2-complete.jar"

:: Crear alias para antlr4 y grun en la sesión actual
set "antlr4=java -cp %antlrPath%\antlr-4.13.2-complete.jar org.antlr.v4.Tool"
set "grun=java -cp %antlrPath%\antlr-4.13.2-complete.jar org.antlr.v4.gui.TestRig"

:: Establecer variables de entorno globales
setx antlr4 "java -cp %antlrPath%\antlr-4.13.2-complete.jar org.antlr.v4.Tool"
setx grun "java -cp %antlrPath%\antlr-4.13.2-complete.jar org.antlr.v4.gui.TestRig"

:: Actualizar PATH
set "PATH=%PATH%;%antlrPath%"
setx PATH "%PATH%"

echo Antlr y Antlr Runtime CPP han sido configurados