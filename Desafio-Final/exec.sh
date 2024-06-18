#!/bin/bash
set -e #ativa para exibir todas as saídas
#set -v

# Função para exibir ajuda
show_help() {
    echo "Uso: $0 [opções]"
    echo
    echo "Opções:"
    echo "  --build           Construir a imagem connect-custom:1.0.0"
    echo "  --restart         Reiniciar os serviços Docker (docker-compose down e docker-compose up)"
    echo "  --consume-ipca    Consumir mensagens do tópico postgres-dadostesouroipca em modo nohup"
    echo "  --consume-pre     Consumir mensagens do tópico postgres-dadostesouropre em modo nohup"
    echo "  --help            Exibir esta ajuda e sair"
    echo
    echo "Exemplos:"
    echo "  $0 --build --restart"
    echo "  $0 --consume-ipca --consume-pre"
    echo "  $0 --build --restart --consume-ipca --consume-pre"
}

# Variáveis padrão
build_image=false
restart_services=false
run_consumer_ipca=false
run_consumer_pre=false,

# Cores
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Processar argumentos
while [ $# -gt 0 ]; do
    case "$1" in
        --build)
            build_image=true
            ;;
        --restart)
            restart_services=true
            ;;
        --consume-ipca)
            run_consumer_ipca=true
            ;;
        --consume-pre)
            run_consumer_pre=true
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo "Opção inválida: $1"
            show_help
            exit 1
            ;;
    esac
    shift
done

# Parar e remover containers gerenciados pelo docker-compose, se necessário
if [ "$restart_services" = true ]; then
    docker-compose down -v
fi

# Build da imagem do kafka-connect, se necessário
if [ "$build_image" = true ]; then
    cd custom-kafka-connector-image
    docker buildx build . -t connect-custom:1.0.0
    cd ..
fi

# Verificar se os serviços estão rodando, se não, subir os serviços
if ! docker-compose ps | grep -q "Up"; then
    docker-compose up -d
fi

# Aguardar o container connect
echo "Verificando se o serviço connectors está funcionando"
until $(curl --output /dev/null --silent --head --fail http://localhost:8083/connectors); do
  printf '.'
  sleep 5
done
echo

# Criar tópicos no Kafka
docker exec -ti broker kafka-topics --create \
   --bootstrap-server localhost:9092 \
   --partitions 1 \
   --replication-factor 1 \
   --topic postgres-dadostesouroipca 2>&1 | tee >(cat >> error_log)

docker exec -ti broker kafka-topics --create \
   --bootstrap-server localhost:9092 \
   --partitions 1 \
   --replication-factor 1 \
   --topic postgres-dadostesouropre 2>&1 | tee >(cat >> error_log)

# Registrar os parâmetros de configuração do connector no Kafka
curl -X POST -H "Content-Type: application/json" \
    --data @connectors/source/connect_jdbc_postgres.config localhost:8083/connectors

curl -X POST -H "Content-Type: application/json" \
    --data @connectors/source/connect_jdbc_postgres_pre.config localhost:8083/connectors

# Executar consumidores em modo nohup
# Os consumidores precisam ser iniciados explicitamente para ler e processar as mensagens dos tópicos.
# Isso é feito por meio de scripts ou aplicações que executam o consumidor Kafka.
# No nosso caso, o script que iniciamos os consumidores usando comandos kafka-console-consumer.

if [ "$run_consumer_ipca" = true ]; then
        nohup docker exec -ti broker kafka-console-consumer --bootstrap-server localhost:9092 \
        --topic postgres-dadostesouroipca \
        --from-beginning > nohup-postgres-dadostesouroipca.log 2>&1 &
        echo -e "${YELLOW}Consumo de mensagens do tópico postgres-dadostesouroipca iniciado."
        echo -e "Para monitorar a saída, use: tail -f nohup-postgres-dadostesouroipca.log${NC}"
fi

if [ "$run_consumer_pre" = true ]; then
      nohup docker exec -ti broker kafka-console-consumer --bootstrap-server localhost:9092 \
      --topic postgres-dadostesouropre \
      --from-beginning > nohup-postgres-dadostesouropre.log 2>&1 &
      echo -e "${YELLOW}Consumo de mensagens do tópico postgres-dadostesouropre iniciado."
      echo -e "Para monitorar a saída, use: tail -f nohup-postgres-dadostesouropre.${NC}"
fi

# Descrever os tópicos
docker exec -ti broker kafka-topics --bootstrap-server localhost:9092 \
--describe \
--topic postgres-dadostesouroipca

docker exec -ti broker kafka-topics --bootstrap-server localhost:9092 \
--describe \
--topic postgres-dadostesouropre

# Subir os sink connectors para entregar os dados ao S3
curl -X POST -H "Content-Type: application/json" \
    --data @connectors/sink/connect_s3_sink_ipca.config localhost:8083/connectors

curl -X POST -H "Content-Type: application/json" \
    --data @connectors/sink/connect_s3_sink_pre.config localhost:8083/connectors


# Função para verificar mensagens no tópico
#check_messages() {
#    local topic=$1
#    local count=$(docker exec -ti broker kafka-run-class kafka.tools.GetOffsetShell --broker-list localhost:9092 --topic $topic --time -1 | awk -F ':' '{sum += $3} END {print sum}')
#    echo $count
#}
#if [ $(check_messages "postgres-dadostesouroipca") -gt 0 ]; then
#    nohup docker exec -ti broker kafka-console-consumer --bootstrap-server localhost:9092 \
#    --topic postgres-dadostesouroipca \
#    --from-beginning > nohup-postgres-dadostesouroipca.log 2>&1 &
#    echo "Consumo de mensagens do tópico postgres-dadostesouroipca iniciado. Para monitorar a saída, use: tail -f nohup-postgres-dadostesouroipca.log"
#else
#    echo "Não há mensagens a serem consumidas no tópico postgres-dadostesouroipca"
#fi