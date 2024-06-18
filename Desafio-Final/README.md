# Data Ingestion com Kafka e Kafka Connect

Exercício para praticar uma pipeline de Streaming de Dados com Kafka. Vamos implementar a seguinte arquitetura:

Integração do Kafka com uma database (postgresql) usando *kafka connect* e entrega em data lake com *kafka connect*. Todos os serviços que compõem o kafka e a database PostgreSQL que servirá de fonte serão implantadas com `docker-compose`.

---
# Passo a passo para execução

## 1 - Pré-requisitos

- Docker
- docker-compose
- Uma conta AWS free tier
- Comando jq

## 2 - Intalar o comando `jq`

O jq é uma ferramenta de linha de comando leve e flexível para processar dados JSON. 
Ele permite filtrar, transformar e manipular dados JSON de uma maneira muito semelhante 
ao sed, awk, grep, cut e outras ferramentas fazem para texto.

No seu script, `jq` é utilizado para processar as respostas JSON retornadas pelas APIs do Kafka Connect. 
Quando fazemos requisições HTTP para obter informações sobre os conectores, a resposta vem em formato JSON, 
que pode ser difícil de ler e manipular diretamente na linha de comando.

O `jq` facilita isso, permitindo que seja possível extrair e formatar as informações 
de maneira mais legível e utilizável.


### Ubuntu/Debian
```
sudo apt-get update
sudo apt-get install jq
```

### macOS
```
brew install jq
```

## 3 - Tornar o arquivo shell script cluster.sh executável
```
chmod +x cluster.sh
```

## 4 - Execute o shell script cluster.sh

Ele é autoexplicativo, irá lhe orientar com os passos necessários.

presumindo que você está no diretório onde está o script, faça:
```
./cluster.sh
```

# Explicações dos comandos incluídos no script cluster.sh

Esses comandos permitem que você gerencie e monitore seu cluster Kafka e serviços relacionados de maneira eficiente.


### Comandos de Controle do Cluster

1. **--build**
   - **Descrição**: Constrói a imagem Docker `connect-custom:1.0.0`.
   - **Uso**: `./cluster.sh --build`
   - **Explicação**: Este comando é usado para construir a imagem Docker personalizada do Kafka Connect.

2. **--restart**
   - **Descrição**: Reinicia os serviços Docker, removendo todos os containers e volumes.
   - **Uso**: `./cluster.sh --restart`
   - **Explicação**: Este comando para e remove todos os containers e volumes associados, e em seguida, inicia os serviços novamente.

3. **--down**
   - **Descrição**: Encerra o cluster e apaga todos os dados.
   - **Uso**: `./cluster.sh --down`
   - **Explicação**: Este comando para todos os containers do cluster e remove todos os volumes, efetivamente limpando todos os dados armazenados.

4. **--stop**
   - **Descrição**: Para o cluster sem apagar os dados.
   - **Uso**: `./cluster.sh --stop`
   - **Explicação**: Este comando para todos os containers do cluster, mas mantém os volumes, permitindo a retenção dos dados.

5. **--ps**
   - **Descrição**: Lista todos os containers em execução do cluster.
   - **Uso**: `./cluster.sh --ps`
   - **Explicação**: Este comando exibe a lista de todos os containers em execução no cluster.

### Comandos de Logs

6. **--logs [--service <nome_do_serviço>]**
   - **Descrição**: Exibe os logs do cluster ou de um serviço específico.
   - **Uso**: 
     - Para todos os logs do cluster: `./cluster.sh --logs`
     - Para logs de um serviço específico: `./cluster.sh --logs --service <nome_do_serviço>`
   - **Explicação**: Este comando exibe os logs de todos os containers no cluster ou de um serviço específico se especificado.

### Comandos do Kafka

7. **--topics-list**
   - **Descrição**: Lista todos os tópicos do Kafka.
   - **Uso**: `./cluster.sh --topics-list`
   - **Explicação**: Este comando exibe uma lista de todos os tópicos configurados no cluster Kafka.

8. **--topic-describe --topic <nome_do_tópico>**
   - **Descrição**: Descreve um tópico específico do Kafka.
   - **Uso**: `./cluster.sh --topic-describe --topic <nome_do_tópico>`
   - **Explicação**: Este comando fornece detalhes sobre um tópico específico, incluindo partições, fator de replicação, líderes de partições e réplicas.

9. **--get-offsets --topic <nome_do_tópico>**
   - **Descrição**: Exibe offsets de um tópico específico.
   - **Uso**: `./cluster.sh --get-offsets --topic <nome_do_tópico>`
   - **Explicação**: Este comando exibe os offsets atuais para todas as partições de um tópico especificado.

10. **--topic-create --topic <nome_do_tópico>**
    - **Descrição**: Cria um novo tópico no Kafka.
    - **Uso**: `./cluster.sh --topic-create --topic <nome_do_tópico>`
    - **Explicação**: Este comando cria um novo tópico no Kafka com uma partição e um fator de replicação de 1.

11. **--topic-delete --topic <nome_do_tópico>**
    - **Descrição**: Deleta um tópico do Kafka.
    - **Uso**: `./cluster.sh --topic-delete --topic <nome_do_tópico>`
    - **Explicação**: Este comando deleta um tópico especificado do Kafka.

### Comandos do Kafka Connect

12. **--connector-status**
    - **Descrição**: Verifica o status dos connectors.
    - **Uso**: `./cluster.sh --connector-status`
    - **Explicação**: Este comando exibe o status de todos os connectors configurados no Kafka Connect.

13. **--connectors-list**
    - **Descrição**: Lista todos os connectors.
    - **Uso**: `./cluster.sh --connectors-list`
    - **Explicação**: Este comando lista todos os connectors configurados no Kafka Connect.

