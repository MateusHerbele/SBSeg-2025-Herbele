#!/bin/bash

echo "[1/3] Configurando ambiente Python..."
python3 -m venv /usr/src/venv
source /usr/src/venv/bin/activate
pip install -r /usr/src/scripts/requirements.txt

echo "[2/3] Executando microsec.py..."
cd /usr/src/scripts
python microsec.py

echo "[3/3] Finalizado!"
