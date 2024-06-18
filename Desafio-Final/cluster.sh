#!/bin/bash

# Cores
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m' # No Color

# Função para exibir ajuda
show_help() {
    local color=$1
    echo -e "${color}Atenção: Uso: $0 [opções]"
    echo
    echo "Opções:"
    echo "  --build               Construir a imagem connect-custom:1.0.0"
    echo "  --restart             Reiniciar os serviços Docker (docker-compose down e docker-compose up)"
    echo "  --monitor-consume-ipca    Monitorar a saída do consumidor do tópico postgres-dadostesouroipca"
    echo "  --monitor-consume-pre     Monitorar a saída do consumidor do tópico postgres-dadostesouropre"
    echo "  --logs [--service <nome_do_servico>] Exibir os logs do cluster ou de um serviço específico"
    echo "  --down                Encerrar o cluster e apagar todos os dados"
    echo "  --stop                Parar o cluster sem apagar os dados"
    echo "  --ps                  Listar todos os containers em execução do cluster"
    echo "  --topics-list         Listar todos os tópicos do Kafka"
    echo "  --topic-describe      Descrever um tópico específico do Kafka"
    echo "  --get-offsets         Exibir offsets de um tópico específico"
    echo "  --topic-create        Criar um novo tópico no Kafka"
    echo "  --topic-delete        Deletar um tópico do Kafka"
    echo "  --connector-status    Verificar o status dos connectors"
    echo "  --connectors-list     Listar todos os connectors"
    echo "  --connector-restart   Reiniciar um connector específico"
    echo "  --s3-list-files       Listar os arquivos de um bucket e um caminho específico"
    echo "  --s3-list-buckets     Listar todos os buckets no S3"
    echo "  --s3-create-bucket    Criar um novo bucket no S3"
    echo "  --s3-delete-bucket    Excluir um bucket no S3"
    echo "  --help                Exibir esta ajuda e sair"
    echo
    echo "Exemplos:"
    echo "  ./cluster.sh --build --restart"
    echo "  ./cluster.sh --monitor-consume-ipca"
    echo "  ./cluster.sh --logs"
    echo "  ./cluster.sh --down"
    echo "  ./cluster.sh --stop"
    echo "  ./cluster.sh --ps"
    echo "  ./cluster.sh --topics-list"
    echo "  ./cluster.sh --topic-describe --topic nome_do_topico"
    echo "  ./cluster.sh --get-offsets --topic nome_do_topico"
    echo "  ./cluster.sh --topic-create --topic nome_do_topico"
    echo "  ./cluster.sh --topic-delete --topic nome_do_topico"
    echo "  ./cluster.sh --connector-status"
    echo "  ./cluster.sh --connectors-list"
    echo "  ./cluster.sh --connector-restart --connector nome_do_connector"
    echo "  ./cluster.sh --logs --service nome_do_servico"
    echo "  ./cluster.sh --s3-list-files --bucket nome_do_bucket --path caminho/do/diretorio"
    echo "  ./cluster.sh --s3-list-buckets"
    echo "  ./cluster.sh --s3-create-bucket --bucket nome_do_bucket"
    echo "  ./cluster.sh --s3-delete-bucket --bucket nome_do_bucket${NC}"
}

# Verificar se o jq está instalado
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Erro: jq não está instalado. Instale o jq e tente novamente.${NC}"
    exit 1
fi

# Verificar se o AWS CLI está instalado
if ! command -v aws &> /dev/null; then
    echo -e "${RED}Erro: AWS CLI não está instalado."
    echo -e "Para instalar, siga as instruções em: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html${NC}"
    exit 1
fi

# Verificar se o arquivo .env_kafka_connect existe, se não, copiar de .env_kafka_connect.sample
if [ ! -f .env_kafka_connect ]; then
    cp .env_kafka_connect.sample .env_kafka_connect
fi

# Verificar se a primeira linha do arquivo .env_kafka_connect é igual a AWS_ACCESS_KEY_ID=
if grep -q "^AWS_ACCESS_KEY_ID=$" .env_kafka_connect; then
    echo -e "${RED}Para rodar o cluster, faz-se necessário informar as chaves de sua conta AWS no arquivo .env_kafka_connect.${NC}"
    exit 1
fi

# Carregar as variáveis de ambiente do arquivo .env_kafka_connect
export $(grep -v '^#' .env_kafka_connect | xargs)

# Variáveis padrão
build_image=false
restart_services=false
monitor_consume_ipca=false
monitor_consume_pre=false
logs_cluster=false
down_cluster=false
stop_cluster=false
list_containers=false
list_topics=false
describe_topic=false
get_offsets=false
create_topic=false
delete_topic=false
status_connector=false
list_connectors=false
restart_connector=false
service_logs=false
s3_list_files=false
s3_list_buckets=false
s3_create_bucket=false
s3_delete_bucket=false

