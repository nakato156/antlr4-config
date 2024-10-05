cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME MyProj)

project(${PROJECT_NAME})

# Especifica la versión de C++
set(CMAKE_CXX_STANDARD 17)

# Añade el directorio lib a los directorios de inclusión
include_directories(./src)

# Incluye los encabezados del runtime de ANTLR
include_directories($ENV{ANTLRRUNTIMEH})
link_directories($ENV{ANTLRRUNTIME})

# Busca todos los archivos .cpp en src/lib
file(GLOB LIB_SOURCES "./src/lib/*.cpp")
file(GLOB MIO_SOURCES "./src/*.cpp")

# Añade la ruta de los archivos fuente
set(SOURCE_FILES ${MIO_SOURCES} ${LIB_SOURCES})

# Crea el ejecutable
add_executable(${PROJECT_NAME} ${SOURCE_FILES})

# Añade los directorios de búsqueda de las bibliotecas para el proyecto
target_link_directories(${PROJECT_NAME} PUBLIC)

# Enlaza el runtime de ANTLR y LLVM con tu proyecto
target_link_libraries(${PROJECT_NAME} antlr4-runtime)