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