# Processar argumentos
if [ $# -eq 0 ]; then
    show_help "$YELLOW"
    exit 0
fi

while [ $# -gt 0 ]; do
    case "$1" in
        --build)
            build_image=true
            ;;
        --restart)
            restart_services=true
            ;;
        --monitor-consume-ipca)
            monitor_consume_ipca=true
            ;;
        --monitor-consume-pre)
            monitor_consume_pre=true
            ;;
        --logs)
            logs_cluster=true
            ;;
        --down)
            down_cluster=true
            ;;
        --stop)
            stop_cluster=true
            ;;
        --ps)
            list_containers=true
            ;;
        --topics-list)
            list_topics=true
            ;;
        --topic-describe)
            describe_topic=true
            ;;
        --get-offsets)
            get_offsets=true
            ;;
        --topic-create)
            create_topic=true
            ;;
        --topic-delete)
            delete_topic=true
            ;;
        --connector-status)
            status_connector=true
            ;;
        --connectors-list)
            list_connectors=true
            ;;
        --connector-restart)
            restart_connector=true
            ;;
        --s3-list-files)
            s3_list_files=true
            ;;
        --s3-list-buckets)
            s3_list_buckets=true
            ;;
        --s3-create-bucket)
            s3_create_bucket=true
            ;;
        --s3-delete-bucket)
            s3_delete_bucket=true
            ;;
        --service)
            service_name="$2"
            service_logs=true
            shift
            ;;
        --help)
            show_help "$NC"
            exit 0
            ;;
        --topic)
            topic_name="$2"
            shift
            ;;
        --connector)
            connector_name="$2"
            shift
            ;;
        --bucket)
            bucket_name="$2"
            shift
            ;;
        --path)
            bucket_path="$2"
            shift
            ;;
        *)
            echo "Opção inválida: $1"
            show_help "$NC"
            exit 1
            ;;
    esac
    shift
done

# Função para verificar se o serviço PostgreSQL está acessível
check_postgres() {
    echo
    echo "Verificando se o serviço PostgreSQL está acessível..."
    until docker-compose -f postgres/docker-compose.yaml exec -T postgres pg_isready; do
        printf '.'
        sleep 5
    done
    echo
    echo "Serviço PostgreSQL acessível."
}

# Parar e remover containers gerenciados pelo docker-compose, se necessário
if [ "$restart_services" = true ]; then
    echo
    echo "Reiniciando os serviços Docker..."
    docker-compose -f postgres/docker-compose.yaml down -v
    docker-compose down -v
fi

# Encerrar o cluster e apagar todos os dados
if [ "$down_cluster" = true ]; then
    echo
    echo "Encerrando o cluster e apagando todos os dados..."
    docker-compose -f postgres/docker-compose.yaml down -v
    docker-compose down -v
    echo "Cluster encerrado e todos os dados foram apagados."
    exit 0
fi

# Parar o cluster sem apagar os dados
if [ "$stop_cluster" = true ]; then
    echo
    echo "Parando o cluster sem apagar os dados..."
    docker-compose -f postgres/docker-compose.yaml down
    docker-compose down
    echo "Cluster parado sem apagar os dados."
    exit 0
fi

# Exibir logs do cluster, se necessário
if [ "$logs_cluster" = true ]; then
    echo
    if [ -n "$service_name" ]; then
        echo "Exibindo os logs do serviço: $service_name"
        if [ "$service_name" = "postgres" ]; then
            docker-compose -f postgres/docker-compose.yaml logs -f "$service_name"
        else
            docker-compose logs -f "$service_name"
        fi
    else
        echo "Exibindo os logs do cluster..."
        docker-compose logs -f
    fi
    exit 0
fi

# Comandos utilitários
if [ "$list_containers" = true ]; then
    echo
    echo "Listando todos os containers em execução do cluster..."
    docker-compose ps
    exit 0
fi

if [ "$list_topics" = true ]; then
    echo
    echo "Listando todos os tópicos do Kafka..."
    docker exec broker kafka-topics --bootstrap-server localhost:9092 --list
    exit 0
fi

if [ "$describe_topic" = true ]; then
    echo
    echo "Descrevendo o tópico: $topic_name"
    docker exec broker kafka-topics --bootstrap-server localhost:9092 --describe --topic "$topic_name"
    exit 0
fi

if [ "$get_offsets" = true ]; then
    echo
    echo "Exibindo offsets do tópico: $topic_name"
    docker exec broker kafka-run-class kafka.tools.GetOffsetShell --broker-list localhost:9092 --topic "$topic_name" --time -1
    exit 0
fi

if [ "$create_topic" = true ]; then
    echo
    echo "Criando tópico: $topic_name"
    docker exec broker kafka-topics --create --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1 --topic "$topic_name"
    exit 0
fi

if [ "$delete_topic" = true ]; then
    echo
    echo "Deletando tópico: $topic_name"
    docker exec broker kafka-topics --bootstrap-server localhost:9092 --delete --topic "$topic_name"
    exit 0
