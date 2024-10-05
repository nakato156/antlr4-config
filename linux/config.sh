#!/bin/bash

ROJO="\e[31m"
VERDE="\e[32m"
AMARILLO="\e[33m"
RESET="\e[0m"

X="✘"
CHECK="✔"

function ejecutar_comando() {
    local comando=$1
    local SALIDA_TEMP=$(mktemp)
    local ERROR_TEMP=$(mktemp)
    
    $1 > "$SALIDA_TEMP" 2> "$ERROR_TEMP"
            
    if [ $? -ne 0 ]; then
        echo -e "${ROJO}${X} Se produjo un error al ejecutar '${comando}':\n"
        cat "$ERROR_TEMP"
        echo -e "$RESET"
    fi
    rm -f "$SALIDA_TEMP" "$ERROR_TEMP"
}

function descargar_e_instalar_manual(){
    local nombre=$1
    local url=$2
    local archivo=$(basename "$url")

    echo -e "${AMARILLO}[*] Descargando $nombre...${RESET}"
    curl -L -o "/tmp/$archivo" "$url"

    if [ $? -ne 0 ]; then
        echo -e "${ROJO}${X} Error al descargar $nombre.${RESET}"
        return 1
    fi

    echo -e "${AMARILLO}[*] Instalando $nombre...${RESET}"
    chmod +x "/tmp/$archivo"
    sudo /tmp/"$archivo"
    
    if [ $? -ne 0 ]; then
        echo -e "${ROJO}${X} Error al instalar $nombre.${RESET}"
        return 1
    fi
}

function comprobar_dependencias(){
    echo -e "${AMARILLO}[*] Comprobando dependencias...${RESET}"
    paquetes_requeridos=("curl" "unzip" "git" "g++" "cmake" "make" "antlr4")
    descargar=("cmake")
    no_instalados=()

    for paquete in "${paquetes_requeridos[@]}"; do
        if command -v "$paquete" &> /dev/null; then
            echo -e "$paquete\t$VERDE${CHECK}${RESET}"
        else
            echo -e "$paquete\t$RED${X}${RESET}"
            no_instalados+=("$paquete")
        fi
    done

    # Informar sobre paquetes no instalados
    if [ ${#no_instalados[@]} -ne 0 ]; then
        echo -e "Los siguientes paquetes no están instalados:"
        for paquete in "${no_instalados[@]}"; do
            echo " - $paquete"
        done

        read -p "Desea instalarlos [S/n]?" op
        if [ "$op" == "S" ]; then
            SALIDA_TEMP=$(mktemp)
            ERROR_TEMP=$(mktemp)

            echo "$AMARILLO[*] Instalando paquetes...$RESET"
            ejecutar_comando "sudo apt-get update"

            for paquete in "${no_instalados[@]}"; do
                echo -e "$AMARILLO[*] Instalando $paquete...$RESET"

                case $paquete in 
                    "cmake")
                        url="https://github.com/Kitware/CMake/releases/download/v3.30.3/cmake-3.30.3-linux-x86_64.sh"
                        descargar_e_instalar_manual "cmake" "$url"
                    ;;
                    *)
                        ejecutar_comando "sudo apt-get install $paquete"
                    ;;
                esac
            done
            
        fi
    fi
}

function donwload_antlrRuntime(){
    antlrPath=$1
    mkdir -p /tmp/antlr4-temp

    curl -o /tmp/antlr4-temp/antlr4-cpp-runtime-4.13.2-source.zip https://www.antlr.org/download/antlr4-cpp-runtime-4.13.2-source.zip
    sudo unzip /tmp/antlr4-temp/antlr4-cpp-runtime-4.13.2-source.zip -d $antlrPath
    
    rm -r /tmp/antlr4-temp
}

function instalar_antlrRuntime(){
    antlrPath="/usr/local/antlr4-runtime"

    if [ -d "/usr/local/antlr4-runtime" ]; then
        echo "El directorio /usr/local/antlr4-runtime ya existe."
        read -p "Desea eliminar su contenido [B], Omitir descarga y usar la existente [C] o establecer una ruta [S]?" op
        
        if [ "$op" == "B" ]; then
            echo -e "${AMARILLO}[*] Eliminando contenido de /usr/local/antlr4-runtime ${RESET}"
            sudo rm -rf /usr/local/antlr4-runtime
            sudo mkdir -p /usr/local/antlr4-runtime

            antlrPath="/usr/local/antlr4-runtime"
            donwload_antlrRuntime $antlrPath

        elif [ "$op" == "C" ]; then
            echo "Usando la ruta existente"
            antlrPath="/usr/local/antlr4-runtime"
        elif [ "$op" == "S" ]; then
            read -p "Ingrese la ruta donde se instalara el runtime: " antlrPath
            donwload_antlrRuntime $antlrPath
        fi
    else
        sudo mkdir -p /usr/local/antlr4-runtime
        echo -e "${AMARILLO}[*] Descargando antlr4-cpp-runtime en ${antlrPath} ${RESET}"
        donwload_antlrRuntime $antlrPath
    fi

    cd $antlrPath
    mkdir build && cd build
    cmake .. && make

    export ANTLRRUNTIMEH="$antlrPath/runtime/src"
    export ANTLRRUNTIME="$antlrPath/build/runtime"
    

    echo "export ANTLRRUNTIMEH=\"$antlrPath/runtime/src\"" >> ~/.bashrc
    echo "export ANTLRRUNTIME=\"$antlrPath/build/runtime\"" >> ~/.bashrc

    source ~/.bashrc
}

comprobar_dependencias
instalar_antlrRuntime