FROM openjdk:17-jdk-slim

ARG SPARK_VERSION=3.5.5
ARG HADOOP_PROFILE=hadoop3
ARG SCALA_VERSION=2.12

ENV SPARK_HOME=/opt/spark
ENV PATH=$SPARK_HOME/bin:$PATH

# Install necessary packages and Spark with Hive support
RUN apt-get update && apt-get install -y curl bash tar sudo && \
    curl -fL "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-${HADOOP_PROFILE}-with-hive-scala${SCALA_VERSION}.tgz" \
    | tar -xz -C /opt && \
    mv /opt/spark-${SPARK_VERSION}-bin-${HADOOP_PROFILE}-with-hive-scala${SCALA_VERSION} $SPARK_HOME && \
    rm -rf /var/lib/apt/lists/*

# Create a spark user with sudo privileges
RUN useradd -ms /bin/bash spark && \
    echo "spark ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    chown -R spark:spark $SPARK_HOME

USER spark
WORKDIR /opt/spark/work-dir