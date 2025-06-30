#!/bin/bash
set -e

# This script sets up the environment and then executes the command passed to the container.

# 1. Build the classpath with only the required external libraries.
# Spark will automatically pick up JARs from /opt/spark/jars,
# so we only need to add the Hadoop and Hive libraries.
HADOOP_JARS=$(find ${HADOOP_HOME}/share/hadoop -name "*.jar" | paste -sd ":" -)
HIVE_JARS=$(find ${HIVE_HOME}/lib -name "*.jar" | paste -sd ":" -)

# 2. Export SPARK_CLASSPATH. Spark launch scripts will automatically prepend this to the JVM's classpath.
# This is the canonical way to add custom libraries to Spark's environment.
export SPARK_CLASSPATH="${HADOOP_JARS}:${HIVE_JARS}"

# 3. Execute the command provided to the container (e.g., the 'command' from docker-compose.yml)
# 'exec' replaces this script with the process of the new command, which is a container best practice.
exec "$@"