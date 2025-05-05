FROM flink:1.20.1

# Install Python, pip, and JDK 17 headers (required for arm64)
RUN apt-get update -y \
  && apt-get install -y \
     python3 python3-pip python3-dev \
     openjdk-17-jdk-headless \
  && ln -s /usr/bin/python3 /usr/bin/python \
  && rm -rf /var/lib/apt/lists/*

## install PyFlink
RUN pip3 install apache-flink==1.20.1

## copy s3 file system plugins plugins
RUN mkdir /opt/flink/plugins/s3-fs-hadoop \
  && cp /opt/flink/opt/flink-s3-fs-hadoop-1.20.1.jar /opt/flink/plugins/s3-fs-hadoop \
  && mkdir /opt/flink/plugins/s3-fs-presto \
  && cp /opt/flink/opt/flink-s3-fs-presto-1.20.1.jar /opt/flink/plugins/s3-fs-presto

## copy custom flink binaries
COPY config.sh flink-console.sh flink-daemon.sh sql-client.sh /opt/flink/bin/

## copy hadoop config
COPY core-site.xml /opt/hadoop/etc/hadoop/core-site.xml

## download hadoop, iceberg and parquet dependencies
RUN mkdir /tmp/hadoop && mkdir /tmp/iceberg && mkdir /tmp/parquet \
  && curl --silent -o /tmp/hadoop/hadoop-common-3.3.6.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-common/3.3.6/hadoop-common-3.3.6.jar \
  && curl --silent -o /tmp/hadoop/hadoop-mapreduce-client-core-3.3.6.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-mapreduce-client-core/3.3.6/hadoop-mapreduce-client-core-3.3.6.jar \
  && curl --silent -o /tmp/hadoop/hadoop-hdfs-client-3.3.6.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-hdfs-client/3.3.6/hadoop-hdfs-client-3.3.6.jar \
  && curl --silent -o /tmp/hadoop/hadoop-auth-3.3.6.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-auth/3.3.6/hadoop-auth-3.3.6.jar \
  && curl --silent -o /tmp/hadoop/woodstox-core-6.5.1.jar https://repo1.maven.org/maven2/com/fasterxml/woodstox/woodstox-core/6.5.1/woodstox-core-6.5.1.jar \
  && curl --silent -o /tmp/hadoop/stax2-api-4.2.1.jar https://repo1.maven.org/maven2/org/codehaus/woodstox/stax2-api/4.2.1/stax2-api-4.2.1.jar \
  && curl --silent -o /tmp/hadoop/commons-configuration2-2.8.0.jar https://repo1.maven.org/maven2/org/apache/commons/commons-configuration2/2.8.0/commons-configuration2-2.8.0.jar \
  && curl --silent -o /tmp/hadoop/hadoop-shaded-guava-1.1.1.jar https://repo1.maven.org/maven2/org/apache/hadoop/thirdparty/hadoop-shaded-guava/1.1.1/hadoop-shaded-guava-1.1.1.jar \
  && curl --silent -o /tmp/hadoop/hadoop-aws-3.3.6.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.6/hadoop-aws-3.3.6.jar \
  && curl --silent -o /tmp/hadoop/aws-java-sdk-bundle-1.11.1026.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.1026/aws-java-sdk-bundle-1.11.1026.jar \
  && curl --silent -o /tmp/iceberg/iceberg-flink-runtime-1.20-1.8.1.jar https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-flink-runtime-1.20/1.8.1/iceberg-flink-runtime-1.20-1.8.1.jar \
  && curl --silent -o /tmp/iceberg/iceberg-aws-bundle-1.8.1.jar https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-aws-bundle/1.8.1/iceberg-aws-bundle-1.8.1.jar \
  && curl --silent -o /tmp/parquet/flink-sql-parquet-1.20.1.jar https://repo1.maven.org/maven2/org/apache/flink/flink-sql-parquet/1.20.1/flink-sql-parquet-1.20.1.jar