14. **--connector-restart --connector <nome_do_connector>**
    - **Descrição**: Reinicia um connector específico.
    - **Uso**: `./cluster.sh --connector-restart --connector <nome_do_connector>`
    - **Explicação**: Este comando reinicia um connector especificado no Kafka Connect.

### Comandos para Consumidores

15. **--monitor-consume-ipca**
    - **Descrição**: Monitora a saída do consumidor do tópico `postgres-dadostesouroipca`.
    - **Uso**: `./cluster.sh --monitor-consume-ipca`
    - **Explicação**: Este comando inicia a monitoração da saída do consumidor do tópico `postgres-dadostesouroipca` utilizando `tail -f` no arquivo de log.

16. **--monitor-consume-pre**
    - **Descrição**: Monitora a saída do consumidor do tópico `postgres-dadostesouropre`.
    - **Uso**: `./cluster.sh --monitor-consume-pre`
    - **Explicação**: Este comando inicia a monitoração da saída do consumidor do tópico `postgres-dadostesouropre` utilizando `tail -f` no arquivo de log.

### Comandos do AWS S3

17. **--s3-list-files --bucket <nome_do_bucket> --path <caminho/do/diretorio>**
    - **Descrição**: Lista os arquivos de um bucket e um caminho específico.
    - **Uso**: `./cluster.sh --s3-list-files --bucket <nome_do_bucket> --path <caminho/do/diretorio>`
    - **Explicação**: Este comando lista os arquivos presentes em um bucket e diretório especificados no S3.

18. **--s3-list-buckets**
    - **Descrição**: Lista todos os buckets no S3.
    - **Uso**: `./cluster.sh --s3-list-buckets`
    - **Explicação**: Este comando lista todos os buckets disponíveis na conta AWS configurada.

19. **--s3-create-bucket --bucket <nome_do_bucket>**
    - **Descrição**: Cria um novo bucket no S3.
    - **Uso**: `./cluster.sh --s3-create-bucket --bucket <nome_do_bucket>`
    - **Explicação**: Este comando cria um novo bucket com o nome especificado no S3.

20. **--s3-delete-bucket --bucket <nome_do_bucket>**
    - **Descrição**: Exclui um bucket no S3.
    - **Uso**: `./cluster.sh --s3-delete-bucket --bucket <nome_do_bucket>`
    - **Explicação**: Este comando exclui um bucket com o nome especificado no S3, incluindo todos os seus conteúdos.

### Comando de Ajuda

21. **--help**
    - **Descrição**: Exibe a ajuda e sai.
    - **Uso**: `./cluster.sh --help`
    - **Explicação**: Este comando exibe a lista de opções disponíveis e sua descrição, e então sai do script.

### Comandos de Exemplo:

- Construir a imagem e reiniciar os serviços:
  ```bash
  ./cluster.sh --build --restart
  ```

- Monitorar a saída do consumidor do tópico `postgres-dadostesouroipca`:
  ```bash
  ./cluster.sh --monitor-consume-ipca
  ```

- Exibir logs de todos os serviços:
  ```bash
  ./cluster.sh --logs
  ```

- Exibir logs de um serviço específico:

  ```bash
  #./cluster.sh --logs --service <nome_do_servico>
  ./cluster.sh --logs --service postgres
  ```

- Encerrar o cluster e apagar todos os dados:
  ```bash
  ./cluster.sh --down
  ```

- Parar o cluster sem apagar os dados:
  ```bash
  ./cluster.sh --stop
  ```

- Listar todos os tópicos do Kafka:
  ```bash
  ./cluster.sh --topics-list
  ```

- Descrever um tópico específico:
  ```bash
  #./cluster.sh --topic-describe --topic <nome_do_topico>
  ./cluster.sh --topic-describe --topic postgres-dadostesouroipca
  ```

- Exibir offsets de um tópico específico:
  ```bash
  #./cluster.sh --get-offsets --topic <nome_do_topico>
  ./cluster.sh --get-offsets --topic postgres-dadostesouroipca
  ```

- Criar um novo tópico no Kafka:
  ```bash
  #./cluster.sh --topic-create --topic nome_do_topico
  ./cluster.sh --topic-create --topic novo-topico
  ```  

- Deletar um tópico do Kafka: 
  ```bash
  #./cluster.sh --topic-delete --topic <nome_do_topico>
  ./cluster.sh --topic-delete --topic novo-topico
  ```

- Verificar o status dos connectors:
  ```bash
  ./cluster.sh --connector-status
  ```

- Listar todos os connectors:
  ```bash
  ./cluster.sh --connectors-list
  ```

- Reiniciar um connector específico:
  ```bash
  #./cluster.sh --connector-restart --connector <nome_do_connector>
  ./cluster.sh --connector-restart --connector customers-s3-sink-pre
  ```

- Listar arquivos de um bucket e caminho específico:
  ```bash
  ./cluster.sh --s3-list-files --bucket nome_do_bucket --path caminho/do/diretorio
  ```

- Listar todos os buckets no S3:
  ```bash
  ./cluster.sh --s3-list-buckets
  ```

- Criar um novo bucket no S3:
  ```bash
  #./cluster.sh --s3-create-bucket --bucket nome_do_bucket
  ./cluster.sh --s3-create-bucket --bucket meu-bucket-aws-s3
  ```

- Excluir um bucket no S3:
  ```bash
  #./cluster.sh --s3-delete-bucket --bucket nome_do_bucket
  ./cluster.sh --s3-delete-bucket --bucket meu-bucket-aws-s3
  ```

