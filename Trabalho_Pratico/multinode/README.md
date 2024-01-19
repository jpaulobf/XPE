## Introduction to Kafka on Docker :whale:

1) Baixar o Repositório
2) Instalar o Docker (completo)
3) Entrar na Pasta Multinode pelo Shell (Windows ou Linux) e inicializar o ambiente com o seguinte comando:

```sh
# start services
docker-compose up -d
```

4) Após o download, provisão e instalação de tudo, consulte o ambiente com o comando:

```sh
# get name brocker
docker-compose ps

```

5) Os logs podem ser vistos com o comando:

```sh

#ver os logs dos clusters
docker logs -f multinode_kafka-1_1

```

6) Entre no Container do Kafka:

```sh

# access container broker
CONTAINER_NAME=multinode_kafka-1_1
docker exec -it $CONTAINER_NAME bash

```

7) Crie estas variáveis de ambiente:

```sh

# declare variables on container
BOOTSTRAP_SERVER=localhost:19092
TOPIC=topico
GROUP=grupo

```

8) Crie os Tópicos do Kafka (serão 3 partições e 3 réplicas):

```sh

# create topic with kafka cli
kafka-topics --create --bootstrap-server $BOOTSTRAP_SERVER \
--replication-factor 3 \
--partitions 3 \
--topic $TOPIC

```

9) Use o comando abaixo para listar os tópicos:

```sh

# list topics after created
kafka-topics --list --bootstrap-server $BOOTSTRAP_SERVER


```

10) ...:

```sh

# configs about topic
kafka-topics --bootstrap-server $BOOTSTRAP_SERVER \
--describe \
--topic $TOPIC

# create producer
kafka-console-producer --broker-list $BOOTSTRAP_SERVER \
--topic $TOPIC

# send message to topic
abc
def
ghi
jkl
mno
pqr
stu
vwx
yza

kafka-console-consumer --bootstrap-server $BOOTSTRAP_SERVER \
--topic $TOPIC \
--from-beginning

# read topic and partitions
kafka-console-consumer --bootstrap-server $BOOTSTRAP_SERVER \
--topic $TOPIC \
--group $GROUP

# read topic from beginning
kafka-console-consumer --bootstrap-server $BOOTSTRAP_SERVER \
--topic $TOPIC \
--from-beginning

# stop services
docker-compose down
```
