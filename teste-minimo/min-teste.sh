echo "[INIT] Executando Teste Mínimo do MicroSec..."

echo "Ativando Snort com regras do MicroSec ..."
echo "Utilizando pcap do teste mínimo..."

snort --daq pcap \
      -R /usr/src/rules/microsec-pcap.rules \
      -r /teste-minimo/microsec/teste-microsec.pcap \
      -A cmg 

echo "[INIT] Teste mínimo do MicroSec concluído."