#!/bin/bash
# Auto-rotation for PineTab2 on Hyprland

# Log file for debugging
LOGFILE="/tmp/autorotate.log"

# Use monitor-sensor to listen for orientation changes
monitor-sensor --accel | while read -r line; do
  echo "[$(date)] $line" >>"$LOGFILE"

  if [[ "$line" == *"normal"* ]]; then
    hyprctl keyword monitor "DSI-1,transform,0"
    hyprctl keyword "input:touchdevice:transform 0"
    hyprctl keyword "input:touchdevice:output DSI-1"
    echo "[$(date)] Applied transform 0 (protrait)" >>"$LOGFILE"
  elif [[ "$line" == *"right-up"* ]]; then
    hyprctl keyword monitor "DSI-1,transform,3"
    hyprctl keyword "input:touchdevice:transform 3"
    hyprctl keyword "input:touchdevice:output DSI-1"
    echo "[$(date)] Applied transform 3 (landscape)" >>"$LOGFILE"
  elif [[ "$line" == *"bottom-up"* ]]; then
    hyprctl keyword monitor "DSI-1,transform,2"
    hyprctl keyword "input:touchdevice:transform 2"
    hyprctl keyword "input:touchdevice:output DSI-1"
    echo "[$(date)] Applied transform 2 (portrait inverted)" >>"$LOGFILE"
  elif [[ "$line" == *"left-up"* ]]; then
    hyprctl keyword monitor "DSI-1,transform,1"
    hyprctl keyword "input:touchdevice:transform 1"
    hyprctl keyword "input:touchdevice:output DSI-1"
    echo "[$(date)] Applied transform 1 (landscape inverted)" >>"$LOGFILE"
  fi
done
