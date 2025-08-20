# Este artefato provê um ambiente de simulação para o MicroSec traffic

# MicroSec Traffic: Utilizando Estratégias de Engenharia de Tráfego para Aprimoramento da Eficiência de Sistemas de Detecção de Intrusão

Este trabalho propõe o MicroSec Traffic, uma abordagem para melhorar a eficiência de soluções IDS tradicionais baseadas em assinaturas e anomalias definidas por regras, por meio da redução da carga de dados do tráfego de rede, sem comprometer a detecção de ameaças. A técnica não exige modificações nas ferramentas IDS, como Snort ou Suricata, apenas ajustes nas regras utilizadas. Avaliada em um cenário controlado com o Snort, a abordagem demonstrou ser efetiva ao manter a geração de alertas com menor tempo de processamento e volume de dados.

## Estrutura do README.md

* [Título projeto](#microsec-traffic-utilizando-estratégias-de-engenharia-de-tráfego-para-aprimoramento-da-eficiência-de-sistemas-de-detecção-de-intrusão)
* [Estrutura do readme.md](#estrutura-do-readmemd)
* [Selos Considerados](#selos-considerados)
* [Informações básicas](#informações-básicas)
    * [Hardware](#hardware)
    * [Software](#software)
* [Dependências](#dependências)
* [Preocupações com segurança](#preocupações-com-segurança)
* [Instalação](#instalação)
* [Dataset](#dataset)
* [Dataset processado](#dataset-processado)
* [Teste mínimo](#teste-mínimo)
* [Experimentos](#experimentos)
   * [Reivindicação #1](#reivindicações-1)
* [Contato](#contato)
* [Informações gerais](#informações-gerais)
* [LICENSE](#license)


### Estrutura do repositório

```bash
SBSeg-2025-Herbele
├── docker
│   ├── Dockerfile
│   └── init.sh
├── Guia_do_usuário_MicroSec.pdf
├── LICENSE
├── README.md
├── rules
│   ├── microsec-pcap.rules
│   └── original-pcap.rules
├── scripts
│   ├── cenario-1.sh
│   ├── cenario-2.sh
│   ├── cenario-3.sh
│   ├── cenario-4.sh
│   ├── microsec.py
│   ├── requirements.txt
│   └── roda-cenarios.sh
└── teste-minimo
    └── teste-microsec.pcap

```
## Selos Considerados

Selo D + Selo F + Selo S + Selo R

## Informações básicas

### Hardware

    * CPU: AMD EPYC 7401 24-Core 2.0GHz
    * RAM: 16 GB
    * Kernel: 6.6.6-Atwood
    * SO: Debian GNU/Linux 12 (bookworm)
### Software
    * Docker - versão 28.0.2
    * Wireshark - versão 4.0.17
    * Python - versão 3.12

## Dependências

A execução do sistema depende da utilização de ambiente python para a execução de Sripts relacionados aos cortes do pacote, e junto a isso é necessário executar o docker para ter acesso ao sistema de detecção de intrusão Snort.

## Preocupações com segurança

Não há.

### Explicações:
O dataset original já está sendo estudado e avaliado desde 2017, e está disponível para download público o que permite auditação.
O dataset processado é gerado através do script microsec.py, que está disponível nesse repositório, utilizando como entrada o dataset original, possiblitando a auditação.
O ambiente do contêiner isola o experimento e dentro das reinvidicações a interação dos processos só ocorre dentro do mesmo.
## Instalação 

### Docker 
```
sudo apt install ca-certificates curl gnupg
```
#### Adicione a chave GPG oficial da Docker 
```
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```
#### Configuração do repositório do Docker
```
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
#### Atualize o índice de pacotes
```
sudo apt update
```
#### Instale o Docker Engine e o plugin do Docker Compose
```
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
#### Navegue até o diretório raíz do projeto e execute:
```
cd SBSeg-2025-Herbele
sudo docker build -t snort3-docker -f docker/Dockerfile .
```

## Dataset
Não é possível disponibilizar o dataset original nesse repositório por questões de limitação de tamanho de arquivos do próprio GitHub. Em razão disso, as explicações seguintes ensinam como ter acesso.

Para ter acesso ao dataset utilizado neste projeto é preciso acessar [CIC-IDS-2017](https://www.unb.ca/cic/datasets/ids-2017.html). Após acessar, toda informações sobre o dataset está apresentada no site, e para download é necessário ir ao final da página e clicar em "Download this dataset" e seguir as instruções até que seja liberado a página de download para "Wednesday-workingHours.pcap", que será o conjunto de dados usados no experimento.

Também é possível baixar diretamente via terminal por:
```
wget http://cicresearch.ca/CICDataset/CIC-IDS-2017/Dataset/CIC-IDS-2017/PCAPs/Wednesday-workingHours.pcap
```

## Dataset processado
Também é possível ter acesso ao dataset já processado pelos scripts em python em [Download pcap processado](https://www.inf.ufpr.br/msh22/microsec.html).

Que também pode ser possível baixar diretamente via terminal por:
```
wget https://www.inf.ufpr.br/msh22/dados/microsec.tar.gz
```
E descompatado com:
```
tar -zxvf microsec.tar.gz
```

## Teste mínimo

### Rodando o container
```
sudo docker run -d --name snort-container snort3-docker
```

#### Entrando no contâiner
```
sudo docker exec -it snort-container /bin/bash
```
### Executando apenas o script de teste mínimo
Nesse teste, serão utilizadas as regras desenvolvidas para gerar alerta com os ataques presentes no dataset, porém com uma porção pequena do pcap já processado. Assim, é possível avaliar em pouco tempo o funcionamento do Snort com o tráfego processado e as regras específicas.
```
cd /usr/src/teste-minimo
./min-teste.sh
```
O teste mínimo irá executar o Snort utilizando as regras estipuladas para o pacote processado no chunk determinado.

### Executando o script de configuração essencial do experimento
Esse script é responsável por:  
    - Baixar o dataset original e o dataset processado (MicroSec) dentro do contâiner;    
    - Criar os chunks dos datasets;  
    
```
cd /usr/src
./init.sh
```
Adendo: Em razão do tamanho do PCAP original (12.5 Gb), e da velocidade de download, pode haver um tempo de espera de até 1 hora.

### Executando o MicroSec com o PCAP original:
Foi disponibilizado o download do dataset já processado pela técnica, em razão de que, como esta simulação utiliza de ferramentas em Python, que não fazem parte da avaliação de desempenho ou de testes online, pode haver demora para o processamento completo, cerca de 4-7 horas. Caso não seja um tempo disponível, recomenda-se o download direto do pcap comprimido como descrito em seções anteriores e executado pelo script de init.sh.

Mas para a criação própria do PCAP processado utilizando a técnica basta seguir dentro do contêiner a seguinte execução:
```
cd /usr/src/scripts
./criar-pcap.sh
```

### Funcionamento do microsec.py
Para utilizar o microsec.py sem o auxílio de outros scripts, deve se ativar o ambiente python com os devidos requisitos instalados através do script criar-ambiente.sh, seguindo os seguintes comandos dentro do contêiner:
```
cd /usr/src/scritps
./criar-ambiete.sh
```

O microsec.py apresenta uma interface por linha de comandos que tem a seguinte estrutura principal:
```
python3 microsec.py <arquivo_pcap_de_entrada> <arquivo_pcap_de_saida> [--chunk_size <tamanho_do_bloco>]
```
O arquivo de entrada é o PCAP que será processado utilizando a técnica MicroSec;
O arquivo de saída é o PCAP resultado do processo;
E o opcional de chunk_size é para otimizar o tratamento de memória, no qual é possível limitar a quantidade de pacotes que são tratados por vez durante o processo. O valor padrão é de 10000.

## Experimentos

### Reivindicações #1

#### Entrando no contâiner
```
sudo docker exec -it snort-container /bin/bash
```   

#### Acessando o snort (estando dentro do contâiner)
```
cd /usr/src/snort3/lua
```
#### Executando o snort
```
snort --daq pcap -R [rota para o arquivo de regras que serão usadas] -r [rota do pcap que será analisado] -A cmg > [rota para o log de saída]
```

Observação: As regras atribuídas para cada cenário não devem ser alteradas para que a replicação do experimento não seja comprometida!

Existem mais de 500 regras por rule file, apenas 4 dessas em cada arquivo são legítimas e estão ligadas diretamente com a geração de alertas para os tipos de ataques presente nos datasets. As outras 500 regras, são regras de sobrecarga para simular um comportamento mais próximo ao real do Snort, chamadas de regras dummy. As regras legítimas são respectivamente as primeiras regras presentes em cada arquivo.

Existem 4 cenários de execução:
    1. Executar o snort com as regras específicas para o pcap original junto do mesmo;
    2. Executar o snort com as regras específicas para o pcap processado pelo microsec junto do mesmo;
    3. Executar o snort com as regras específicas para o pcap original para cada chunk gerado a partir do pcap original;
    4. Executar o snort com as regras específicas para o pcap processado pelo microsec para cada chunk gerado a partir do pcap processado pelo microsec.

Devem ser feitas 10 execuções por cenário, para que seja possível avaliar a média e ter uma noção mais vasta da eficiência da técnica.

### Script para a execução dos cenários
Para a execução dos cenários de forma automatizada deve-se utilizar o script roda-cenarios.sh, localizado em /usr/src/scripts. O scirpt irá executar o snort no modo adequado, comentando anteriormente, para a geração dos logs, que possibilite posteriormente, no mesmo script, a execução de cada cenário, que são arquivos de script bash individuais
```
cd /usr/src/scripts
./roda-cenarios.sh
```

### Resultados
Na execução do script serão impressas as informações retiradas de cada log de cada cenário e de suas respecitvas médias dentre todas as execuções. 

### Contato
Autor: Mateus dos Santos Herbele
e-mail: msh22@inf.ufpr.br

Estou disponível para responder todas as dúvidas sobre a pesquisa :)

### Informações gerais:
Link do repositório: https://github.com/MateusHerbele/SBSeg-2025-Herbele/tree/main
Última data de atualização: 20/08/2025.

## LICENSE

GNU GPL v3

