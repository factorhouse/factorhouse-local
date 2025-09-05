#!/usr/bin/env bash

progress_bar() {
  local progress=$((CURRENT_STEP * 100 / TOTAL_STEPS))
  local done=$((progress / 2))
  local left=$((50 - done))
  local fill=$(printf "%${done}s")
  local empty=$(printf "%${left}s")
  echo -ne "\r⏳ Progress : [${fill// /#}${empty// /-}] ${progress}%"
}

flag_time_taken() {
  local end_time=$(date +%s)
  local elapsed=$((end_time - START_TIME))
  local minutes=$((elapsed / 60))
  local seconds=$((elapsed % 60))
  echo ""
  echo "✅ Download complete in ${minutes}m ${seconds}s!"
}

### Determine absolute paths for kafka/flink connectors
SCRIPT_PATH="$(cd $(dirname "$0"); pwd)"
JAR_PATH=$SCRIPT_PATH/deps

#### Recreate necessary paths
rm -rf $JAR_PATH \
  && mkdir -p $JAR_PATH/flink/connector -p $JAR_PATH/flink/hive \
    -p $JAR_PATH/flink/iceberg -p $JAR_PATH/flink/parquet \
    -p $JAR_PATH/hadoop -p $JAR_PATH/hms -p $JAR_PATH/kafka/connector \
    -p $JAR_PATH/spark/iceberg -p $JAR_PATH/spark/lineage

####
#### Kafka connectors
####
echo "▶️  Downloading Kafka connectors..."

START_TIME=$(date +%s)
TOTAL_STEPS=4
CURRENT_STEP=0

KAFKA_CONNECTOR_PATH=$JAR_PATH/kafka/connector

curl --silent -o $KAFKA_CONNECTOR_PATH/confluent.zip \
  https://hub-downloads.confluent.io/api/plugins/confluentinc/kafka-connect-s3/versions/10.6.5/confluentinc-kafka-connect-s3-10.6.5.zip \
  && unzip -qq $KAFKA_CONNECTOR_PATH/confluent.zip -d $KAFKA_CONNECTOR_PATH \
  && mv $KAFKA_CONNECTOR_PATH/confluentinc-kafka-connect-s3-10.6.5/lib $KAFKA_CONNECTOR_PATH/confluent-s3 \
  && rm $KAFKA_CONNECTOR_PATH/confluent.zip \
  && rm -rf $KAFKA_CONNECTOR_PATH/confluentinc-kafka-connect-s3-10.6.5
((CURRENT_STEP++)); progress_bar

curl --silent -o $KAFKA_CONNECTOR_PATH/debezium-connector-postgres.tar.gz \
  https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/3.1.1.Final/debezium-connector-postgres-3.1.1.Final-plugin.tar.gz \
  && tar -xzf $KAFKA_CONNECTOR_PATH/debezium-connector-postgres.tar.gz -C $KAFKA_CONNECTOR_PATH \
  && rm $KAFKA_CONNECTOR_PATH/debezium-connector-postgres.tar.gz
((CURRENT_STEP++)); progress_bar

mkdir -p $KAFKA_CONNECTOR_PATH/msk-datagen
curl --silent -L -o $KAFKA_CONNECTOR_PATH/msk-datagen/msk-data-generator.jar \
  https://github.com/awslabs/amazon-msk-data-generator/releases/download/v0.4.0/msk-data-generator-0.4-jar-with-dependencies.jar
((CURRENT_STEP++)); progress_bar

curl --silent -L -o $KAFKA_CONNECTOR_PATH/iceberg.zip \
  https://github.com/databricks/iceberg-kafka-connect/releases/download/v0.6.19/iceberg-kafka-connect-runtime-hive-0.6.19.zip \
  && unzip -qq $KAFKA_CONNECTOR_PATH/iceberg.zip -d $KAFKA_CONNECTOR_PATH \
  && mv $KAFKA_CONNECTOR_PATH/iceberg-kafka-connect-runtime-hive-0.6.19/lib $KAFKA_CONNECTOR_PATH/iceberg \
  && rm $KAFKA_CONNECTOR_PATH/iceberg.zip \
  && rm -rf $KAFKA_CONNECTOR_PATH/iceberg-kafka-connect-runtime-hive-0.6.19
