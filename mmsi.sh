#!/bin/bash
echo "Content-Type: text/plain"
echo

tail -n 10000000 "./Log/aktueldaten.log" | cut -d'|' -f3 | sort | uniq > mmsi.csv
