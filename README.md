# Configurar Antlr4 en Windows y Linux basados en Ubuntu
En este repo se provee unos archivos de configuración para poder configurar el entorno de antlr4 automaticamente y poder compilar proyectos de c++ con cmake 

## Pasos
### Para Windows
1. Descargar o clonar la carpeta win
2. Ejecutar como administrador el archivo `config.bat`  
Este archivo descarga la versión 21 de Java si no encuentra una instalación de java 21 o 18 pre existente. Así mismo descarga el runtime de antlr4 para cpp y lo compila para windows usando el compilador de visual studio. Tambien se establecen variables de entorno para hacer más sencillo la compilación con cmake, visual studio o por otro medio.
3. Dentro del `CMakeLists.txt` lo único que se debe adaptar es la ruta a los archivos fuente y compilados generados por antlr4 para su gramatica.  
Para el `CMakeLists` se espera tener una estructura de carpetas tal que así:
    ```
    |- src/
    |  |--lib/
    |  |    // Archivos de gramatica generados por antlr
    |  |-- visitor/
    |       // Archivos de su propia implementacion de visitor
    |- main.cpp // Archivo principal de entrada del programa
    |- run.bat
    |- CMakeLists.txt
    ```

### Para Linux
En Linuz la vida es más sencilla por que no hay windows con que complicarse, pero igual te la simplifico más.
1. Descargar o clonar la carpeta `linux`
2. Ejecutar con sudo `config.sh`  
La descarga y verificación de archivos comenzará se descargará las cosas que no se tengan y se establecerán las mismas variables de entorno para poder trabajar con cmake en c++
4. Si usas linux se supone que ya sabrás compilar con cmake, sino, es buen momento para aprender
# antlr4-config
