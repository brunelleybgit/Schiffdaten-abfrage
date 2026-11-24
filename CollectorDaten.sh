#!/bin/bash
mkdir -p Log
 ncat --recv-only rhodes 8082 | while read -r line; do
  echo "$line" >> ./Log/aktueldaten.log 
done &

echo "$!" > Log/pid.log
#holt Daten von Server rhodes und speichert in dem Pfad 
