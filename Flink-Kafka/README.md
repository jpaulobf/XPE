# Data Ingestion com Kafka e Apache Flink

Exercício para praticar uma pipeline de Streaming de Dados com Kafka + Flink. Vamos implementar a seguinte arquitetura:

Integração do Kafka com o Apache Flink que processará os dados e os enviará a uma database (postgresql). Todos os serviços que compõem o kafka, flink e a database PostgreSQL que servirá de fonte serão implantados com `docker-compose`.

---

# Passo a passo para execução

## 1 - Pré-requisitos

- Docker
- docker-compose
- Uma conta no Docker Hub
- Python 3
    - Faker
    - Confluent_Kafka
    - SimpleJson

## 2 - Subir o ambiente
Com os prerequisitos instalados e testados, baixar o projeto no GitHub e entrar na pasta `Flink-Kafka`, execute o seguinte comando:

```bash
cd docker
docker-compose up -d
```
O ambiente será baixado e provisionado em sua máquina, conforme desenho arquitetural descrito na pasta `arquitetura`.

## 3 - Executar os dados fakes

No arquivo `docker-compose.yml
` na pasta `postgres` estamos subindo o banco de dados.

## 5 - Processar o ETL

Veja o arquivo importar.ipynb (necessário o Jupyter)

## 6 - Subir a plataforma Confluent no docker-compose

No arquivo `docker-compose.yml` estamos subindo toda a estrutura da plataforma Confluent. Para isso, vamos entrar na pasta e subir a estrutura.

```bash
cd ..
docker-compose up -d
```

## 7 - Criar dos tópicos no Kafka

Vamos criar dois tópicos do kafka que irão armazenar os dados movidos da fonte.

```bash
docker exec -it broker bash

kafka-topics --create \
   --bootstrap-server localhost:9092 \
   --partitions 1 \
   --replication-factor 1 \
   --topic postgres-dadostesouroipca

kafka-topics --create \
   --bootstrap-server localhost:9092 \
   --partitions 1 \
   --replication-factor 1 \
   --topic postgres-dadostesouropre
```

## 8 - Registrar os parâmetros de configuração do connector no kafka

Para isso, vamos precisar de um arquivo no formato `json` contendo as configurações do conector que vamos registrar. 
O arquivo `connect_jdbc_postgres_ipca.config` possui a implementação do IPCA.
O arquivo `connect_jdbc_postgres_pre.config` possui a implementação do PRE.

 O conteúdo do arquivo está transcrito abaixo:

```json
{
    "name": "postg-connector",
    "config": {
        "connector.class": "io.confluent.connect.jdbc.JdbcSourceConnector",
        "tasks.max": 1,    
        "connection.url": "jdbc:postgresql://postgres:5432/postgres",
        "connection.user": "postgres",
        "connection.password": "Jp1987",
        "mode": "timestamp",
        "timestamp.column.name": "dt_update",
        "table.whitelist": "public.[nomedobd]",
        "topic.prefix": "postgres-",
        "validate.non.null": "false",
        "poll.interval.ms": 500
    }
}
```

Com o arquivo, fazemos uma chamada à API do Kafka para registrar os parâmetros:

```bash
curl -X POST -H "Content-Type: application/json" \
    --data @connectors/source/connect_jdbc_postgres.config localhost:8083/connectors

curl -X POST -H "Content-Type: application/json" \
    --data @connectors/source/connect_jdbc_postgres_pre.config localhost:8083/connectors
```

```bash
docker exec -it broker bash

kafka-console-consumer --bootstrap-server localhost:9092 \
--topic postgres-dadostesouroipca \
--from-beginning

kafka-console-consumer --bootstrap-server localhost:9092 \
--topic postgres-dadostesouropre \
--from-beginning

kafka-topics --bootstrap-server localhost:9092 \
--describe \
--topic postgres-dadostesouroipca

kafka-topics --bootstrap-server localhost:9092 \
--describe \
--topic postgres-dadostesouropre
```


Este comando cria um conector que irá puxar todo o conteúdo da tabela mais todos os novos dados que forem inseridos. **Atenção**: O Kafka connect não puxa, por default, alterações feitas em registros já existentes. Puxa apenas novos registros. Para verificar se nossa configuração foi criada corretamente e o conector está ok, vamos exibir os logs.

```bash
docker logs -f connect
```

e verifique se não há nenhuma mensagem de erro. 

Agora, vamos subir dois `sink connectors` para entregar os dados desse tópico diretamente ao S3. Um exemplo de configuração do conector está apresentado abaixo:

```json
{
    "name": "customers-s3-sink",
    "config": {
        "connector.class": "io.confluent.connect.s3.S3SinkConnector",
        "format.class": "io.confluent.connect.s3.format.json.JsonFormat",
        "keys.format.class": "io.confluent.connect.s3.format.json.JsonFormat",
        "schema.generator.class": "io.confluent.connect.storage.hive.schema.DefaultSchemaGenerator",
        "flush.size": 2,
        "schema.compatibility": "FULL",
        "s3.bucket.name": "NOME-DO-BUCKET",
        "s3.region": "us-east-1",
        "s3.object.tagging": true,
        "s3.ssea.name": "AES256",
        "topics.dir": "raw-data/kafka",
        "storage.class": "io.confluent.connect.s3.storage.S3Storage",
        "tasks.max": 1,
        "topics": "postgres-dadostesouroipca"
    }
}
```

Para subir o sink, usamos o seguinte comando:

```bash
curl -X POST -H "Content-Type: application/json" \
    --data @connectors/sink/connect_s3_sink_ipca.config localhost:8083/connectors

curl -X POST -H "Content-Type: application/json" \
    --data @connectors/sink/connect_s3_sink_pre.config localhost:8083/connectors
```

Este sink vai pegar todos os eventos no tópico `postgres-dadostesouroipca` e `postgres-dadostesouropre` e escrever no S3.

---

**Parabéns**!! Você acabou de concluir o seu pipeline de processamento de dados em tempo real usando a plataforma Confluent no docker-compose!