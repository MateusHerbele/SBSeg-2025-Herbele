#!/bin/bash
set -e

echo "[1/5] Baixando dataset original..."
mkdir -p /usr/src/datasets/original /usr/src/datasets/microsec

# Original
wget -O /usr/src/datasets/original/Wednesday-workingHours.pcap \
    http://cicresearch.ca/CICDataset/CIC-IDS-2017/Dataset/CIC-IDS-2017/PCAPs/Wednesday-workingHours.pcap


echo "[2/5] Configurando ambiente Python..."
python3 -m venv /usr/src/venv
source /usr/src/venv/bin/activate
pip install -r /usr/src/scripts/requirements.txt

echo "[3/5] Executando microsec.py..."
cd /usr/src/scripts
python microsec.py

echo "[4/5] Criando chunks..."
# Original
editcap -c 1000000 /usr/src/datasets/original/Wednesday-workingHours.pcap /usr/src/datasets/original/chunks/original-%d.pcap
n=0; for f in /usr/src/datasets/original/chunks/original-%d_*.pcap; do mv "$f" "/usr/src/datasets/original/chunks/original-${n}.pcap"; ((n++)); done

# Processado
editcap -c 1000000 /usr/src/datasets/microsec/microsec.pcap /usr/src/datasets/microsec/chunks/microsec-%d.pcap
n=0; for f in /usr/src/datasets/microsec/chunks/microsec-%d_*.pcap; do mv "$f" "/usr/src/datasets/microsec/chunks/microsec-${n}.pcap"; ((n++)); done

echo "[5/5] Ambiente pronto."
exec /bin/bash

echo "[INIT] Executando Snort com regras do MicroSec (teste mínimo)..."

snort --daq pcap \
      -R /usr/src/rules/microsec-pcap.rules \
      -r /teste-minimo/teste-microsec.pcap \
      -A cmg 

echo "[INIT] Teste mínimo do MicroSec concluído."