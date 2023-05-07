FROM confluentinc/cp-kafka-connect-base:7.0.0

RUN confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:10.4.1 \
    && confluent-hub install --no-prompt confluentinc/kafka-connect-s3:10.0.7