# Desafio: Data Ingestion com Kafka e Apache Flink

Desafio de uma pratica de pipeline de Streaming de Dados com Kafka + Flink. Vamos implementar a seguinte arquitetura:

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
Com os prerequisitos instalados e testados, baixar o projeto no GitHub e entrar na pasta `Desafio\Flink`, execute o seguinte comando:

```bash
cd docker
docker-compose up -d
```
O ambiente será baixado e provisionado em sua máquina, conforme desenho arquitetural descrito na pasta `arquitetura`.

## 3 - Carregar os dados fakes no Tópico do Kafka

Na pasta `python` executar a geração dos dados com o comando:
```bash
python3 .\main.py
```

## 4 - Pare os dados fake

```bash
CTRL + C
```


## 5 - Criar o arquivo JAR com o Intellij

Abrir o Intellij, abrir a pasta do projeto Java e criar o JAR que será depositado no Flink.
Abra o terminal e digite: 

```bash
mvn clean compile package
```

## 6 - Abrir o Manager do Flink

Vá até seu navegador e digite o seguinte endereço:

```bash
http://localhost:8081
```

- No Intellij, abra a pasta Target (abrir com o explorer) e copie o JAR em seu Desktop (normalmente: FlinkCommerce-2.0-SNAPSHOT.jar).
- Depois clique no menu lateral esquerdo na opção `Submit new Job`.
- Clique no botão azul `Add new`.
- Selecione o arquivo JAR do desktop.
- Clique sobre o objeto enviado e selecione o botão `Submit`.


## 7 - Verifique se o Job está executando corretamente

Na aba `Jobs \ Running Jobs` verifique se seu Job está apresentando o estado `Azul` (o estado `Vermelho` deve desaparecer em poucos segundos).


## 8 - Gere mais dados pelo Python

Volte ao terminal e execute novamente nosso programa `main.py`

Na pasta `python` executar a geração dos dados com o comando:
```bash
python3 .\main.py
```

## 9 - Valide

Abra o PostgreSQL e verifique se as tabelas `transactions` e `sales_per_category` foram criadas, e se seus dados foram recebidos.

---

**Parabéns**!! Você acabou de concluir o seu pipeline de processamento de dados em tempo real usando a plataforma Flink no docker-compose!