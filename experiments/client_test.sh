#!/bin/bash
NUM_KEYS=50
NUM_TESTS=10
NODES=opt
CSV_DIR="./experiments/csv"
CSV_FILE="$CSV_DIR/busquedas_${NODES}_nodes.csv"
CLIENT="./client/chord"

echo "probando $NUM_TESTS búsquedas aleatorias..."

echo "key,tiempo_ms" > $CSV_FILE

for i in $(seq 1 $NUM_KEYS | shuf | head -n $NUM_TESTS); do
    KEY="key$i"
    START=$(date +%s%N)
    $CLIENT locate "$KEY"
    END=$(date +%s%N)
    ELAPSED=$(( (END-START)/1000000 ))
    echo "$KEY,$ELAPSED" >> $CSV_FILE
    echo "Búsqueda de $KEY: $ELAPSED ms"
done

echo "Tiempos guardados en $CSV_FILE"