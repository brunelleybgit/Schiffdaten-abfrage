#!/bin/bash

#BASE="/usr/lib/cgi-bin/"
LOG_DATA="Log/aktueldaten.log"
LOG_FILE="Log/logg.log"
PID_FILE="Log/pid.log"
SCRIPT="CollectorDaten.sh"

NOW=$(date "+%d.%m.%Y %H:%M:%S")

if test -f "$LOG_DATA";then

    ts_now=$(date +%s)
    ts_file=$(date -r "$LOG_DATA" +%s)
    alter=$((ts_now - ts_file))
    
    if test "$alter" -gt 180;then
        
        echo "$NOW: Neu starten" >> "$LOG_FILE"
        
        if test -f "$PID_FILE";then
            
            read alte_pid < "$PID_FILE"
            
            echo "$NOW: Beende Prozess mit PID $alte_pid" >> "$LOG_FILE"
    
                kill "$alte_pid" 2>/dev/null
        fi
       
        sleep 1
        
        echo "$NOW: Starte CollectorDaten neu..." >> "$LOG_FILE"
        
        nohup bash "$SCRIPT" >> /dev/null 2>&1 &
        
    else
       
        echo "$NOW: Alles OK." >> "$LOG_FILE"
    fi

else
    echo "$NOW: Datei $LOG_DATA nicht gefunden!" >> "$LOG_FILE"
fi
