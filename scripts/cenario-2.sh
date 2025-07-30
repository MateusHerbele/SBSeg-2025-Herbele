#!/bin/bash

# Mapeamento dos padrões para nomes de ataques
declare -A attack_names=(
    ["1000002"]="Slow Loris"
    ["1000003"]="Slow HTTP"
    ["1000004"]="GoldenEye"
    ["1000005"]="HULK"
)

# Variáveis para acumular totais
total_files=0
sum_time=0
sum_alerts=0
sum_pkts=0
sum_mbits=0
declare -A sum_attacks=()
for pattern in "${!attack_names[@]}"; do
    sum_attacks[$pattern]=0
done
sum_dummy=0

# Processar cada arquivo
for ((x=0; x<=9; x++)); do
    file="../logs/microsec/microsec-$x.txt"
    echo -e "\n=== Arquivo: $file ==="

    # Métricas básicas
    time=$(grep -oP "seconds: \K\d+\.\d+" "$file" 2>/dev/null || echo "0")
    alerts_total=$(grep -oP "alert: \K\d+" "$file" 2>/dev/null || echo "0")
    pkts_sec=$(grep -oP "pkts/sec: \K\d+" "$file" 2>/dev/null || echo "0")
    mbits_sec=$(grep -oP "Mbits/sec: \K\d+" "$file" 2>/dev/null || echo "0")

    echo "Tempo de execução: $time segundos"
    echo "Total de alertas: $alerts_total"
    echo "Taxa de pacotes: $pkts_sec pkts/sec"
    echo "Largura de banda: $mbits_sec Mbits/sec"

    # Contagem de ataques e cálculo de Dummy
    echo -e "\n[Detecao de Ataques]"
    file_sum_attacks=0
    for pattern in "${!attack_names[@]}"; do
        count=$(grep -o "\[1:${pattern}:0\]" "$file" 2>/dev/null | wc -l)
        file_sum_attacks=$((file_sum_attacks + count))
        sum_attacks[$pattern]=$((sum_attacks[$pattern] + count))
        echo "${attack_names[$pattern]} ($pattern): $count"
    done

    # Cálculo de alertas Dummy
    dummy=$((alerts_total - file_sum_attacks))
    sum_dummy=$((sum_dummy + dummy))
    echo -e "\nAlertas Dummy: $dummy"

    # Acumular totais
    total_files=$((total_files + 1))
    sum_time=$(echo "$sum_time + $time" | bc)
    sum_alerts=$((sum_alerts + alerts_total))
    sum_pkts=$((sum_pkts + pkts_sec))
    sum_mbits=$((sum_mbits + mbits_sec))
done

# Calcular médias
if [ $total_files -gt 0 ]; then
    avg_time=$(echo "scale=2; $sum_time / $total_files" | bc)
    avg_alerts=$(echo "scale=2; $sum_alerts / $total_files" | bc)
    avg_pkts=$(echo "scale=2; $sum_pkts / $total_files" | bc)
    avg_mbits=$(echo "scale=2; $sum_mbits / $total_files" | bc)

    echo -e "\n=== RESUMO GERAL ==="
    echo "Total de arquivos processados: $total_files"
    echo -e "\n[MÉDIAS]"
    echo "Tempo médio de execução: $avg_time segundos"
    echo "Média de alertas totais: $avg_alerts"
    echo "Taxa média de pacotes: $avg_pkts pkts/sec"
    echo "Largura de banda média: $avg_mbits Mbits/sec"

    echo -e "\n[MÉDIAS DE ATAQUES]"
    for pattern in "${!attack_names[@]}"; do
        avg=$(echo "scale=2; ${sum_attacks[$pattern]} / $total_files" | bc)
        echo "${attack_names[$pattern]} ($pattern): $avg"
    done

    avg_dummy=$(echo "scale=2; $sum_dummy / $total_files" | bc)
    echo -e "\nMédia de alertas Dummy: $avg_dummy"
else
    echo "Nenhum arquivo foi processado."
fi