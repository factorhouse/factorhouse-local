FROM flink:1.20.1

# TARGETARCH is automatically provided by Docker buildx.
# - 'amd64', 'arm64', etc.
ARG TARGETARCH

# Set correct Temurin JDK 11 download URL based on arch
ENV TEMURIN_BASE_URL=https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.27%2B6
ENV TEMURIN_JDK_AMD64=OpenJDK11U-jdk_x64_linux_hotspot_11.0.27_6.tar.gz
ENV TEMURIN_JDK_AMD64_CHECKSUM=dc6136eaa8c1898cbf8973bb1e203e1f653f4c9166be0f5bebe0b02c5f3b5ae3
ENV TEMURIN_JDK_ARM64=OpenJDK11U-jdk_aarch64_linux_hotspot_11.0.27_6.tar.gz
ENV TEMURIN_JDK_ARM64_CHECKSUM=4decd2e5caf4667144091cf723458b14148dc990730b3ecb34bba5eb1aa4ad5d


# Install dependencies and Python tools
RUN apt-get update -y \
  && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-dev \
    curl \
    build-essential \
    ca-certificates \
  && ln -s /usr/bin/python3 /usr/bin/python \
  # Download and extract the appropriate JDK with checksum verification
  && mkdir -p /opt/java \
  && JDK_FILE=$(if [ "$TARGETARCH" = "arm64" ]; then echo "$TEMURIN_JDK_ARM64"; else echo "$TEMURIN_JDK_AMD64"; fi) \
  && CHECKSUM=$(if [ "$TARGETARCH" = "arm64" ]; then echo "$TEMURIN_JDK_ARM64_CHECKSUM"; else echo "$TEMURIN_JDK_AMD64_CHECKSUM"; fi) \
  && curl -fsSL "${TEMURIN_BASE_URL}/${JDK_FILE}" -o /tmp/openjdk.tar.gz \
  && echo "${CHECKSUM}  /tmp/openjdk.tar.gz" | sha256sum -c - \
  && tar -xz -C /opt/java --strip-components=1 -f /tmp/openjdk.tar.gz \
  && rm -f /tmp/openjdk.tar.gz \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME and update PATH
ENV JAVA_HOME=/opt/java
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Install PyFlink
RUN pip3 install --no-cache-dir apache-flink==1.20.1

# Verify setup
RUN echo "--- Verify installations ---" && \
    echo "Java Version:" && java -version && \
    echo "Python Version:" && python --version && \
    echo "PyFlink Location:" && python -m pip show apache-flink && \
    echo "JAVA_HOME resolved to: $JAVA_HOME" && \
    ls -la "$JAVA_HOME/include" && \
    echo "------"

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
  && curl --silent -o /tmp/hadoop/flink-sql-connector-hive-3.1.2_2.12-1.16.3.jar https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-hive-3.1.2_2.12/1.16.3/flink-sql-connector-hive-3.1.2_2.12-1.16.3.jar \
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
