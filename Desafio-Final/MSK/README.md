# Bootcamp EDD - M4 - MSK

Pré-requisitos:

- Conta na AWS
- Se logar na AWS

## 1 - Criar uma nova 

    Criar a VPC - com CIDR - 10.0.0.0/16

## 2 - Criar 2 subnets A e B

    A : 10.0.0.0/24
    B: 10.0.1.0/24

## 3 - Ajustar a tabela de Roteamento

    Adicionar as Subnets A e B na Route Table

## 4 - Criar o Internet Gateway

    Criar um IGW com qualquer nome

## 5 - Adicionar o IGW a Route Table

    Associar o IGW com a Route Table

## 6 - Criar o Cluster MVK na rede estabelecida

    Selecionar "unauthorized access allowed"
    Selecionar "plain text encryption"

## 7 - Criar as Máquinas EC2

    - Escolher a Rede previamente criada
    - Escolher o Auto-assign Public IP

## 8 - Configurar o Security Group
    
    - do EC2 para o MSK
    - do MSK para a EC2

## 9 - Instalar o Java e o Kafka Client

```bash
sudo yum install java-17-amazon-corretto

wget https://archive.apache.org/dist/kafka/3.5.1/kafka_2.12-3.5.1.tgz

tar -xvf kafka_2.12-3.5.1.tgz

cd kafka_2.12-3.5.1
```

## 10 - Criar o tópico

    - Verificar o bootstrap-server no "View Client Information"

```bash
cd bin
./kafka-topics.sh --create --topic demo_topic --bootstrap-server b-1.myclusterkafka01.mjat97.c21.kafka.us-east-1.amazonaws.com:9092,b-3.myclusterkafka01.mjat97.c21.kafka.us-east-1.amazonaws.com:9092,b-2.myclusterkafka01.mjat97.c21.kafka.us-east-1.amazonaws.com:9092 --replication-factor 3 --partitions 1

./kafka-topics.sh --list --bootstrap-server b-1.myclusterkafka01.mjat97.c21.kafka.us-east-1.amazonaws.com:9092,b-3.myclusterkafka01.mjat97.c21.kafka.us-east-1.amazonaws.com:9092,b-2.myclusterkafka01.mjat97.c21.kafka.us-east-1.amazonaws.com:9092
```


## 11 - Criar o Console Producer

    - Verificar o bootstrap-server no "View Client Information"

```bash
./kafka-console-producer.sh --topic demo_topic --bootstrap-server b-1.myclusterkafka01.mjat97.c21.kafka.us-east-1.amazonaws.com:9092,b-3.myclusterkafka01.mjat97.c21.kafka.us-east-1.amazonaws.com:9092,b-2.myclusterkafka01.mjat97.c21.kafka.us-east-1.amazonaws.com:9092
```

## 12 - Criar o Console Consumer

    - Verificar o bootstrap-server no "View Client Information"

```bash
./kafka-console-consumer.sh --topic demo_topic --bootstrap-server b-1.myclusterkafka01.mjat97.c21.kafka.us-east-1.amazonaws.com:9092,b-3.myclusterkafka01.mjat97.c21.kafka.us-east-1.amazonaws.com:9092,b-2.myclusterkafka01.mjat97.c21.kafka.us-east-1.amazonaws.com:9092 --from-beginning
```

## 13 - Instalando a interface de API Rest

```bash
wget http://packages.confluent.io/archive/5.1/confluent-5.1.2-2.11.zip
unzip confluent-5.1.2-2.11.zip
cd confluent-5.1.2

export CONFLUENT_HOME=/home/ec2-user/confluent-5.1.2
export PATH=$PATH:$CONFLUENT_HOME/bin

cd etc/kafka-rest/

nano kafka-rest.properties

PLAINTEXT://b-2.myclusterkafka01.mjat97.c21.kafka.us-east-1.amazonaws.com:9092,PLAINTEXT://b-1.myclusterkafka01.mjat97.c21.kafka.us-east-1.amazonaws.com:9092,PLAINTEXT://b-3.myclusterkafka01.mjat97.c21.kafka.us-east-1.amazonaws.com:9092
```

## 14 - Liberar a porta 8082 no Security Group da Instância

    TCP - 8082 - Any 0.0.0.0/0

## 15 - Iniciar a API Rest:

```bash
/home/ec2-user/confluent-5.1.2/bin/kafka-rest-start /home/ec2-user/confluent-5.1.2/etc/kafka-rest/kafka-rest.properties
```

## 16 - Testar a API:

    - http://18.206.205.232:8082/topics/demo_topic_2

## 17 - Postman:

```
Headers:
Content-Type: application/vnd.kafka.json.v2+json
```

```
{"records":[{"value":{"name": "testUser"}}]}
```

```
{"records":[
    {
        "key":"1",
        "value":{
            "id":"1",
            "customer_code": "22",
            "telephone":"666555444",
            "email":"email@email.com",
            "language":"pt"
        }
    }
    ]
}
```

```
{"records":[
    {
        "key":"2",
        "value":{
            "id":"2",
            "customer_code": "111",
            "telephone":"888444222",
            "email":"email2@email.com",
            "language":"pt"
        }
    },
    {
        "key":"3",
        "value":{
            "id":"3",
            "customer_code": "333",
            "telephone":"555444111",
            "email":"email3@email.com",
            "language":"pt"
        }
    }
    ]
}
```