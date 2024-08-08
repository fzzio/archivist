#!/bin/bash

# Función para mostrar el menú de ayuda
show_help() {
    echo "Uso: $0 [directorio] [opciones]"
    echo
    echo "Descripción:"
    echo "  Este script procesa archivos de texto en un directorio, concatenándolos en un único archivo"
    echo "  o copiándolos al portapapeles. Respeta los archivos de ignorar (como .gitignore) y ofrece"
    echo "  opciones para personalizar el comportamiento."
    echo
    echo "Opciones:"
    echo "  -h, --help          Muestra este mensaje de ayuda"
    echo "  --clipboard         Copia el resultado al portapapeles en lugar de crear un archivo"
    echo "  --ignore <rutas>    Rutas adicionales a ignorar (separadas por espacios)"
    echo "  --force <rutas>     Rutas a incluir forzosamente (separadas por espacios)"
    echo "  --output <archivo>  Especifica un archivo de salida personalizado (por defecto: files.txt)"
    echo
    echo "Ejemplos:"
    echo "  $0 /ruta/del/proyecto"
    echo "  $0 . --clipboard --ignore node_modules --force src/important.js"
    echo "  $0 /ruta/del/proyecto --output resultado.md"
}

# Configuración inicial
DIRECTORY="."
OUTPUT_FILE="files.txt"
USE_CLIPBOARD=false
ADDITIONAL_IGNORES=()
FORCE_INCLUDE=()

# Procesar argumentos
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) show_help; exit 0 ;;
        --clipboard) USE_CLIPBOARD=true; shift ;;
        --ignore) shift; ADDITIONAL_IGNORES+=("$1"); shift ;;
        --force) shift; FORCE_INCLUDE+=("$1"); shift ;;
        --output) shift; OUTPUT_FILE="$1"; shift ;;
        -*) echo "Opción desconocida: $1" >&2; show_help; exit 1 ;;
        *) DIRECTORY="$1"; shift ;;
    esac
done

# Función para comprobar si un archivo debe ser ignorado
should_ignore() {
    local file="$1"
    local relative_path="${file#$DIRECTORY/}"

    # Comprobar si el archivo está en la lista de inclusión forzada
    for force_path in "${FORCE_INCLUDE[@]}"; do
        if [[ "$relative_path" == "$force_path" || "$relative_path" == "$force_path"/* ]]; then
            return 1
        fi
    done

    # Comprobar patrones de exclusión
    if git check-ignore -q "$file" 2>/dev/null; then
        return 0
    fi

    # Comprobar ignores adicionales
    for ignore_path in "${ADDITIONAL_IGNORES[@]}"; do
        if [[ "$relative_path" == "$ignore_path" || "$relative_path" == "$ignore_path"/* ]]; then
            return 0
        fi
    done

    return 1
}

# Función para procesar un archivo
process_file() {
    local file="$1"
    local relative_path="${file#$DIRECTORY/}"

    if should_ignore "$file"; then
        return
    fi

    # Comprobar si es un archivo de texto
    if file -b --mime-type "$file" | grep -qE '^text|^application/json|^application/xml|^application/csv'; then
        echo "$relative_path"
        echo '```'
        cat "$file"
        echo '```'
        echo
    else
        echo "$relative_path (archivo binario)"
        echo
    fi
}

# Procesar archivos
output=$(find "$DIRECTORY" -type f | while read -r file; do
    process_file "$file"
done)

# Manejar la salida
if [ "$USE_CLIPBOARD" = true ]; then
    echo "$output" | xclip -selection clipboard
    echo "El contenido ha sido copiado al portapapeles."
else
    echo "$output" > "$OUTPUT_FILE"
    echo "El contenido ha sido guardado en $OUTPUT_FILE"
fi