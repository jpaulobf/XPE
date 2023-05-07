## Introduction to Kafka on Docker :whale:

```sh
# start services
docker-compose up -d

# get name brocker
docker-compose ps

# access container broker
CONTAINER_NAME=multinode_kafka-1_1
docker exec -it $CONTAINER_NAME bash

# declare variables on container
BOOTSTRAP_SERVER=localhost:19092
TOPIC=topico
GROUP=grupo

# create topic with kafka cli
kafka-topics --create --bootstrap-server $BOOTSTRAP_SERVER \
--replication-factor 3 \
--partitions 3 \
--topic $TOPIC

# list topics after created
kafka-topics --list --bootstrap-server $BOOTSTRAP_SERVER

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