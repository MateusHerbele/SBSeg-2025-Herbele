from scapy.all import *
from scapy.layers.http import HTTPRequest
from scapy.layers.inet import IP
from scapy.layers.inet6 import IPv6
import time

def process_packet(packet):
    original_length = len(packet)
    print(f"\n--- Pacote original (tamanho: {original_length} bytes) ---")
    
    # Criar a camada Ethernet mínima (apenas MACs e tipo)
    if Ether in packet:
        eth = Ether(src=packet[Ether].src, dst=packet[Ether].dst, type=packet[Ether].type)
    else:
        return packet
    
    # Criar a camada IP, removendo TCP completamente
    if IP in packet:
        ip = IP(src=packet[IP].src, dst=packet[IP].dst, ttl=64)
    elif IPv6 in packet:
        ip = IPv6(src=packet[IPv6].src, dst=packet[IPv6].dst, hlim=64)
    else:
        new_packet = eth
        new_packet.time = packet.time  # <-- Preserva o timestamp
        print(f"Pacote não-IP - mantido apenas Ethernet básica")
        print(f"Tamanho final: {len(new_packet)} bytes (redução de {original_length - len(new_packet)} bytes)")
        return new_packet
    
    # Extrair método HTTP e colocar no payload IP
    if TCP in packet and packet[TCP].dport == 80 and HTTPRequest in packet:
        http_method = packet[HTTPRequest].Method.decode('utf-8')
        payload = Raw(load=http_method)  # Apenas o método HTTP no payload do IP
        new_packet = eth / ip / payload
        print(f"Pacote HTTP - mantido Ethernet+IP+método '{http_method}' (TCP removido)")
    else:
        new_packet = eth / ip  # Para pacotes não-HTTP, manter apenas Ethernet+IP
        print("Pacote não-HTTP - mantido apenas Ethernet+IP")
    
    # Agora, copiar o timestamp
    new_packet.time = packet.time
    
    final_length = len(new_packet)
    print(f"Tamanho final: {final_length} bytes (redução de {original_length - final_length} bytes)")
    return new_packet

def process_large_pcap(input_pcap, output_pcap, chunk_size=10000):
    exe_time = time.time()
    
    pcap_reader = PcapReader(input_pcap)
    pcap_writer = PcapWriter(output_pcap, sync=True)
    
    packet_count = 0
    total_original = 0
    total_processed = 0
    
    try:
        while True:
            packets = pcap_reader.read_all(count=chunk_size)
            if not packets:
                break
                
            for packet in packets:
                original_size = len(packet)
                processed_packet = process_packet(packet)
                processed_size = len(processed_packet)
                
                pcap_writer.write(processed_packet)
                
                packet_count += 1
                total_original += original_size
                total_processed += processed_size
            
            print(f"\nProgresso: {packet_count} pacotes")
            print(f"Redução total: {total_original - total_processed} bytes")
    
    except Exception as e:
        print(f"Erro: {e}")
    finally:
        pcap_reader.close()
        pcap_writer.close()
    
    exe_time = time.time() - exe_time

    print(f"\nProcessamento completo!")
    print(f"Pacotes processados: {packet_count}")
    print(f"Tamanho original total: {total_original} bytes")
    print(f"Tamanho processado total: {total_processed} bytes")
    print(f"Redução total: {total_original - total_processed} bytes ({((total_original - total_processed)/total_original*100):.2f}%)")
    print(f"Tempo total: {exe_time} segundos")


# Configuração
input_file = "../datasets/original/Wednesday-workingHours.pcap"
output_file = "../datasets/microsec/microsec.pcap"
process_large_pcap(input_file, output_file, chunk_size=10000)
