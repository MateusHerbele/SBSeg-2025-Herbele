# Este artefato provê um ambiente de simulação para o MicroSec traffic

# MicroSec Traffic: Utilizando Estratégias de Engenharia de Tráfego para Aprimoramento da Eficiência de Sistemas de Detecção de Intrusão

Este trabalho propõe o MicroSec Traffic, uma abordagem para melhorar a eficiência de soluções IDS tradicionais baseadas em assinaturas e anomalias definidas por regras, por meio da redução da carga de dados do tráfego de rede, sem comprometer a detecção de ameaças. A técnica não exige modificações nas ferramentas IDS, como Snort ou Suricata, apenas ajustes nas regras utilizadas. Avaliada em um cenário controlado com o Snort, a abordagem demonstrou ser efetiva ao manter a geração de alertas com menor tempo de processamento e volume de dados.

## Estrutura do README.md

* [Título projeto](#microsec-traffic:-utilizando-estratégias-de-engenharia-de-tráfego-para-aprimoramento-da-eficiência-de-sistemas-de-detecção-de-intrusão)
* [Estrutura do readme.md](#estrutura-do-readmemd)
* [Selos Considerados](#selos-considerados)
* [Informações básicas](#informações-básicas)
    * [Hardware](#hardware)
    * [Software](#software)
* [Dependências](#dependências)
* [Preocupações com segurança](#preocupações-com-seguranca)
* [Instalação](#instalacao)
* [Dataset](#dataset)
* [Dataset processado](#dataset-processado)
* [Teste mínimo](#teste-mínimo)
* [Experimentos](#experimentos)
   * [Reivindicação #1](#reivindicações-#1)
* [LICENSE](#license)

### Estrutura do repositório

```bash
SBSeg-2025-Herbele
├── datasets
│   ├── microsec
│   │   └── chunks
│   └── original
│       └── chunks
├── docker
│   └── Dockerfile
├── logs
│   ├── microsec
│   │   └── chunks
│   └── original
│       └── chunks
├── README.md
├── rules
│   ├── microsec-pcap.rules
│   └── original-pcap.rules
└── scripts
    ├── cenario-1.sh
    ├── cenario-2.sh
    ├── cenario-3.sh
    ├── cenario-4.sh
    ├── micro-sec.py
    └── requirements.txt

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
#### Navegue até o diretório 'docker' do projeto e execute:
```
cd SBSeg-2025-Herbele/docker
docker build -t snort3-docker .
```


### Python 

#### Instalando Python
```
sudo apt install python3.12
```
#### Criando o ambiente python
```
python -m venv "nome do ambiente"
```
#### Ativando o ambiente criado
```
source "nome do ambiente"/bin/activate
```
#### Navegue até o diretório 'scripts' do projeto e instale os requisitos:
```
cd SBSeg-2025-Herbele/scripts
pip install -r requirements.txt
```
### Editcap
Será importante para a geração dos chunks dos datasets.
```
sudo apt install wireshark
```


## Dataset
Não é possível disponibilizar o dataset original nesse repositório em razões de direitos dos criadores do dataset e questões de limitação de tamanho de arquivos do próprio GitHub. Em razão disso, as explicações seguintes ensinam como ter acesso.

Para ter acesso ao dataset utilizado neste projeto é preciso acessar [CIC-IDS-2017](https://www.unb.ca/cic/datasets/ids-2017.html). Após acessar, toda informações sobre o dataset está apresentada no site, e para download é necessário ir ao final da página e clicar em "Download this dataset" e seguir as instruções até que seja liberado a página de download para "Wednesday-workingHours.pcap", que será o conjunto de dados usados no experimento.

## Dataset processado
Também é possível ter acesso ao dataset já processado pelos scripts em python em [Download pcap processado](https://www.inf.ufpr.br/msh22/microsec.html).

** Importante **
Ambos os datasets devem estar em suas rotas corretas:
   * Para o dataset original: "SBSeg-2025-Herbele/datasets/original";
   * Para o dataset processado: "SBSeg-2025-Herbele/datasets/microsec".
## Teste mínimo

### Gerando o dataset processado
A primeira etapa é a geração do dataset processado pela estratégia de MicroSec Traffic, assim, com o ambiente python ativado deve-se ir até SBSeg-2025-Herbele/scripts e executar:
```
cd SBSeg-2025-Herbele/scripts
python microsec.py
```
Após a execução do script, você deverá ter o pcap com um pacotes processados devidamente seguindo a estratégia.

### Gerando os chunks
```
editcap -c 1000000 SBSeg-2025-Herbele/datasets/microsec/microsec.pcap SBSeg-2025-Herbele/datasets/microsec/chunks/microsec-%d.pcap

editcap -c 1000000 SBSeg-2025-Herbele/datasets/original/Wednesday-workingHours.pcap SBSeg-2025-Herbele/datasets/original/chunks/original-%d.pcap
```

### Rodando o container
```
docker run -d --name snort-container snort3-docker
```

### Enviando para o contâiner os dados necessários
```
sudo docker cp SBSeg-2025-Herbele/datasets/microsec/* snort-container:/usr/src/datasets/microsec/

sudo docker cp SBSeg-2025-Herbele/datasets/original/* snort-container:/usr/src/datasets/original/
```

### Enviando para o contâiner as regras
```
sudo docker cp SBSeg-2025-Herbele/rules/* snort-container:/usr/src/rules
```
## Experimentos

### Reinvindicações #1

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
Existem 4 cenários de execução:
    1. Executar o snort com as regras específicas para o pcap original junto do mesmo;
    2. Executar o snort com as regras específicas para o pcap processado pelo microsec junto do mesmo;
    3. Executar o snort com as regras específicas para o pcap original para cada chunk gerado a partir do pcap original;
    4. Executar o snort com as regras específicas para o pcap processado pelo microsec para cada chunk gerado a partir do pcap processado pelo microsec.

Devem ser feitas 10 execuções por cenário, para que seja possível avaliar a média e ter uma noção mais vasta da eficiência da técnica. Deve-se utilizar numerações de 0 a 9 para as execuções.

#### Executando o cenário 1:
```
snort --daq pcap -R /usr/src/rules/original.rules -r /usr/src/datasets/original/Wednesday-workingHours.pcap -A cmg > /usr/src/logs/original-[número da execução].txt
```

#### Executando o cenário 2:
```
snort --daq pcap -R /usr/src/rules/microsec.rules -r /usr/src/datasets/microsec/microsec.pcap -A cmg > /usr/src/logs/microsec-[número da execução].txt
```

#### Executando o cenário 3:
```
snort --daq pcap -R /usr/src/rules/original.rules -r /usr/src/datasets/original/chunks/original-[numero do chunk].pcap -A cmg > /usr/src/logs/original/chunks/[número da execução]/original-[numero do chunk].txt
[...]
```

#### Executando o cenário 4:
```
snort --daq pcap -R /usr/src/rules/microsec.rules -r /usr/src/datasets/microsec/chunks/microsec-[numero do chunk].pcap -A cmg > /usr/src/logs/microsec/chunks/[número da execução]/microsec-[numero do chunk].txt
[...]
```

#### Fazer uma cópia dos logs para fora do contâiner:
Sair do contâiner com: 
    Ctrl + P + Q

Voltando para a máquina host, deve ser executado:
```
docker cp snort-container:/usr/src/logs/microsec/* /SBSeg-2025-Herbele/logs/microsec

docker cp snort-container:/usr/src/logs/original/* /SBSeg-2025-Herbele/logs/original
```
#### Avaliando o resultado dos cenários 1 e 2:
Deve-se ir até o diretório scripts:
```
cd /SBSeg-2025-Herbele/scripts
```

Deve-se executar o script cenario-1.sh para avaliar o cenário 1:
```
./cenario-1.sh
```
Deve-se executar o script cenario-2.sh para avaliar o cenário 2:
```
./cenario-2.sh
```
Serão impressas no terminal as informações de cada log de execução e da média entre esses mesmos valores entre todos eles.


#### Rodando scripts para a avaliação dos logs dos chunks:

Deve-se ir até o diretório scripts:
```
cd /SBSeg-2025-Herbele/scripts
```

Deve-se executar o script cenario-3.sh para avaliar o cenário 1:
```
./cenario-3.sh
```
Deve-se executar o script cenario-4.sh para avaliar o cenário 2:
```
./cenario-4.sh
```
Serão impressas no terminal as informações de execução e da média entre esses mesmos valores entre todos os chunks ao longo de cada execução.

Então será mostrado, na execução do script de cada cenário, informações importantes para a análise como o tempo de execução e o número de alertas.

## LICENSE

GNU GPL v3

