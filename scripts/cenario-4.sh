#!/bin/bash

# Mapeamento dos padrões para nomes de ataques
declare -A attack_names=(
    ["1000002"]="Slow Loris"
    ["1000003"]="Slow HTTP"
    ["1000004"]="GoldenEye"
    ["1000005"]="HULK"
)

base_dir="/usr/src/logs/microsec/chunks"
total_executions=10
total_chunks=14

# Arrays para armazenar resultados por CHUNK (acumulados)
declare -a chunk_times
declare -a chunk_alerts
declare -a chunk_pkts
declare -a chunk_mbits
declare -a chunk_dummies
declare -A chunk_attacks  # Array associativo para ataques por chunk

# Inicializar arrays por chunk
for ((chunk=0; chunk<total_chunks; chunk++)); do
    chunk_times[$chunk]=0
    chunk_alerts[$chunk]=0
    chunk_pkts[$chunk]=0
    chunk_mbits[$chunk]=0
    chunk_dummies[$chunk]=0
    
    # Inicializar contadores de ataques por chunk
    for pattern in "${!attack_names[@]}"; do
        key="chunk${chunk}_${pattern}"
        chunk_attacks[$key]=0
    done
done

# Processar cada execução e cada chunk
for exec_num in $(seq 0 $((total_executions - 1))); do
    echo -e "\n=== Processando Execução $exec_num ==="
    
    for chunk_num in $(seq 0 $((total_chunks - 1))); do
        file="${base_dir}/${exec_num}/microsec-${chunk_num}.txt"
        if [ ! -f "$file" ]; then
            echo "  [Chunk $chunk_num] Arquivo não encontrado: $file"
            continue
        fi

        # Extrair métricas do arquivo
        time_val=$(grep -oP "seconds: \K\d+\.\d+" "$file" 2>/dev/null || echo "0")
        alerts_total=$(grep -oP "alert: \K\d+" "$file" 2>/dev/null || echo "0")
        pkts_sec=$(grep -oP "pkts/sec: \K\d+" "$file" 2>/dev/null || echo "0")
        mbits_sec=$(grep -oP "Mbits/sec: \K\d+" "$file" 2>/dev/null || echo "0")

        # Acumular métricas para ESTE CHUNK (para cálculo da média posterior)
        chunk_times[$chunk_num]=$(echo "${chunk_times[$chunk_num]} + $time_val" | bc)
        chunk_alerts[$chunk_num]=$((chunk_alerts[$chunk_num] + alerts_total))
        chunk_pkts[$chunk_num]=$((chunk_pkts[$chunk_num] + pkts_sec))
        chunk_mbits[$chunk_num]=$((chunk_mbits[$chunk_num] + mbits_sec))

        # Contar ataques para ESTE CHUNK
        chunk_sum_attacks=0
        for pattern in "${!attack_names[@]}"; do
            count=$(grep -o "\[1:${pattern}:0\]" "$file" 2>/dev/null | wc -l)
            key="chunk${chunk_num}_${pattern}"
            chunk_attacks[$key]=$((chunk_attacks[$key] + count))
            chunk_sum_attacks=$((chunk_sum_attacks + count))
        done

        # Calcular Dummy para ESTE CHUNK
        dummy=$((alerts_total - chunk_sum_attacks))
        chunk_dummies[$chunk_num]=$((chunk_dummies[$chunk_num] + dummy))
    done
done

# Calcular e exibir médias por CHUNK
echo -e "\n=== MÉDIAS POR CHUNK (sobre $total_executions execuções) ==="
for chunk_num in $(seq 0 $((total_chunks - 1))); do
    # Cálculo das médias
    avg_time=$(echo "scale=2; ${chunk_times[$chunk_num]} / $total_executions" | bc)
    avg_alerts=$(echo "scale=2; ${chunk_alerts[$chunk_num]} / $total_executions" | bc)
    avg_pkts=$(echo "scale=2; ${chunk_pkts[$chunk_num]} / $total_executions" | bc)
    avg_mbits=$(echo "scale=2; ${chunk_mbits[$chunk_num]} / $total_executions" | bc)
    avg_dummy=$(echo "scale=2; ${chunk_dummies[$chunk_num]} / $total_executions" | bc)

    echo -e "\n=== Chunk $chunk_num ==="
    echo "Tempo médio: $avg_time segundos"
    echo "Média de alertas: $avg_alerts"
    echo "Taxa média de pacotes: $avg_pkts pkts/sec"
    echo "Largura de banda média: $avg_mbits Mbits/sec"
    
    # Médias de ataques para este chunk
    for pattern in "${!attack_names[@]}"; do
        key="chunk${chunk_num}_${pattern}"
        avg_attack=$(echo "scale=2; ${chunk_attacks[$key]} / $total_executions" | bc)
        echo "${attack_names[$pattern]}: $avg_attack"
    done
    
    echo "Média de alertas Dummy: $avg_dummy"
done