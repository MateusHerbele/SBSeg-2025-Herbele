# Imagem base
FROM ubuntu:24.04

# Variáveis de ambiente
ENV DEBIAN_FRONTEND=noninteractive
ENV LD_LIBRARY_PATH=/usr/local/lib

# Instalação de dependências do Snort + Python + Editcap
RUN apt-get update && apt-get install -y \
    cmake \
    wget \
    git \
    libdumbnet-dev \
    flex \
    g++ \
    libhwloc-dev \
    libluajit-5.1-dev \
    libssl-dev \
    libpcap-dev \
    libpcre3-dev \
    pkg-config \
    zlib1g-dev \
    asciidoc \
    cpputest \
    dblatex \
    flatbuffers-compiler \
    libhyperscan-dev \
    libunwind-dev \
    liblzma-dev \
    libsafec-dev \
    source-highlight \
    w3m \
    uuid-dev \
    iproute2 \
    tcpdump \
    tcpreplay \
    libpcre2-dev \
    nano \
    wireshark-common \
    bc \
    python3.12 python3.12-venv python3-pip \
    && apt-get clean

# Criar diretórios
RUN mkdir -p /usr/src/datasets/original/chunks \
    /usr/src/datasets/microsec/chunks \
    /usr/src/rules \
    /usr/src/logs/microsec/chunks \
    /usr/src/logs/original/chunks

# Compilar o libdaq
WORKDIR /usr/src
RUN git clone https://github.com/snort3/libdaq.git && \
    cd libdaq && \
    ./bootstrap && \
    ./configure && \
    make install && \
    cd ..

# Compilar e instalar o Snort 3
RUN git clone https://github.com/snort3/snort3.git && \
    cd snort3 && \
    ./configure_cmake.sh --prefix=/usr/local && \
    cd build && \
    make -j$(nproc) && \
    make install && \
    cd ..

# Copiar scripts e regras do projeto
COPY /scripts /usr/src/scripts
COPY /rules /usr/src/rules

# Copiar script de inicialização
COPY /docker/init.sh /usr/src/init.sh

# Copia o pcap de teste e o script respectivo para dentro do container
COPY /teste-minimo /teste-minimo


# Limpeza
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Entrypoint: prepara ambiente e abre bash
ENTRYPOINT ["/usr/src/init.sh"]
