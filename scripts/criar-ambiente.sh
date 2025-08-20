echo "1/2] Configurando ambiente Python..."
if [ ! -d "/usr/src/venv" ]; then
    python3 -m venv /usr/src/venv
fi
source /usr/src/venv/bin/activate
pip install -r /usr/src/scripts/requirements.txt
echo "[2/2] Ambiente configurado com sucesso!"