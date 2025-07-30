# MicroSec Traffic: Utilizando Estratégias de Engenharia de Tráfego para Aprimoramento da Eficiência de Sistemas de Detecção de Intrusão

Este trabalho propõe o MicroSec Traffic, uma abordagem para melhorar a eficiência de soluções IDS tradicionais baseadas em assinaturas e anomalias definidas por regras, por meio da redução da carga de dados do tráfego de rede, sem comprometer a detecção de ameaças. A técnica não exige modificações nas ferramentas IDS, como Snort ou Suricata, apenas ajustes nas regras utilizadas. Avaliada em um cenário controlado com o Snort, a abordagem demonstrou ser efetiva ao manter a geração de alertas com menor tempo de processamento e volume de dados.

## Estrutura do README.md

* [Título do projeto](#microsec-traffic:-utilizando-estratégias-de-engenharia-de-tráfego-para-aprimoramento-da-eficiência-de-sistemas-de-detecção-de-intrusão)
* [Estrutura do readme.md](#estrutura-do-readmemd) 
* [Informações básicas](#informações-básicas)
    * [Hardware](#hardware)
    * [Software](#software)
* [Dependêcnias](#dependências)
* [Instalação](#instalação)
* [Dataset](#dataset)
* [Teste mínimo](#teste-mínimo)
* [Experimentos](#experimentos) 
* [LICENSE](#license)

### Estrutura do repositório

### Definição dos diretórios

## Informações básicas

### Hardware

    * CPU: AMD EPYC 7401 24-Core 2.0GHz
    * RAM: 16 GB
    * Kernel: 6.6.6-Atwood
    * SO: Debian GNU/Linux 12 (bookworm)
### Software
    * Docker - versão 28.0.2

## Dependências

A execução do sistema depende da utilização de ambiente python para a execução de Sripts relacionados aos cortes do pacote, e junto a isso é necessário executar o docker para ter acesso ao sistema de detecção de intrusão Snort.

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
source "nome do ambiente"/bin/source
```
#### Navegue até o diretório 'scripts' do projeto e instale os requisitos:
```
cd SBSeg-2025-Herbele/scripts
pip install -r requirements.txt
```

## Acesso ao dataset
Não é possível disponibilizar o dataset original nesse repositório em razões de direitos dos criadores do dataset e questões de limitação de tamanho de arquivos do próprio GitHub. Em razão disso, as explicações seguintes ensinam como ter acesso.

Para ter acesso ao dataset utilizado neste projeto é preciso acessar [CIC-IDS-2017](https://www.unb.ca/cic/datasets/ids-2017.html). Após acessar, há presente toda informação sobre o dataset, e para dowload é necessário ir ao final da página e clicar em "Dowload this dataset" e seguir as instruções até que seja liberado a página de dowload para "Wednesday-workingHours.pcap", que será o conjunto de dados usadols no experimento.

## Dataset processado
Também é possível ter acesso ao dataset já processado pelos scripts em python em [link para a minha página do dinf]()

** Importante **
Ambos os datasets devem estar de preferência na rota "SBSeg-2025-Herbele/datasets"

## Experimento

### Gerando o dataset cortado
A primeira etapa é a geração do dataset processado pela estratégia de MicroSec Traffic, assim, com o ambiente python ativado deve-se executar:
```
python microsec.py
```
Após a execução do script, você deverá ter o pcap com um pacotes processados devidamente seguindo a estratégia.

### Gerando os chunks
```
editcap -c 1000000 SBSeg-2025-Herbele/datasets/microsec/microsec.pcap SBSeg-2025-Herbele/datasets/microsec/chunks

editcap -c 1000000 SBSeg-2025-Herbele/datasets/original/Wednesday-workingHours.pcap SBSeg-2025-Herbele/datasets/original/chunks
```