((CURRENT_STEP++)); progress_bar

flag_time_taken

####
#### Flink connectors
####
echo ""
echo "▶️  Downloading Flink connectors..."

START_TIME=$(date +%s)
TOTAL_STEPS=3
CURRENT_STEP=0

FLINK_CONNECTOR_PATH=$JAR_PATH/flink/connector

curl --silent -o $FLINK_CONNECTOR_PATH/flink-sql-connector-kafka-3.3.0-1.20.jar \
  https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-connector-kafka/3.3.0-1.20/flink-sql-connector-kafka-3.3.0-1.20.jar
((CURRENT_STEP++)); progress_bar

curl --silent -o $FLINK_CONNECTOR_PATH/flink-sql-avro-confluent-registry-1.20.1.jar \
  https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-avro-confluent-registry/1.20.1/flink-sql-avro-confluent-registry-1.20.1.jar
((CURRENT_STEP++)); progress_bar

curl --silent -L -o $FLINK_CONNECTOR_PATH/flink-faker-0.5.3.jar \
  https://github.com/knaufk/flink-faker/releases/download/v0.5.3/flink-faker-0.5.3.jar
((CURRENT_STEP++)); progress_bar

flag_time_taken

####
#### Flink Hive dependencies
####
echo ""
echo "▶️  Downloading Flink Hive dependencies..."

START_TIME=$(date +%s)
TOTAL_STEPS=4
CURRENT_STEP=0

FLINK_HIVE_PATH=$JAR_PATH/flink/hive

curl --silent -L -o $FLINK_HIVE_PATH/antlr-runtime-3.5.2.jar \
  https://repo1.maven.org/maven2/org/antlr/antlr-runtime/3.5.2/antlr-runtime-3.5.2.jar
((CURRENT_STEP++)); progress_bar

curl --silent -L -o $FLINK_HIVE_PATH/flink-sql-connector-hive-3.1.3_2.12-1.20.1.jar \
  https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-connector-hive-3.1.3_2.12/1.20.1/flink-sql-connector-hive-3.1.3_2.12-1.20.1.jar
((CURRENT_STEP++)); progress_bar

curl --silent -L -o $FLINK_HIVE_PATH/hive-exec-3.1.0.jar \
  https://repo1.maven.org/maven2/org/apache/hive/hive-exec/3.1.0/hive-exec-3.1.0.jar
((CURRENT_STEP++)); progress_bar

curl --silent -L -o $FLINK_HIVE_PATH/libfb303-0.9.3.jar \
  https://repo1.maven.org/maven2/org/apache/thrift/libfb303/0.9.3/libfb303-0.9.3.jar
((CURRENT_STEP++)); progress_bar

flag_time_taken

####
#### Flink Iceberg/Parquet dependencies
####
echo ""
echo "▶️  Downloading Flink Iceberg/Parquet dependencies..."

START_TIME=$(date +%s)
TOTAL_STEPS=3
CURRENT_STEP=0

FLINK_ICEBERG_PATH=$JAR_PATH/flink/iceberg

curl --silent -o $FLINK_ICEBERG_PATH/iceberg-flink-runtime-1.20-1.8.1.jar \
  https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-flink-runtime-1.20/1.8.1/iceberg-flink-runtime-1.20-1.8.1.jar
((CURRENT_STEP++)); progress_bar

curl --silent -o $FLINK_ICEBERG_PATH/iceberg-aws-bundle-1.8.1.jar \
  https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-aws-bundle/1.8.1/iceberg-aws-bundle-1.8.1.jar
((CURRENT_STEP++)); progress_bar

FLINK_PARQUET_PATH=$JAR_PATH/flink/parquet

curl --silent -o $FLINK_PARQUET_PATH/flink-sql-parquet-1.20.1.jar \
  https://repo1.maven.org/maven2/org/apache/flink/flink-sql-parquet/1.20.1/flink-sql-parquet-1.20.1.jar
((CURRENT_STEP++)); progress_bar

flag_time_taken

####
#### Hadoop/Hive Metastore dependencies
####
echo ""
echo "▶️  Downloading Hadoop/Hive Metastore dependencies..."

