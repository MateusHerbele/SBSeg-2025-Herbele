#!/bin/bash

echo "[1/3] Configurando ambiente Python..."
if [ ! -d "/usr/src/venv" ]; then
    python3 -m venv /usr/src/venv
fi
source /usr/src/venv/bin/activate
pip install -r /usr/src/scripts/requirements.txt

echo "[2/3] Executando microsec.py..."
cd /usr/src/scripts
python microsec.py /usr/src/datasets/original/Wednesday-workingHours.pcap /usr/src/datasets/microsec/microsec.pcap

echo "[3/3] Finalizado!"