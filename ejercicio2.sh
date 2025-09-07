#!/bin/bash

programa=$@
logs="monitor.log"
PID=""

# Ejecutar el programa en segundo plano
echo "Ejecutando: $programa"
$programa &
PID=$!
echo "Proceso PID: $PID"
echo "Tiempo,CPU%,Mem%" > "$logs"

while kill -0 "$PID" 2>/dev/null; do
    stats=$(ps -p "$PID" -o %cpu,%mem --no-headers 2>/dev/null)
    if [ $? -eq 0 ] && [ ! -z "$stats" ]; then
        tiempo=$(date '+%H:%M:%S')
        echo "$tiempo,$stats" >> "$logs"
        echo "Registrado: $tiempo - $stats"
    else
        break
    fi
    sleep 1
done

# Verificar si hay datos en el log
lineas_log=$(wc -l < "$logs")
if [ "$lineas_log" -le 1 ]; then
    echo "Error: No hay datos suficientes en $logs"
    echo "Contenido del archivo:"
    cat "$logs"
    exit 1
fi

echo "Fin del proceso, graficando consumo..."

#gnuplot
cat > grafico.gp << 'EOF'
set terminal png size 800,600
set output 'grafico.png'
set title 'Consumo de CPU y Memoria'
set xlabel 'Tiempo'
set ylabel 'Porcentaje'
set grid
set key outside
set style data lines
set datafile separator comma
plot "monitor.log" using 2:xtic(1) with lines title 'CPU%', \
     "monitor.log" using 3 with lines title 'Mem%'
EOF

gnuplot grafico.gp
if command -v gnuplot >/dev/null 2>&1; then
    if gnuplot grafico.gp; then
        echo "Gráfico creado: grafico.png"
    else
        echo "Error al generar el gráfico"
fi

rm -f grafico.gp

# Mostrar los datos capturados
echo "Datos registrados en $logs:"
cat "$logs"
