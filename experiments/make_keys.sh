#!/bin/bash
NUM_KEYS=50

NODE_IP="34.174.141.169"
NODE_PORT=8000
CSV_FILE="busquedas.csv"
CLIENT="./client/chord"

echo "insertando $NUM_KEYS claves en Chord..."

for i in $(seq 1 $NUM_KEYS); do
    KEY="key$i"
    VALUE="value$i"
    $CLIENT put "$KEY" "$VALUE"
done

echo "inserción completada."