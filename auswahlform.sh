#!/bin/bash

echo "Content-Type: text/html"
echo

pfad_basis="/usr/lib/cgi-bin/"
datei_mmsi="$pfad_basis/mmsi.csv"
heute=$(date +%Y-%m-%d)

echo "<html><head><meta charset='utf-8'><title>Auswahl</title>"
echo "<style>
  body { font-family: sans-serif; padding: 40px; background: #f4f4f4; }
  .container { max-width: 500px; margin: auto; background: white; padding: 30px; border-radius: 8px; }
  label { display: block; margin-top: 15px; font-weight: bold; }
  input, select { width: 100%; padding: 10px; margin-top: 5px; }
  button { width: 100%; padding: 10px; background-color: #007bff; color: white; border: none; margin-top: 20px; cursor: pointer; }
</style>"
echo "</head><body>"

echo "<div class='container'>"
echo "<h1>Datenabfrage Schiffe</h1>"

echo "<form action='ergebnis.sh' method='get'>"

    echo "<label>Datum:</label>"
    echo "<input type='date' name='datum' value='$heute' required>"

    echo "<label>Schiff (MMSI):</label>"
    echo "<select name='mmsi' required>"
    echo "<option value=''>-- Bitte wählen --</option>"

    # CSV einlesen
    if test -f "$datei_mmsi"; then
        while read -r zeile; do
            clean_mmsi=$(echo "$zeile" | tr -d ' \r\n')
            if test -n "$clean_mmsi"; then
                echo "<option value='$clean_mmsi'>$clean_mmsi</option>"
            fi
        done < "$datei_mmsi"
    else
        echo "<option>Fehler: mmsi.csv fehlt</option>"
    fi
    echo "</select>"

    echo "<button type='submit'>Suchen starten</button>"

echo "</form>"
echo "<p style='text-align:center;'><a href='../../indexbrymele.html'>Abbrechen</a></p>"
echo "</div>"

echo "</body></html>"
