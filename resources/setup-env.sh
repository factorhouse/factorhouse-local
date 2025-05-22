#!/usr/bin/env bash

### Determine absolute paths for kafka/flink connectors
SCRIPT_PATH="$(cd $(dirname "$0"); pwd)"
KAFKA_CONNECTOR_PATH=$SCRIPT_PATH/kpow/connector
FLINK_CONNECTOR_PATH=$SCRIPT_PATH/flex/connector

#### Recreate existing connector paths
rm -rf $KAFKA_CONNECTOR_PATH && rm -rf $FLINK_CONNECTOR_PATH
mkdir $KAFKA_CONNECTOR_PATH && mkdir $FLINK_CONNECTOR_PATH

####
#### Download Kafka connectors
####
echo "downloading kafka connectors ..."
curl --silent -o $KAFKA_CONNECTOR_PATH/confluent.zip \
  https://hub-downloads.confluent.io/api/plugins/confluentinc/kafka-connect-s3/versions/10.6.5/confluentinc-kafka-connect-s3-10.6.5.zip \
  && unzip -qq $KAFKA_CONNECTOR_PATH/confluent.zip -d $KAFKA_CONNECTOR_PATH \
  && mv $KAFKA_CONNECTOR_PATH/confluentinc-kafka-connect-s3-10.6.5/lib $KAFKA_CONNECTOR_PATH/confluent-s3 \
  && rm $KAFKA_CONNECTOR_PATH/confluent.zip \
  && rm -rf $KAFKA_CONNECTOR_PATH/confluentinc-kafka-connect-s3-10.6.5

curl --silent -o $KAFKA_CONNECTOR_PATH/debezium-connector-postgres.tar.gz \
  https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/3.1.1.Final/debezium-connector-postgres-3.1.1.Final-plugin.tar.gz \
  && tar -xzf $KAFKA_CONNECTOR_PATH/debezium-connector-postgres.tar.gz -C $KAFKA_CONNECTOR_PATH \
  && rm $KAFKA_CONNECTOR_PATH/debezium-connector-postgres.tar.gz

mkdir -p $KAFKA_CONNECTOR_PATH/msk-datagen
curl --silent -L -o $KAFKA_CONNECTOR_PATH/msk-datagen/msk-data-generator.jar \
  https://github.com/awslabs/amazon-msk-data-generator/releases/download/v0.4.0/msk-data-generator-0.4-jar-with-dependencies.jar

curl --silent -L -o $KAFKA_CONNECTOR_PATH/iceberg.zip \
  https://github.com/databricks/iceberg-kafka-connect/releases/download/v0.6.19/iceberg-kafka-connect-runtime-0.6.19.zip \
  && unzip -qq $KAFKA_CONNECTOR_PATH/iceberg.zip -d $KAFKA_CONNECTOR_PATH \
  && mv $KAFKA_CONNECTOR_PATH/iceberg-kafka-connect-runtime-0.6.19/lib $KAFKA_CONNECTOR_PATH/iceberg \
  && rm $KAFKA_CONNECTOR_PATH/iceberg.zip \
  && rm -rf $KAFKA_CONNECTOR_PATH/iceberg-kafka-connect-runtime-0.6.19

####
#### Download Flink connectors
####

echo "downloading flink connectors and format dependencies..."
curl --silent -o $FLINK_CONNECTOR_PATH/flink-sql-connector-kafka-3.3.0-1.20.jar \
  https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-connector-kafka/3.3.0-1.20/flink-sql-connector-kafka-3.3.0-1.20.jar

curl --silent -o $FLINK_CONNECTOR_PATH/flink-sql-avro-confluent-registry-1.20.1.jar \
  https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-avro-confluent-registry/1.20.1/flink-sql-avro-confluent-registry-1.20.1.jar

curl --silent -L -o $FLINK_CONNECTOR_PATH/flink-faker-0.5.3.jar \
  https://github.com/knaufk/flink-faker/releases/download/v0.5.3/flink-faker-0.5.3.jar
