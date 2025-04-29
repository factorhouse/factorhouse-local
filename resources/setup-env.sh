#!/usr/bin/env bash

### Determine absolute paths for kpow/flex resources
SCRIPT_PATH="$(cd $(dirname "$0"); pwd)"
KPOW_RESOURCES_PATH=$SCRIPT_PATH/kpow
FLEX_RESOURCES_PATH=$SCRIPT_PATH/flex

#### Remove existing paths
rm -rf $KPOW_RESOURCES_PATH/connect \
  && rm -rf $FLEX_RESOURCES_PATH/jar

####
#### Download Kafka connectors
####
mkdir $KPOW_RESOURCES_PATH/connect

echo "downloading kafka connectors ..."
curl --silent -o $KPOW_RESOURCES_PATH/connect/confluent.zip \
  https://hub-downloads.confluent.io/api/plugins/confluentinc/kafka-connect-s3/versions/10.6.5/confluentinc-kafka-connect-s3-10.6.5.zip \
  && unzip -qq $KPOW_RESOURCES_PATH/connect/confluent.zip -d $KPOW_RESOURCES_PATH/connect \
  && mv $KPOW_RESOURCES_PATH/connect/confluentinc-kafka-connect-s3-10.6.5/lib $KPOW_RESOURCES_PATH/connect/confluent-s3 \
  && rm $KPOW_RESOURCES_PATH/connect/confluent.zip \
  && rm -rf $KPOW_RESOURCES_PATH/connect/confluentinc-kafka-connect-s3-10.6.5

curl --silent -o $KPOW_RESOURCES_PATH/connect/debezium-connector-postgres.tar.gz \
  https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/3.1.1.Final/debezium-connector-postgres-3.1.1.Final-plugin.tar.gz \
  && tar -xzf $KPOW_RESOURCES_PATH/connect/debezium-connector-postgres.tar.gz -C $KPOW_RESOURCES_PATH/connect \
  && rm $KPOW_RESOURCES_PATH/connect/debezium-connector-postgres.tar.gz

mkdir -p $KPOW_RESOURCES_PATH/connect/msk-datagen
curl --silent -L -o $KPOW_RESOURCES_PATH/connect/msk-datagen/msk-data-generator.jar \
  https://github.com/awslabs/amazon-msk-data-generator/releases/download/v0.4.0/msk-data-generator-0.4-jar-with-dependencies.jar

####
#### Download Flink jar files
####
## Flink connectors
FLINK_CONNECTOR_PATH=$FLEX_RESOURCES_PATH/jar/connector
mkdir -p $FLINK_CONNECTOR_PATH

echo "downloading flink connectors ..."
curl --silent -o ${FLINK_CONNECTOR_PATH}/flink-sql-connector-kafka-3.3.0-1.20.jar \
  https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-connector-kafka/3.3.0-1.20/flink-sql-connector-kafka-3.3.0-1.20.jar
curl --silent -L -o ${FLINK_CONNECTOR_PATH}/flink-faker-0.5.3.jar \
  https://github.com/knaufk/flink-faker/releases/download/v0.5.3/flink-faker-0.5.3.jar

## Flink parquet dependencies
FLINK_PARQUET_DEPENDENCY_PATH=$FLEX_RESOURCES_PATH/jar/parquet
mkdir -p $FLINK_PARQUET_DEPENDENCY_PATH

## Flink parquet dependencies
echo "downloading flink sql dependencies for parquet format ..."
curl --silent -o ${FLINK_PARQUET_DEPENDENCY_PATH}/flink-sql-parquet-1.20.1.jar \
  https://repo1.maven.org/maven2/org/apache/flink/flink-sql-parquet/1.20.1/flink-sql-parquet-1.20.1.jar
curl --silent -o ${FLINK_PARQUET_DEPENDENCY_PATH}/hadoop-common-3.4.1.jar \
  https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-common/3.4.1/hadoop-common-3.4.1.jar
curl --silent -o ${FLINK_PARQUET_DEPENDENCY_PATH}/hadoop-mapreduce-client-core-3.4.1.jar \
  https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-mapreduce-client-core/3.4.1/hadoop-mapreduce-client-core-3.4.1.jar

## Flink iceberg dependencies
FLINK_ICEBERG_DEPENDENCY_PATH=$FLEX_RESOURCES_PATH/jar/iceberg
mkdir -p $FLINK_ICEBERG_DEPENDENCY_PATH

echo "downloading flink sql dependencies for iceberg format ..."
curl --silent -o ${FLINK_ICEBERG_DEPENDENCY_PATH}/iceberg-flink-runtime-1.20-1.8.1.jar \
  https://repo.maven.apache.org/maven2/org/apache/iceberg/iceberg-flink-runtime/1.20-1.8.1/iceberg-flink-runtime-1.20-1.8.1.jar
curl --silent -o ${FLINK_ICEBERG_DEPENDENCY_PATH}/iceberg-aws-bundle-1.8.1.jar \
  https://repo.maven.apache.org/maven2/org/apache/iceberg/iceberg-aws-bundle/1.8.1/iceberg-aws-bundle-1.8.1.jar
curl --silent -o ${FLINK_ICEBERG_DEPENDENCY_PATH}/iceberg-core-1.8.1.jar \
  https://repo.maven.apache.org/maven2/org/apache/iceberg/iceberg-core/1.8.1/iceberg-core-1.8.1.jar
curl --silent -o ${FLINK_ICEBERG_DEPENDENCY_PATH}/iceberg-s3-1.8.1.jar \
  https://repo.maven.apache.org/maven2/org/apache/iceberg/iceberg-s3/1.8.1/iceberg-s3-1.8.1.jar
curl --silent -o ${FLINK_ICEBERG_DEPENDENCY_PATH}/hadoop-aws-3.3.0.jar \
  https://repo.maven.apache.org/maven2/org/apache/hadoop/hadoop-aws/3.3.0/hadoop-aws-3.3.0.jar
curl --silent -o ${FLINK_ICEBERG_DEPENDENCY_PATH}/aws-java-sdk-s3-1.12.100.jar \
  https://repo.maven.apache.org/maven2/com/amazonaws/aws-java-sdk-s3/1.12.100/aws-java-sdk-s3-1.12.100.jar

####
#### Build a custom Flink image for PyFlink
####
FLINK_DOCKER_FILE_PATH=$FLEX_RESOURCES_PATH/docker/Dockerfile

echo "building a custom docker image (factorhouse/flink) for PyFlink support ..."
docker build --quiet -f $FLINK_DOCKER_FILE_PATH -t factorhouse/flink .
