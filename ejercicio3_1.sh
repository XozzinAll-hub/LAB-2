#!/bin/bash

mkdir -p ~/monitor_dir
log="/home/$USER/directory_monitor.log"

touch "$log"
chmod 755 "$log"

log_eventos() {
    local tiempo=$(date)
    local evento="$1"
    local archivo="$2"
    echo "[$tiempo] $evento: $archivo" >> "$log"
}

echo "monitoreo del directorio: /home/$USER/monitor_dir" | tee -a "$log"

inotifywait -m -r -e create,modify,delete --format '%w%f %e' "/home/$USER/monitor_dir" | while read file evento
do
    case "$evento" in
        "CREATE")
            log_eventos "Un Archivo fue creado" "$file"
            ;;
        "MODIFY")
            log_eventos "Se Modifico un archivo" "$file"
            ;;
        "DELETE")
            log_eventos "Se Elimino un archivo" "$file"
            ;;
        *)
            log_eventos "evento inesperado" "$file ($evento)"
            ;;
    esac
done
