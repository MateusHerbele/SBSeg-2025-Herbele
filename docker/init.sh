#!/bin/bash

echo "[1/4] Baixando dataset original..."
mkdir -p /usr/src/datasets/original /usr/src/datasets/microsec

# Original
wget -O /usr/src/datasets/original/Wednesday-workingHours.pcap \
    http://cicresearch.ca/CICDataset/CIC-IDS-2017/Dataset/CIC-IDS-2017/PCAPs/Wednesday-workingHours.pcap

echo "[2/4] Baixando dataset processado (Microsec)..."
# Dataset processado
wget -O /usr/src/datasets/microsec/microsec.tar.gz \
    https://www.inf.ufpr.br/msh22/dados/microsec.tar.gz

tar -xzvf /usr/src/datasets/microsec/microsec.tar.gz /usr/src/datasets/microsec/microsec.pcap
rm /usr/src/datasets/microsec/microsec.tar.gz

echo "[3/4] Criando chunks..."
# Original
editcap -c 1000000 /usr/src/datasets/original/Wednesday-workingHours.pcap /usr/src/datasets/original/chunks/original-.pcap
n=0; for f in /usr/src/datasets/original/chunks/original-*.pcap; do mv "$f" "/usr/src/datasets/original/chunks/original-${n}.pcap"; ((n++)); done

# Processado
editcap -c 1000000 /usr/src/datasets/microsec/microsec.pcap /usr/src/datasets/microsec/chunks/microsec-.pcap
n=0; for f in /usr/src/datasets/microsec/chunks/microsec-*.pcap; do mv "$f" "/usr/src/datasets/microsec/chunks/microsec-${n}.pcap"; ((n++)); done

echo "[4/4] Datasets e chunks prontos para uso!"
