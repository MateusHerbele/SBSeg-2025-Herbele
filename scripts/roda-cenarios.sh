#!/bin/bash
set -euo pipefail

# Diretórios base
RULES_DIR="/usr/src/rules"
DATASETS_DIR="/usr/src/datasets"
LOGS_DIR="/usr/src/logs"

# Criar pastas de logs
mkdir -p "$LOGS_DIR/original" "$LOGS_DIR/microsec"
mkdir -p "$LOGS_DIR/original/chunks" "$LOGS_DIR/microsec/chunks"

echo "=== Iniciando execuções dos cenários ==="

# Cenário 1: Original - pcap completo
for exec_num in {0..9}; do
    echo "Cenário 1 - Execução $exec_num"
    snort --daq pcap \
        -R "$RULES_DIR/original.rules" \
        -r "$DATASETS_DIR/original/Wednesday-workingHours.pcap" \
        -A cmg > "$LOGS_DIR/original/original-${exec_num}.txt"
done

# Cenário 2: MicroSec - pcap completo
for exec_num in {0..9}; do
    echo "Cenário 2 - Execução $exec_num"
    snort --daq pcap \
        -R "$RULES_DIR/microsec.rules" \
        -r "$DATASETS_DIR/microsec/microsec.pcap" \
        -A cmg > "$LOGS_DIR/microsec/microsec-${exec_num}.txt"
done

# Cenário 3: Original - chunks
chunk_files=("$DATASETS_DIR/original/chunks/"*.pcap)
for exec_num in {0..9}; do
    echo "Cenário 3 - Execução $exec_num"
    mkdir -p "$LOGS_DIR/original/chunks/$exec_num"
    for chunk_path in "${chunk_files[@]}"; do
        chunk_name=$(basename "$chunk_path" .pcap)
        snort --daq pcap \
            -R "$RULES_DIR/original-pcap.rules" \
            -r "$chunk_path" \
            -A cmg > "$LOGS_DIR/original/chunks/$exec_num/${chunk_name}.txt"
    done
done

# Cenário 4: MicroSec - chunks
chunk_files=("$DATASETS_DIR/microsec/chunks/"*.pcap)
for exec_num in {0..9}; do
    echo "Cenário 4 - Execução $exec_num"
    mkdir -p "$LOGS_DIR/microsec/chunks/$exec_num"
    for chunk_path in "${chunk_files[@]}"; do
        chunk_name=$(basename "$chunk_path" .pcap)
        snort --daq pcap \
            -R "$RULES_DIR/microsec-pcap.rules" \
            -r "$chunk_path" \
            -A cmg > "$LOGS_DIR/microsec/chunks/$exec_num/${chunk_name}.txt"
    done
done

echo "=== Execuções finalizadas ==="

echo "=== Iniciando análise dos cenários ==="

echo -e "\n--- Análise do Cenário 1: Original - pcap completo ---"
bash ./cenario-1.sh

echo -e "\n--- Análise do Cenário 2: MicroSec - pcap completo ---"
bash ./cenario-2.sh

echo -e "\n--- Análise do Cenário 3: Original - chunks ---"
bash ./cenario-3.sh

echo -e "\n--- Análise do Cenário 4: MicroSec - chunks ---"
bash ./cenario-4.sh
