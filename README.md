![factorhouse](./images/factorhouse.jfif)

# Factor House Local

![architecture](./images/factorhouse-local.png)

## Set up Environment

```bash
## set up environment
./resources/setup-env.sh

# downloading kafka connectors ...
# downloading flink connectors ...
# downloading iceberg flink runtime and iceberg aws bundle ...
# downloading s3 hadoop and presto plugins ...
# building a custom docker image (factorhouse/flink) for PyFlink support ...
# sha256:9941ebf0a422e8ffc52971da280866db20b7d4d684f14e29740a157d557bee34
```

## Start Resources

```bash
## Start Kpow, Flex and associated resources
##  - Kpow should be started first
##      because it creates the Docker network that is shared across all resources
##  - Set different project names to avoid the following warning
##      WARN[0002] Found orphan containers ([kpow-ee connect schema_registry kafka-2 kafka-1 kafka-3 zookeeper]) for this project.
docker compose -p kpow -f compose-kpow-trial.yml up -d \
  && docker compose -p flex -f compose-flex-trial.yml up -d \
  && docker compose -p analytics -f compose-analytics.yml up -d \
  && docker compose -p pinot -f compose-pinot.yml up -d

## Start individual services
##  - USE_EXT=false if not kpow
docker compose -f compose-kpow-trial.yml up -d
USE_EXT=false docker compose -f compose-flex-trial.yml up -d
USE_EXT=false docker compose -p analytics -f compose-analytics.yml up -d
# Pinot cannot be started on its own because it depends on the Zookeeper service in the Kpow stack
```

## Stop/Remove Resources

```bash
## Stop and remove Kpow, Flex and associated resources
##  - Kpow should be removed last because it contains the Docker network
##  - Ensure to use the same project names
docker compose -p pinot -f compose-pinot.yml down \
  && docker compose -p analytics -f compose-analytics.yml down \
  && docker compose -p flex -f compose-flex-trial.yml down \
  && docker compose -p kpow -f compose-kpow-trial.yml down

## Stop and remove Flex on its own by setting USE_EXT=false
docker compose -f compose-kpow-trial.yml down
USE_EXT=false docker compose -f compose-flex-trial.yml down
USE_EXT=false docker compose -p analytics -f compose-analytics.yml down
# Pinot cannot be started on its own because it depends on the Zookeeper service in the Kpow stack
```

## Port Mapping

**Kpow**

- `compose-kpow-trial.yml`
- `compose-kpow-community.yml`

| Service Name | Port(s) (Host:Container) | Description                                               |
| :----------- | :----------------------- | :-------------------------------------------------------- |
| `kpow`       | `3000:3000`              | Kpow (Web UI for Kafka monitoring and management)         |
| `schema`     | `8081:8081`              | Confluent Schema Registry (manages Kafka message schemas) |
| `connect`    | `8083:8083`              | Kafka Connect (framework for Kafka connectors)            |
| `zookeeper`  | `2181:2181`              | ZooKeeper (coordination service for Kafka)                |
| `kafka-1`    | `9092:9092`              | Kafka Broker 1 (message broker instance)                  |
| `kafka-2`    | `9093:9093`              | Kafka Broker 2 (message broker instance)                  |
| `kafka-3`    | `9094:9094`              | Kafka Broker 3 (message broker instance)                  |

**Flex**

- `compose-flex-community.yml`
- `compose-flex-trial.yml`

| Service Name  | Port(s) (Host:Container) | Description                                                       |
| :------------ | :----------------------- | :---------------------------------------------------------------- |
| `flex`        | `3001:3000`              | Flex (Web UI for Flink management, using host port 3001)          |
| `jobmanager`  | `8082:8081`              | Apache Flink JobManager (coordinates Flink jobs, Web UI/REST API) |
| `sql-gateway` | `9090:9090`              | Apache Flink SQL Gateway (REST endpoint for SQL queries)          |

_(Note: `taskmanager-1`, `taskmanager-2`, `taskmanager-3` do not expose ports to the host)_

**Analytics**

- `compose-analytics.yml`

| Service Name    | Port(s) (Host:Container)                                     | Description                                                               |
| :-------------- | :----------------------------------------------------------- | :------------------------------------------------------------------------ |
| `spark-iceberg` | `8888:8888`,<br>`8080:8080`,<br>`10000:10000`, `10001:10001` | 8888: Jupyter Server<br>8080: Spark Web UI<br>10000/1 Spark Thrift Server |
| `rest`          | `8181:8181`                                                  | Apache Iceberg REST Catalog Service                                       |
| `minio`         | `9001:9001`, `9000:9000`                                     | MinIO S3 Object Storage (9000: API, 9001: Console UI)                     |
| `postgres`      | `5432:5432`                                                  | PostgreSQL Database Server                                                |

_(Note: `mc` does not expose ports to the host)_

**Pinot**

- `compose-pinot.yml`

| Service Name       | Port(s) (Host:Container) | Description                                                 |
| :----------------- | :----------------------- | :---------------------------------------------------------- |
| `pinot-controller` | `19000:9000`             | Apache Pinot Controller (manages cluster state, UI/API)     |
| `pinot-broker`     | `18099:8099`             | Apache Pinot Broker (handles query routing and results)     |
| `pinot-server`     | `18098:8098`             | Apache Pinot Server (hosts data segments, executes queries) |
