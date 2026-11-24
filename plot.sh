#!/bin/bash

# Argumente aus ergebnis.sh
daten_datei="$1"   
mmsi="$2"          

dir_plot="/var/www/html/docker-bruymele-web/Step"

plot_daten="/tmp/plot_${mmsi}_$$.dat"
plot_befehl="/tmp/plot_${mmsi}_$$.gp"
bild_datei="$dir_plot/zeitreihe_$mmsi.png"

# Daten ausschneiden
cut -d'|' -f1,7 "$daten_datei" > "$plot_daten"

echo "set terminal png size 800,400" > "$plot_befehl"
echo "set output '$bild_datei'" >> "$plot_befehl"
echo "set title 'Geschwindigkeit (MMSI $mmsi)'" >> "$plot_befehl"
echo "set datafile separator '|'" >> "$plot_befehl"
echo "set timefmt '%Y-%m-%d %H:%M:%S'" >> "$plot_befehl"
echo "set xdata time" >> "$plot_befehl"
echo "set format x '%H:%M'" >> "$plot_befehl"
echo "set xlabel 'Uhrzeit'" >> "$plot_befehl"
echo "set ylabel 'Speed (kn)'" >> "$plot_befehl"
echo "set grid" >> "$plot_befehl"
echo "set yrange [0:*]" >> "$plot_befehl"
echo "plot '$plot_daten' using 1:2 with lines title 'Speed' linecolor rgb 'blue'" >> "$plot_befehl"

rm -f "$bild_datei"
gnuplot "$plot_befehl"

rm "$plot_daten" "$plot_befehl"