START_TIME=$(date +%s)
TOTAL_STEPS=11
CURRENT_STEP=0

HADOOP_PATH=$JAR_PATH/hadoop

curl --silent -o $HADOOP_PATH/aws-java-sdk-bundle-1.11.1026.jar \
  https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.1026/aws-java-sdk-bundle-1.11.1026.jar
((CURRENT_STEP++)); progress_bar

curl --silent -o $HADOOP_PATH/commons-configuration2-2.8.0.jar \
  https://repo1.maven.org/maven2/org/apache/commons/commons-configuration2/2.8.0/commons-configuration2-2.8.0.jar
((CURRENT_STEP++)); progress_bar

curl --silent -o $HADOOP_PATH/hadoop-auth-3.3.6.jar \
  https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-auth/3.3.6/hadoop-auth-3.3.6.jar
((CURRENT_STEP++)); progress_bar

curl --silent -o $HADOOP_PATH/hadoop-aws-3.3.6.jar \
  https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.6/hadoop-aws-3.3.6.jar
((CURRENT_STEP++)); progress_bar

curl --silent -o $HADOOP_PATH/hadoop-common-3.3.6.jar \
  https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-common/3.3.6/hadoop-common-3.3.6.jar
((CURRENT_STEP++)); progress_bar

curl --silent -o $HADOOP_PATH/hadoop-hdfs-client-3.3.6.jar \
  https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-hdfs-client/3.3.6/hadoop-hdfs-client-3.3.6.jar
((CURRENT_STEP++)); progress_bar

curl --silent -o $HADOOP_PATH/hadoop-mapreduce-client-core-3.3.6.jar \
  https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-mapreduce-client-core/3.3.6/hadoop-mapreduce-client-core-3.3.6.jar
((CURRENT_STEP++)); progress_bar

curl --silent -o $HADOOP_PATH/hadoop-shaded-guava-1.1.1.jar \
  https://repo1.maven.org/maven2/org/apache/hadoop/thirdparty/hadoop-shaded-guava/1.1.1/hadoop-shaded-guava-1.1.1.jar
((CURRENT_STEP++)); progress_bar

curl --silent -o $HADOOP_PATH/stax2-api-4.2.1.jar \
  https://repo1.maven.org/maven2/org/codehaus/woodstox/stax2-api/4.2.1/stax2-api-4.2.1.jar
((CURRENT_STEP++)); progress_bar

curl --silent -o $HADOOP_PATH/woodstox-core-6.5.1.jar \
  https://repo1.maven.org/maven2/com/fasterxml/woodstox/woodstox-core/6.5.1/woodstox-core-6.5.1.jar
((CURRENT_STEP++)); progress_bar

HMS_PATH=$JAR_PATH/hms

curl --silent -o $HMS_PATH/postgresql-42.7.3.jar \
  https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.3/postgresql-42.7.3.jar
((CURRENT_STEP++)); progress_bar

flag_time_taken

####
#### Spark Iceberg/OpenLineage dependencies
####
echo ""
echo "▶️  Downloading Spark Iceberg/OpenLineage dependencies..."

START_TIME=$(date +%s)
TOTAL_STEPS=3
CURRENT_STEP=0

SPARK_ICEBERG_PATH=$JAR_PATH/spark/iceberg

curl --silent -o $SPARK_ICEBERG_PATH/iceberg-spark-runtime-3.5_2.12-1.8.1.jar \
  https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_2.12/1.8.1/iceberg-spark-runtime-3.5_2.12-1.8.1.jar
((CURRENT_STEP++)); progress_bar

curl --silent -o $SPARK_ICEBERG_PATH/iceberg-aws-bundle-1.8.1.jar \
  https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-aws-bundle/1.8.1/iceberg-aws-bundle-1.8.1.jar
((CURRENT_STEP++)); progress_bar

SPARK_LINEAGE_PATH=$JAR_PATH/spark/lineage

curl --silent -o $SPARK_LINEAGE_PATH/openlineage-spark_2.12-1.37.0.jar \
  https://repo1.maven.org/maven2/io/openlineage/openlineage-spark_2.12/1.37.0/openlineage-spark_2.12-1.37.0.jar
((CURRENT_STEP++)); progress_bar

flag_time_taken

echo ""