fi

if [ "$status_connector" = true ]; then
    echo
    echo "Verificando o status dos connectors..."
    curl -s localhost:8083/connectors | jq '.[]' | xargs -I {} curl -s localhost:8083/connectors/{}/status | jq
    exit 0
fi

if [ "$list_connectors" = true ]; then
    echo
    echo "Listando todos os connectors..."
    curl -s localhost:8083/connectors | jq
    exit 0
fi

if [ "$restart_connector" = true ]; then
    echo
    echo "Reiniciando o connector: $connector_name"
    curl -X POST localhost:8083/connectors/"$connector_name"/restart
    exit 0
fi

if [ "$s3_list_files" = true ]; then
    echo
    echo "Listando arquivos do bucket: $bucket_name, no caminho: $bucket_path"
    aws s3 ls "s3://$bucket_name/$bucket_path"
    exit 0
fi

if [ "$s3_list_buckets" = true ]; then
    echo
    echo "Listando todos os buckets..."
    aws s3 ls
    exit 0
fi

if [ "$s3_create_bucket" = true ]; then
    echo
    echo "Criando bucket: $bucket_name"
    aws s3 mb "s3://$bucket_name"
    exit 0
fi

if [ "$s3_delete_bucket" = true ]; then
    echo
    echo "Excluindo bucket: $bucket_name"
    aws s3 rb "s3://$bucket_name" --force
    exit 0
fi

# Build da imagem do kafka-connect, se necessário
if [ "$build_image" = true ]; then
    echo
    echo "Construindo a imagem connect-custom:1.0.0..."
    cd custom-kafka-connector-image
    docker buildx build . -t connect-custom:1.0.0
    cd ..
fi

# Verificar se os serviços estão rodando, se não, subir os serviços
if ! docker-compose ps | grep -q "Up"; then
    echo
    echo "Subindo os serviços Docker..."
    docker-compose -f postgres/docker-compose.yaml up -d
    check_postgres
    docker-compose up -d
fi

# Aguardar o container connect
echo
echo "Verificando se o serviço connectors está funcionando..."
until $(curl --output /dev/null --silent --head --fail http://localhost:8083/connectors); do
  printf '.'
  sleep 5
done
echo

# Criar tópicos no Kafka
echo
echo "Criando tópicos no Kafka..."
docker exec broker kafka-topics --create \
   --bootstrap-server localhost:9092 \
   --partitions 1 \
   --replication-factor 1 \
   --topic postgres-dadostesouroipca 2>&1 | tee >(cat >> error.log) || echo "Tópico postgres-dadostesouroipca já existe"

docker exec broker kafka-topics --create \
   --bootstrap-server localhost:9092 \
   --partitions 1 \
   --replication-factor 1 \
   --topic postgres-dadostesouropre 2>&1 | tee >(cat >> error.log) || echo "Tópico postgres-dadostesouropre já existe"

# Registrar os parâmetros de configuração do connector no Kafka
echo
echo "Registrando os parâmetros de configuração do connector no Kafka..."
curl -X POST -H "Content-Type: application/json" \
    --data @connectors/source/connect_jdbc_postgres.config localhost:8083/connectors || echo "Connector postg-connector-ipca já existe"

curl -X POST -H "Content-Type: application/json" \
    --data @connectors/source/connect_jdbc_postgres_pre.config localhost:8083/connectors || echo "Connector postg-connector-pre já existe"

# Executar consumidores em modo nohup
echo
echo "Executando consumidores em modo nohup..."
nohup docker exec broker kafka-console-consumer --bootstrap-server localhost:9092 \
--topic postgres-dadostesouroipca \
--from-beginning > nohup-postgres-dadostesouroipca.log 2>&1 &

nohup docker exec broker kafka-console-consumer --bootstrap-server localhost:9092 \
--topic postgres-dadostesouropre \
--from-beginning > nohup-postgres-dadostesouropre.log 2>&1 &

# Subir os sink connectors para entregar os dados ao S3
echo
echo "Subindo os sink connectors para entregar os dados ao S3..."
curl -X POST -H "Content-Type: application/json" \
    --data @connectors/sink/connect_s3_sink_ipca.config localhost:8083/connectors || echo "Connector sink-s3-ipca já existe"

curl -X POST -H "Content-Type: application/json" \
    --data @connectors/sink/connect_s3_sink_pre.config localhost:8083/connectors || echo "Connector sink-s3-pre já existe"

# Monitorar as saídas dos consumidores, se necessário
if [ "$monitor_consume_ipca" = true ]; then
    echo
    echo "Monitorando a saída do consumidor do tópico postgres-dadostesouroipca..."
    tail -f nohup-postgres-dadostesouroipca.log
fi

if [ "$monitor_consume_pre" = true ]; then
    echo
    echo "Monitorando a saída do consumidor do tópico postgres-dadostesouropre..."
    tail -f nohup-postgres-dadostesouropre.log
fi