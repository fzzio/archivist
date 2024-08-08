#!/bin/bash

# Verifica si se ha proporcionado un directorio
if [ -z "$1" ]; then
    echo "Por favor, proporciona un directorio."
    exit 1
fi

DIRECTORY=$1
OUTPUT_FILE="files.txt"

# Vacía el archivo de salida si ya existe
> $OUTPUT_FILE

# Función para procesar archivos
process_file() {
    local FILE=$1

    # Usar el comando 'file' para verificar si el archivo es binario
    if file "$FILE" | grep -qE 'text|script'; then
        echo "$FILE" >> $OUTPUT_FILE
        echo '```' >> $OUTPUT_FILE
        cat "$FILE" >> $OUTPUT_FILE
        echo -e '\n```\n' >> $OUTPUT_FILE
    fi
}

# Comprueba si existe un archivo .gitignore en el directorio y construye un patrón de exclusión
GITIGNORE="$DIRECTORY/.gitignore"
EXCLUDE_PATTERNS=" ! -path \"$DIRECTORY/assets/*\" ! -path \"$DIRECTORY/node_modules/*\" ! -path \"$DIRECTORY/dist/*\" ! -path \"$DIRECTORY/.vercel/*\" ! -path \"$DIRECTORY/.git/*\" ! -path \"$DIRECTORY/.expo/*\" ! -path \"$DIRECTORY/package-lock.json\" ! -path \"$DIRECTORY/.gitignore\""
if [ -f "$GITIGNORE" ]; then
    # Convertir patrones de .gitignore para que sean interpretados por find
    grep -v '^#' "$GITIGNORE" | grep -v '^$' | while read -r line; do
        # Formatea y agrega el patrón de exclusión para find
        PATTERN="$DIRECTORY/$line"
        PATTERN="${PATTERN//\*/\*}"  # Manejar asteriscos en los patrones
        EXCLUDE_PATTERNS+=" ! -path \"$PATTERN\""
    done
fi

# Recorre todos los archivos en el directorio dado, excluyendo los que coincidan con .gitignore
eval "find \"$DIRECTORY\" -type f $EXCLUDE_PATTERNS" | while read -r FILE; do
    process_file "$FILE"
done

# Procesa archivos adicionales si se proporciona el flag --additional
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --additional)
            shift
            while [[ "$#" -gt 0 && "$1" != --* ]]; do
                ADDITIONAL_FILE=$1
                if [ -f "$ADDITIONAL_FILE" ]; then
                    process_file "$ADDITIONAL_FILE"
                else
                    echo "El archivo adicional $ADDITIONAL_FILE no existe."
                fi
                shift
            done
            ;;
        *)
            shift
            ;;
    esac
done

echo "El contenido ha sido concatenado en $OUTPUT_FILE"
