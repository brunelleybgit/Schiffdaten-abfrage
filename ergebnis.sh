#!/bin/bash

echo "Content-Type: text/html"
echo

pfad_basis="/usr/lib/cgi-bin/"
datei_log="$pfad_basis/Log/aktueldaten.log"

# Daten holen
mmsi_wahl=$(echo "$QUERY_STRING" | grep -oE "mmsi=[0-9]*" | cut -d'=' -f2)
datum_wahl=$(echo "$QUERY_STRING" | grep -oE "datum=[0-9]*-[0-9]*-[0-9]*" | cut -d'=' -f2)
heute=$(date +%Y-%m-%d)

# Aus 2026-01-24 wird 20260124
datum_zahl=$(echo "$datum_wahl" | tr -d '-')
heute_zahl=$(echo "$heute" | tr -d '-')


echo "<html><head><meta charset='utf-8'><title>Ergebnis</title>"
echo "<style>
  body { font-family: sans-serif; padding: 20px; }
  table { width: 100%; border-collapse: collapse; font-size: 11px; margin-bottom: 20px; }
  th { background-color: #e0f2f2; border: 1px solid #999; padding: 4px; }
  td { border: 1px solid #ccc; padding: 4px; text-align: left; }
  .box-container { display: flex; gap: 20px; }
  .info-box { flex: 1; border: 1px solid #333; padding: 10px; background: #fff; font-size: 13px; }
  .warning { color: red; font-weight: bold; background: #ffe6e6; padding: 10px; border: 1px solid red; }
  .nav-bar { background: #eee; padding: 10px; margin-bottom: 20px; border-radius: 5px; }
  a.button { text-decoration: none; background: #555; color: white; padding: 5px 10px; border-radius: 3px; }
</style>"
echo "</head><body>"

echo "<div class='nav-bar'>"
echo "<b>Ergebnisse für MMSI: $mmsi_wahl | Datum: $datum_wahl</b> &nbsp;&nbsp;&nbsp;"
echo "<a href='auswahlform.sh' class='button'>&larr; Neue Suche</a>"
echo "</div>"

# Fehler: Keine MMSI
if test -z "$mmsi_wahl"; then
    echo "<h3 class='warning'>Fehler: Keine MMSI übergeben.</h3>"

# Fehler: Kein Datum
elif test -z "$datum_wahl"; then
    echo "<h3 class='warning'>Fehler: Kein Datum übergeben.</h3>"

# Fehler: Datum in Zukunft
elif test "$datum_zahl" -gt "$heute_zahl"; then
    echo "<h3 class='warning'>Das Datum $datum_wahl liegt in der Zukunft. Keine Daten vorhanden.</h3>"

# Wenn alles klappt, Suchen
else
    tmp_datei="/tmp/step_daten_$$.txt"
    grep "|$mmsi_wahl|" "$datei_log" | grep "^$datum_wahl" | awk -F'|' '$2==1 || $2==2 || $2==3' > "$tmp_datei"
    anzahl=$(wc -l < "$tmp_datei")

    if test "$anzahl" -eq 0; then
        echo "<p class='warning'>Keine Einträge gefunden.</p>"
    else
        echo "<p>Gefundene Einträge: $anzahl</p>"

        # Tabelle Header
        echo "<table border='1'><thead><tr>
            <th>Datum/Zeit</th><th>AIS</th><th>MMSI</th><th>NavStatus</th>
            <th>Speed (kn)</th><th>Kurs</th><th>Heading</th><th>Lon</th><th>Lat</th>
            <th>ROT</th><th>Genauigkeit</th><th>MsgID</th>
        </tr></thead><tbody>"

        # Wenn weniger als 11 Zeilen, alles zeigen
        if test "$anzahl" -lt 11; then
            while read -r line; do
                echo "$line" | while IFS="|" read -r datetime aistype mmsi navcode navstatus rot speed acc lon lat course heading sekunde manoever extra raim msgid rest; do
                    echo "<tr>
                        <td>$datetime</td><td>$aistype</td><td>$mmsi</td>
                        <td>$navstatus</td><td>$speed</td><td>$course</td>
                        <td>$heading</td><td>$lon</td><td>$lat</td>
                        <td>$rot</td><td>$acc</td><td>$msgid</td>
                    </tr>"
                done
            done < "$tmp_datei"
        
        # Sonst: Erste 5 und letzte 5
        else
            # Erste 5
            head -n 5 "$tmp_datei" | while read -r line; do
                echo "$line" | while IFS="|" read -r datetime aistype mmsi navcode navstatus rot speed acc lon lat course heading sekunde manoever extra raim msgid rest; do
                     echo "<tr>
                        <td>$datetime</td><td>$aistype</td><td>$mmsi</td>
                        <td>$navstatus</td><td>$speed</td><td>$course</td>
                        <td>$heading</td><td>$lon</td><td>$lat</td>
                        <td>$rot</td><td>$acc</td><td>$msgid</td>
                    </tr>"
                done
            done
            
            # Trenner
            echo "<tr><td colspan='12' style='text-align:center; background:#f9f9f9;'>... (Daten ausgeblendet) ...</td></tr>"
            
            # Letzte 5
            tail -n 5 "$tmp_datei" | while read -r line; do
                echo "$line" | while IFS="|" read -r datetime aistype mmsi navcode navstatus rot speed acc lon lat course heading sekunde manoever extra raim msgid rest; do
                     echo "<tr>
                        <td>$datetime</td><td>$aistype</td><td>$mmsi</td>
                        <td>$navstatus</td><td>$speed</td><td>$course</td>
                        <td>$heading</td><td>$lon</td><td>$lat</td>
                        <td>$rot</td><td>$acc</td><td>$msgid</td>
                    </tr>"
                done
            done
        fi
        echo "</tbody></table>"

        # Info Boxen
        echo "<div class='box-container'>"
            # Erste Meldung
            erste=$(head -n 1 "$tmp_datei")
            echo "$erste" | while IFS="|" read -r datetime aistype mmsi navcode navstatus rot speed acc lon lat course heading sekunde manoever extra raim msgid rest; do
                datum=$(echo "$datetime" | cut -d' ' -f1)
                uhr=$(echo "$datetime" | cut -d' ' -f2)
                echo "<div class='info-box'><b>Erste Meldung</b><br>Speed: $speed kn<br>datum: $datum<br>Zeit: $uhr<br>Lon: $lon<br>Lat: $lat</div>"
            done
            
            # Letzte Meldung
            letzte=$(tail -n 1 "$tmp_datei")
            echo "$letzte" | while IFS="|" read -r datetime aistype mmsi navcode navstatus rot speed acc lon lat course heading sekunde manoever extra raim msgid rest; do
                datum=$(echo "$datetime" | cut -d' ' -f1); uhr=$(echo "$datetime" | cut -d' ' -f2)
                echo "<div class='info-box'><b>Letzte Meldung</b><br>Speed: $speed kn<br>datum: $datum<br>Zeit: $uhr<br>Lon: $lon<br>Lat: $lat</div>"
            done
        echo "</div>"

        # Plot
        bash /usr/lib/cgi-bin/plot.sh "$tmp_datei" "$mmsi_wahl"
        sleep 2

        echo "<div class='plot-box'>"
        echo "<h3>Diagramm</h3>"

        bild_url="../Step/zeitreihe_$mmsi_wahl.png"

        zeitstempel=$(date +%s)
        echo "<img src='$bild_url?t=$zeitstempel' alt='Lade Diagramm...'>"

        echo "</div>"

    fi
    rm "$tmp_datei"
fi

echo "</body></html>"
