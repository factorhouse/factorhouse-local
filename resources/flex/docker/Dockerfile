# Use the official multi-arch Flink image
FROM flink:1.20.1

# TARGETARCH is automatically provided by Docker buildx.
# It will be 'amd64', 'arm64', etc.
ARG TARGETARCH

# Set Java Version and base URL
ENV JAVA_VERSION=17.0.11_9
ENV TEMURIN_CHECKSUM_amd64="ebe9927148a85912d63115797d6ffc88a0c48540536e616cc8c2875b953e43a5"
ENV TEMURIN_CHECKSUM_arm64="962fc31a4069d1b02b7819010d09b3438b4f1356921d60fcfd6c4fb672114c80"

# Install prerequisites:
# - Python 3, pip, and dev headers
# - curl for potential downloads
# - build-essential: Needed for compiling Python packages from source (like apache-flink on arm64)
# Combine steps to reduce layers and clean up in the same layer
RUN apt-get update -y \
  && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-dev \
    curl \
    build-essential \
  # Create python symlink if needed
  && ln -s /usr/bin/python3 /usr/bin/python \
  # Clean up apt cache
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Download and install Temurin JDK
RUN set -eux; \
    # Map Docker's TARGETARCH to Temurin's arch names
    case "$TARGETARCH" in \
        'amd64') \
            TEMURIN_ARCH='x64'; \
            TEMURIN_CHECKSUM="$TEMURIN_CHECKSUM_amd64"; \
            ;; \
        'arm64') \
            TEMURIN_ARCH='aarch64'; \
            TEMURIN_CHECKSUM="$TEMURIN_CHECKSUM_arm64"; \
            ;; \
        *) \
            echo "Unsupported architecture: $TARGETARCH"; \
            exit 1; \
            ;; \
    esac; \
    \
    # Construct download URL
    TEMURIN_URL="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-${JAVA_VERSION}/OpenJDK17U-jdk_${TEMURIN_ARCH}_linux_hotspot_${JAVA_VERSION//_/-}.tar.gz"; \
    \
    # Download, verify checksum, and extract
    echo "Downloading Temurin JDK from $TEMURIN_URL"; \
    curl -fL -o /tmp/openjdk.tar.gz "$TEMURIN_URL"; \
    echo "$TEMURIN_CHECKSUM /tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/java; \
    tar -xzf /tmp/openjdk.tar.gz -C /opt/java --strip-components=1; \
    rm /tmp/openjdk.tar.gz; \
    \
    # Verify java command exists
    ls -l /opt/java/bin/java; \
    /opt/java/bin/java -version

# Set JAVA_HOME and update PATH *after* installation
# This ensures the new Java is used by default
ENV JAVA_HOME=/opt/java
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Install PyFlink using pip
RUN pip3 install --no-cache-dir apache-flink==1.20.1

# Verify installations
RUN echo "Java Version (Temurin):" && java -version \
  && echo "JAVA_HOME:" && echo $JAVA_HOME \
  && echo "Python Version:" && python --version \
  && echo "Pip Version:" && pip --version \
  && echo "PyFlink Location:" && python -m pip show apache-flink

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
