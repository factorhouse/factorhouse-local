![factorhouse](./images/factorhouse.jfif)

# Factor House Local

![architecture](./images/factorhouse-local.png)

## Introduction

We provide several pre-configured Docker Compose environments to showcase different data platform setups. The summaries below offer a quick overview of each:

<details>

<summary><b>Kafka Development & Monitoring with Kpow</b></summary>

<br>

This stack provides a complete **Apache Kafka development and monitoring environment**, built using Confluent Platform components and enhanced with [**Kpow**](https://factorhouse.io/kpow) for enterprise-grade observability and management. It includes a 3-node Kafka cluster, Zookeeper, Schema Registry, Kafka Connect, and Kpow itself.

### 📌 Description

This architecture is designed for developers and operations teams who need a **robust, local Kafka ecosystem** for building, testing, and managing Kafka-based applications. It features high availability (3 brokers), schema management for data governance, a data integration framework (Kafka Connect), and a powerful UI (Kpow) for monitoring cluster health, inspecting data, managing topics, and troubleshooting.

It's ideal for scenarios involving **event-driven architectures, microservices communication, data integration pipelines**, and situations requiring deep visibility into Kafka internals.

---

### 🔑 Key Components

#### 🚀 Kpow (Kafka Management & Monitoring Toolkit)

- Container: `factorhouse/kpow:latest` (ee) or `factorhouse/kpow-ce:latest` (ce)
- An engineering toolkit providing a rich web UI for comprehensive Kafka monitoring, management, and data inspection. Kpow gathers Kafka resource information, stores it locally in internal topics, and delivers custom telemetry and insights. Features include:
  - **Comprehensive Real-time Kafka Resource Monitoring:**
    - Instant visibility ("X-Ray vision") of brokers, topics, consumer groups, partitions, offsets, and more.
    - Gathers data every minute, with a "Live mode" for real-time updates.
    - No JMX access required.
  - **Advanced Consumer and Streams Monitoring (Compute Console):**
    - Visualize message throughput and lag for consumers (and soon, Kafka Streams topologies).
    - Multi-dimensional consumer lag insights from custom derived telemetry.
    - Ability to reset consumption at group, host, member, topic, or assignment level.
  - **Deep Data Inspection with kJQ:**
    - Powerful JQ-like querying (kJQ) to search tens of thousands of messages per second.
    - Supports JSON, Apache Avro®, Transit, EDN, and Protobuf messages (with custom serdes for Protobuf to JSON).
  - **Schema Registry Integration:** Full support for controlling and monitoring Schema Registries.
  - **Kafka Connect Cluster Management:** Full support for controlling and monitoring Kafka Connect clusters.
  - **Enterprise-Grade Security & Governance:**
    - **Authentication:** Supports DB, File, LDAP, SAML, or OpenID configurations.
    - **Authorization:** Simple or Role-Based Access Controls (RBAC). The original summary also mentioned JAAS, often paired with RBAC and configured via volume mounts (_Enterprise edition (ee) only_).
    - **Data Policies:** Includes capabilities for masking and redaction of sensitive data (e.g., PII, Credit Card).
    - **Audit Logging:** All user actions are captured in the Kpow audit log.
  - **Key Integrations & Deployment Features:**
    - **Slack Integration:** Sends user actions to an operations channel.
    - **Prometheus Endpoints:** For integration with preferred metrics and alerting systems.
    - **HTTPS Support:** Easily configured with your own certificates or via a reverse-proxy.
    - **Multi-Cluster Monitoring:** Manage multiple Kafka clusters from a single Kpow installation.
    - **Air-Gapped Environments:** Well-suited due to all data being stored in local Kafka topics.
- Exposes UI at `http://localhost:3000`

#### 🧠 Kafka Cluster (3 Brokers + Zookeeper)

- **Zookeeper (`confluentinc/cp-zookeeper:7.8.0`)**: Coordinates the Kafka brokers.
- **Kafka Brokers (`confluentinc/cp-kafka:7.8.0` x3)**: Form the core message bus.
  - Configured with distinct internal (`1909x`) and external (`909x`) listeners for docker networking.
  - Provides basic fault tolerance with 3 nodes.
  - Accessible externally via ports `9092`, `9093`, `9094`.

#### 📜 Schema Registry (`confluentinc/cp-schema-registry:7.8.0`)

- Manages schemas (Avro, Protobuf, JSON Schema) for Kafka topics, ensuring data consistency and enabling schema evolution.
- Accessible at `http://localhost:8081`.
- Configured with Basic Authentication (`schema_jaas.conf`).
- Stores its schemas within the Kafka cluster itself.

#### 🔌 Kafka Connect (`confluentinc/cp-kafka-connect:7.8.0`)

- Framework for reliably streaming data between Apache Kafka and other systems.
- Accessible via REST API at `http://localhost:8083`.
- Configured to use JSON converters by default.
- **Custom Connector Support**: Volume mount `./resources/kpow/connector` allows adding custom or third-party connectors (e.g., JDBC, S3, Iceberg - hinted by `AWS_REGION`).
- Manages its configuration, offsets, and status in dedicated Kafka topics.

---

### 🧰 Use Cases

#### Local Kafka Development & Testing

- Build and test Kafka producers, consumers, and Kafka Streams applications against a realistic, multi-broker cluster.
- Validate application behavior during broker failures (by stopping/starting broker containers).

#### Data Integration Pipelines

- Utilize Kafka Connect to ingest data into Kafka from databases, logs, or APIs using source connectors.
- Stream data out of Kafka to data lakes (S3, Iceberg), warehouses, or other systems using sink connectors.
- Test and manage connector configurations via the Connect REST API or Kpow UI.

#### Schema Management & Evolution

- Define, register, and evolve schemas using Schema Registry to enforce data contracts between producers and consumers.
- Test compatibility modes and prevent breaking changes in data pipelines.

#### Real-Time Monitoring & Operations Simulation

- Use Kpow to monitor cluster health, track topic/partition metrics (size, throughput), identify consumer lag, and inspect messages in real-time.
- Understand Kafka performance characteristics and troubleshoot issues within a controlled environment.

#### Learning & Exploring Kafka

- Provides a self-contained environment to learn Kafka concepts, experiment with configurations, and explore the capabilities of the Confluent Platform and Kpow.

</details>

<details>

<summary><b>Real-Time Stream Analytics with Flink + Flex</b></summary>

<br>

This stack delivers a high-performance **streaming analytics solution** centered on Apache Flink, tailored for **low-latency processing, complex event enrichment, joins**, and SQL-driven operations. It features [**Flex**](https://factorhouse.io/flex), a secure enterprise-grade tool for Flink, along with Flink JobManager/TaskManagers and a **SQL Gateway** for multi-client SQL execution.

### 📌 Description

This architecture is built to support **streaming-first workloads**, making it ideal for scenarios demanding low-latency event-time processing and complex data enrichment. Leveraging the power of Apache Flink, and enhanced by Flex's enterprise features, it provides robust RBAC, accessible SQL gateway operations, and streamlined plug-and-play stream processing capabilities.

It is designed for **dynamic, real-time applications**, proving especially effective for **operational intelligence**, **advanced fraud detection**, **comprehensive system observability**, and the development of **responsive real-time metrics pipelines**.

---

### 🔑 Key Components

#### 🚀 Flex (Enterprise Flink Runtime)

- Container: `factorhouse/flex:latest` (ee) (Inferred from previous context and "Enterprise" focus)
- Provides an enterprise-ready tooling solution to streamline and simplify Apache Flink management. It gathers Flink resource information, offering custom telemetry, insights, and a rich data-oriented UI. Key features include:
  - **Comprehensive Flink Monitoring & Insights:**
    - Gathers Flink resource information minute-by-minute.
    - Offers fully integrated metrics and telemetry.
    - Provides access to long-term metrics and aggregated consumption/production data, from cluster-level down to individual job-level details.
  - **Simplified Management for All User Groups:**
    - User-friendly interface and intuitive controls.
    - Aims to align business needs with Flink capabilities.
  - **Enterprise-Grade Security & Governance:**
    - **Versatile Authentication:** Supports DB, File, LDAP, SAML, OpenID, Okta, and Keycloak.
    - **Robust Authorization:** Offers Simple or fine-grained Role-Based Access Controls (RBAC).
    - **Data Policies:** Includes capabilities for masking and redaction of sensitive data (e.g., PII, Credit Card).
    - **Audit Logging:** Captures all user actions for comprehensive data governance.
    - **Secure Deployments:** Supports HTTPS and is designed for air-gapped environments (all data remains local).
  - **Powerful Flink Enhancements:**
    - **Multi-tenancy:** Advanced capabilities to manage Flink resources effectively with control over visibility and usage.
    - **Multi-Cluster Monitoring:** Manage and monitor multiple Flink clusters from a single installation.
  - **Key Integrations:**
    - **Prometheus:** Exposes endpoints for integration with preferred metrics and alerting systems.
    - **Slack:** Allows user actions to be sent to an operations channel in real-time.
- Exposes UI at `http://localhost:3001`

#### 🧠 Flink Cluster

- **JobManager** coordinates all tasks, handles scheduling, checkpoints, and failover.
  - Healthcheck verifies `/config` for readiness.
  - Volume mounts for custom Flink config and SQL defaults.
- **TaskManagers (3 nodes)** run user code and perform actual stream processing.
  - Horizontally scalable.
  - Connected to the same config and connector volumes as the JobManager.

#### 🛠 SQL Gateway

- REST-accessible endpoint (`http://localhost:9090`) for **interactive Flink SQL queries**.
- Allows:
  - Creating, updating, querying tables using Flink SQL
  - Querying Iceberg, Kafka, JDBC, and custom connectors
- Configured to run in the foreground for easier debugging.

---

### 🧰 Use Cases

#### Real-Time ETL & Stream Enrichment

- Ingest data from Kafka or other connectors.
- Join with lookup data (e.g., Redis, JDBC) in real time.
- Output to Iceberg, S3, PostgreSQL, or other sinks.

#### Event-Driven Analytics

- Detect patterns using **event-time windows**, **session clustering**, or **CEP (Complex Event Processing)**.
- Generate metrics and insights instantly on live data.

#### Self-Service SQL on Streaming Data

- Use SQL Gateway to empower analysts to query streaming datasets without needing deep Flink knowledge.
- Supports materialized views, table functions, and views over dynamic data.

#### Real-Time Data Lake Writes

- Use Flink's native Iceberg integration to write out structured, evolving tables in real time.
- Lakehouse-friendly, works well with batch processors (e.g., Spark) downstream.

</details>

<details>

<summary><b>Analytics & Lakehouse: Spark, Iceberg, MinIO & Postgres</b></summary>

<br>

This stack provides a self-contained environment for **modern data lakehouse analytics** using Apache Spark, Apache Iceberg, MinIO (S3-compatible object storage), and PostgreSQL. It features an Iceberg REST Catalog for centralized metadata management.

### 📌 Description

This architecture enables building and querying **data lakehouses**, where data is stored in an open format (Iceberg) on object storage (MinIO), offering ACID transactions, schema evolution, and time travel capabilities, while leveraging the powerful distributed processing engine of Apache Spark. The included PostgreSQL database can serve as a source/sink for relational data or potentially for Change Data Capture (CDC) scenarios.

It's ideal for **batch ETL/ELT, interactive data exploration via notebooks, and building reliable, scalable data analytics pipelines** on structured and semi-structured data.

---

### 🔑 Key Components

#### 🚀 Spark + Iceberg Compute Engine

- Container: `tabular/spark-iceberg:3.5.5_1.8.1` (`spark-iceberg`)
- Provides an **Apache Spark** environment pre-configured with **Apache Iceberg** support.
- Includes **Jupyter Notebook server** for interactive analytics (`http://localhost:8888`).
- **Spark Web UI** for monitoring jobs (`http://localhost:8080`).
- Configured via `spark-defaults.conf` to connect to the Iceberg REST catalog (`rest:8181`) and use MinIO as the S3 backend.
- Environment variables provide AWS credentials (`admin`/`password`) for MinIO access.

#### 📚 Iceberg REST Catalog

- Container: `apache/iceberg-rest-fixture` (`iceberg-rest`)
- A dedicated **REST service for managing Iceberg table metadata**.
- Allows multiple engines (like the Spark service here) to interact with the same Iceberg tables consistently.
- Configured to use MinIO (`http://minio:9000`) as the storage backend for the warehouse path `s3://warehouse/`.
- Accessible internally at `http://rest:8181`.

#### 💾 S3-Compatible Object Storage (MinIO)

- Container: `minio/minio` (`minio`)
- Provides **S3-compatible object storage**, acting as the data lake storage layer for Iceberg tables.
- **MinIO API** accessible at `http://localhost:9000`.
- **MinIO Console UI** accessible at `http://localhost:9001` (Credentials: `admin`/`password`).
- Initialized by the `mc` service.

#### 🛠 MinIO Client (Initialization)

- Container: `minio/mc` (`mc`)
- Utility container that runs once to:
  - Wait for MinIO to be ready.
  - Configure the MinIO client (`mc`) to connect to the `minio` service.
  - **Create necessary buckets** (`warehouse` for Iceberg, `factorhouse` for general use) and set public access policies.

#### 🐘 Relational Database (PostgreSQL)

- Container: `postgres:17` (`postgres`)
- Standard **PostgreSQL database**.
- Accessible at `localhost:5432` (Credentials: `db_user`/`db_password`, Database: `factorhouse`).
- **`wal_level=logical`**: This setting is enabled, suggesting potential use cases involving **Change Data Capture (CDC)**, allowing changes in Postgres tables to be streamed out.
- Includes volume mount for initialization scripts (`./resources/analytics/postgres`), allowing pre-loading of schemas or data.

---

### 🧰 Use Cases

#### Data Lakehouse Implementation

- Create, manage, and query Iceberg tables stored in MinIO using Spark SQL or DataFrame API via Jupyter notebooks.
- Perform ACID-compliant operations (INSERT, UPDATE, DELETE, MERGE) on large datasets.
- Leverage Iceberg features like schema evolution, partitioning, and time travel/version rollback.

#### Batch ETL/ELT Pipelines

- Ingest data from various sources (including Postgres), process/transform it using Spark, and load it into Iceberg tables in the lakehouse.
- Read data from Iceberg tables for downstream processing or reporting.

#### Interactive Data Analysis & Exploration

- Connect to the Jupyter server (`:8888`) to run Spark code (PySpark, Spark SQL) interactively against data stored in MinIO/Iceberg or the Postgres database.
- Visualize results directly within notebooks.

#### Change Data Capture (CDC) Foundation

- The Postgres `wal_level=logical` setup enables capturing row-level changes. While a CDC tool (like Debezium via Kafka Connect, or a Spark connector) isn't included _in this stack_, the database is ready for such integration, allowing changes from Postgres to be ingested into the Iceberg lakehouse in near real-time.

#### Development & Testing Environment

- Provides a local, integrated environment for developing and testing Spark applications that interact with Iceberg tables, S3 storage, and a relational database.

</details>

<details>

<summary><b>Apache Pinot Real-Time OLAP Cluster</b></summary>

<br>

This stack deploys a basic **Apache Pinot** cluster, a real-time distributed **OLAP (Online Analytical Processing)** datastore designed for **ultra-low-latency analytics** at scale. It includes the core Pinot components: Controller, Broker, and Server.

### 📌 Description

This architecture provides the foundation for ingesting data from batch (e.g., HDFS, S3) or streaming sources (e.g., Kafka) and making it available for analytical queries with response times often in milliseconds. Pinot is optimized for user-facing analytics, real-time dashboards, anomaly detection, and other scenarios requiring fast insights on fresh data.

**Note:** This configuration requires an external Apache Zookeeper instance running at `zookeeper:2181` on the `factorhouse` network for cluster coordination, which is not defined within the Docker Compose file.

---

### 🔑 Key Components

#### 👑 Pinot Controller (`pinot-controller`)

- Container: `apachepinot/pinot:1.2.0`
- Role: Manages the overall cluster state, handles administration tasks (like adding tables, schema management), coordinates segment assignment, and monitors node health via Zookeeper.
- **Admin UI/API**: Exposed externally at `http://localhost:19000` (maps to internal port 9000).
- Healthcheck verifies its readiness.

#### 📡 Pinot Broker (`pinot-broker`)

- Container: `apachepinot/pinot:1.2.0`
- Role: Acts as the query gateway. Receives SQL queries from clients, determines which servers hold the relevant data segments, scatters the query to those servers, gathers the results, and returns the final consolidated response.
- **Query Endpoint**: Exposed externally at `http://localhost:18099` (maps to internal port 8099).
- Depends on the Controller being healthy before starting.
- Healthcheck verifies its readiness.

#### 💾 Pinot Server (`pinot-server`)

- Container: `apachepinot/pinot:1.2.0`
- Role: Hosts data segments (shards) and executes query fragments against the data it stores. Can ingest data directly from streaming sources (Realtime Server) or load pre-built segments from deep storage (Offline Server). This configuration runs a generic Server capable of both roles depending on table setup.
- **Internal API/Metrics**: Exposed externally at `http://localhost:18098` (maps to internal port 8098/8097 for health). Direct interaction is less common than with the Broker or Controller.
- Depends on the Broker being healthy before starting.
- Healthcheck verifies its readiness.

#### 🌐 Network & Dependencies

- All components reside on the `factorhouse` network.
- Relies on an **external Zookeeper** instance at `zookeeper:2181` for coordination.
- Startup order is enforced via `depends_on` and `healthcheck` conditions: Controller -> Broker -> Server.

---

### 🧰 Use Cases

#### Real-Time Dashboards

- Power interactive dashboards requiring millisecond query latency on potentially large, constantly updating datasets (e.g., operational monitoring, business intelligence).

#### User-Facing Analytics

- Embed analytics directly into applications where users can explore data slices and dices with immediate feedback (e.g., e-commerce site analytics, personalized recommendations).

#### Anomaly & Threat Detection

- Query streaming event data in near real-time to identify patterns, outliers, or anomalies quickly (e.g., fraud detection, system security monitoring).

#### A/B Testing Analysis

- Ingest experiment data and provide rapid aggregations and comparisons to evaluate A/B test performance.

#### Log Analytics

- Provide fast, interactive querying over large volumes of log or event data for troubleshooting and analysis.

</details>

---

<div align="center">

## 🚀 New: Factor House Local Labs! 🚀

Get a fast and practical start with our new **Factor House Local labs**. These hands-on labs provide detailed walkthroughs for building real-time data pipelines using **Kafka**, **Flink**, **Spark**, **Iceberg**, and **Pinot**.

<a href="https://github.com/factorhouse/examples/tree/main/fh-local-labs" target="_blank" rel="noopener noreferrer">
  <img src="./images/fh-local-labs.png" alt="Factor House Local Labs" width="600"/>
</a>

Each lab is designed to be modular, hands-on, and production-inspired, helping you learn, prototype, and extend your data platform skills.

[**➡️ Click Here to Explore the Labs**](https://github.com/factorhouse/examples/tree/main/fh-local-labs)

</div>

## Prerequisites

### Install Docker

The local cluster runs with Docker Compose, so you will need to [install Docker](https://www.docker.com/).

Once Docker is installed, clone this repository and run the following commands from the base path.

### Clone this repository

```
git clone git@github.com:factorhouse/factorhouse-local.git
```

### Change into the repository directory

```
cd factorhouse-local
```

### Download Kafka/Flink Connectors and Spark Iceberg Dependencies

The following Kafka/Flink connectors and Spark Iceberg dependency JAR files are downloaded and made available for use:

- **Kafka**
  - [Confulent S3 Sink Connector](https://docs.confluent.io/kafka-connectors/s3-sink/current/overview.html)
  - [Debezium connector for PostgreSQL](https://debezium.io/documentation/reference/stable/connectors/postgresql.html)
  - [Apache Iceberg Sink Connector](https://github.com/databricks/iceberg-kafka-connect)
  - [Amazon MSK Data Generator](https://github.com/awslabs/amazon-msk-data-generator)
- **Flink**
  - [Apache Kafka SQL Connector](https://nightlies.apache.org/flink/flink-docs-release-1.20/docs/connectors/table/kafka/)
  - [Flink Facker Connector](https://github.com/knaufk/flink-faker)
- **Iceberg**
  - [Iceberg Spark Runtime](https://iceberg.apache.org/docs/latest/spark-getting-started/)
  - [Iceberg AWS Bundle](https://iceberg.apache.org/docs/latest/aws/)

```bash
./resources/setup-env.sh

# downloading kafka connectors ...
# downloading flink connectors and format dependencies...
# downloading spark iceberg dependencies...
```

### Update Kpow and Flex Licenses

Both **Kpow** and **Flex** require valid licenses to run. You can get started in one of two ways:

- Request a free **Community License** for non-commercial use:

  - [Kpow Community License](https://factorhouse.io/kpow/community/)
  - [Flex Community License](https://factorhouse.io/flex/community/)

- Or request a **30-day Trial License** for commercial evaluation - **this license unlocks all enterprise features**:

  - [Kpow Trial License](https://factorhouse.io/kpow/get-started/)
  - [Flex Trial License](https://factorhouse.io/flex/get-started/)

For managing Kpow and Flex licenses effectively, it's strongly recommended to store the license files **externally** from your main configuration or version control system (like Git). This approach prevents accidental exposure of sensitive license details and makes updating or swapping licenses much simpler.

The Docker Compose files facilitates this by allowing you to specify the path to your license file using **environment variables** on your host machine _before_ launching the services. Specifically, they are configured to look for these variables and use their values to locate the appropriate license file via the `env_file` directive. If an environment variable is not set, a default path (usually within the `resources` directory) is used as a fallback.

The specific environment variables used are:

- **`KPOW_TRIAL_LICENSE`**: Specifies the path to the Kpow Enterprise Trial license file.
- **`KPOW_COMMUNITY_LICENSE`**: Specifies the path to the Kpow Community license file.
- **`FLEX_TRIAL_LICENSE`**: Specifies the path to the Flex Trial license file.
- **`FLEX_COMMUNITY_LICENSE`**: Specifies the path to the Flex Community license file.

**Example Usage:**

Imagine your Kpow Community license is stored at `/opt/licenses/kpow-community.env`. To instruct Docker Compose to use this specific file, you would set the environment variable on your host _before_ running the compose command:

```bash
# Set the environment variable (syntax may vary slightly depending on your shell)
export KPOW_COMMUNITY_LICENSE=/opt/licenses/kpow-community.env

# Now run Docker Compose - it will use the path set above
docker compose -p kpow -f compose-kpow-community.yml up -d
```

<details>

<summary>License file example</summary>

```
LICENSE_ID=<license-id>
LICENSE_CODE=<license-code>
LICENSEE=<licensee>
LICENSE_EXPIRY=<license-expiry>
LICENSE_SIGNATURE=<license-signature>
```

</details>

<details>

<summary>License mapping details</summary>

```yaml
# compose-kpow-trial.yml
services:
  kpow:
    ...
    env_file:
      - resources/kpow/config/trial.env
      - ${KPOW_TRIAL_LICENSE:-resources/kpow/config/trial-license.env}

# compose-kpow-community.yml
services:
  kpow:
    ...
    env_file:
      - resources/kpow/config/community.env
      - ${KPOW_COMMUNITY_LICENSE:-resources/kpow/config/community-license.env}

# compose-flex-trial.yml
services:
  flex:
  ...
  env_file:
    - resources/flex/config/trial.env
    - ${FLEX_TRIAL_LICENSE:-resources/flex/config/trial-license.env}

# compose-flex-trial.yml
services:
  flex:
  ...
  env_file:
    - resources/flex/config/local-community.env
    - ${KPOW_COMMUNITY_LICENSE:-resources/flex/config/community-license.env}
```

</details>

## Start Resources

There are two primary methods for launching the various Docker Compose stacks (Kpow, Flex, Analytics, Pinot).

- The first method launches all stacks sequentially as an integrated system, offering variants for either **Kpow Enterprise (Trial)** (`compose-kpow-trial.yml`) or **Kpow Community** (`compose-kpow-community.yml`) as the initial component. It uses the `&&` operator to ensure the Kpow stack starts first, which is important becuse it is responsible for creating the shared `factorhouse` Docker network used by the other services. Note that this integrated approach employs the `-p <project_name>` flag for each `docker compose` command (e.g., `-p kpow`, `-p flex`) to assign distinct project names. This prevents potential conflicts and "orphan container" warnings that can occur when Docker Compose manages multiple configurations from the same directory, ensuring each stack is managed as a separate entity while sharing the network.
- The second method demonstrates starting services individually. Kpow (Trial or Community) can be launched standalone. To start Flex or Analytics independently (perhaps for isolated testing), the `USE_EXT=false` environment variable should be prepended to their respective commands. This overrides their default network configuration (defined as `external: ${USE_EXT:-true}` within their Compose files), forcing them to create its own Docker network. Note that the Pinot stack cannot be started in this isolated fashion because its configuration explicitly depends on the Zookeeper service provided by the Kpow stack, requiring them to be on the same network.

```bash
## Method 1
# Kpow/Flex Enterprise
docker compose -p kpow -f compose-kpow-trial.yml up -d \
  && docker compose -p flex -f compose-flex-trial.yml up -d \
  && docker compose -p analytics -f compose-analytics.yml up -d \
  && docker compose -p pinot -f compose-pinot.yml up -d

# Kpow/Flex Community
docker compose -p kpow -f compose-kpow-community.yml up -d \
  && docker compose -p flex -f compose-flex-community.yml up -d \
  && docker compose -p analytics -f compose-analytics.yml up -d \
  && docker compose -p pinot -f compose-pinot.yml up -d

## Method 2
# Kpow Enterprise
docker compose -f compose-kpow-trial.yml up -d
# Flex Enterprise
USE_EXT=false docker compose -f compose-flex-trial.yml up -d

# Kpow Community
docker compose -f compose-kpow-community.yml up -d
# Flex Community
USE_EXT=false docker compose -f compose-flex-community.yml up -d

USE_EXT=false docker compose -p analytics -f compose-analytics.yml up -d
# Pinot cannot be started on its own because it depends on the Zookeeper service in the Kpow stack
```

## Stop/Remove Resources

Likewise, there are two methods for stopping and removing the containers and Docker networks.

- The first method handles the teardown of the **entire integrated system**. It uses `docker compose down` sequentially for each stack, specifying the corresponding `-p <project_name>` flag used during startup (e.g., `-p pinot`, `-p analytics`) to ensure the correct set of resources is targeted. The order is reversed compared to startup, with the Kpow stack (Trial or Community) being brought down _last_. This is necessary because the Kpow stack creates the shared `factorhouse` network, and removing it last allows other services to cleanly detach before the network is removed.
- The second method addresses stopping **individual services** that might have been started in isolation. Kpow (Trial or Community) is stopped using a simple `docker compose down`. For Flex and Analytics, if they were started independently using `USE_EXT=false`, the same `USE_EXT=false` environment variable _must_ be prepended to the `docker compose down` command. This ensures Docker Compose correctly identifies and removes the _isolated_ network that was created specifically for that stack during its isolated startup.

```bash
## Method 1
# Kpow/Flex Enterprise
docker compose -p pinot -f compose-pinot.yml down \
  && docker compose -p analytics -f compose-analytics.yml down \
  && docker compose -p flex -f compose-flex-trial.yml down \
  && docker compose -p kpow -f compose-kpow-trial.yml down

# Kpow/Flex Community
docker compose -p pinot -f compose-pinot.yml down \
  && docker compose -p analytics -f compose-analytics.yml down \
  && docker compose -p flex -f compose-flex-community.yml down \
  && docker compose -p kpow -f compose-kpow-community.yml down

## Method 2
# Kpow Enterprise
docker compose -f compose-kpow-trial.yml down
# Flex Enterprise
USE_EXT=false docker compose -f compose-flex-trial.yml down

# Kpow Community
docker compose -f compose-kpow-community.yml down
# Flex Community
USE_EXT=false docker compose -f compose-flex-community.yml down

USE_EXT=false docker compose -p analytics -f compose-analytics.yml down
```

## Main Services

The enterprise editions of **Kpow** and **Flex** support multiple authentication providers, as outlined in the documentation below:

- [Kpow Authentication Overview](https://docs.factorhouse.io/kpow-ee/authentication/overview/)
- [Flex Authentication Overview](https://docs.factorhouse.io/flex-ee/authentication/)

Among those, this project includes file-based authentication, and user credentials can be found in the following locations:

- **Kpow**: [resources/kpow/config/trial.env](./resources/kpow/config/trial.env)
- **Flex**: [resources/flex/config/trial.env](./resources/flex/config/trial.env)

For demonstration purposes, **Kpow** and **Flex** can be accessed using `admin` as both the username and password.

![Kpow Login](./images/kpow-login.png)

After successful authentication, users are redirected to the **Overview** page.

![Kpow Overview](./images/kpow-overview.png)

The following sections show key services and their associated port mappings.

### Kafka with Kpow

| Service Name | Port(s) (Host:Container) | Description                                               |
| :----------- | :----------------------- | :-------------------------------------------------------- |
| `kpow`       | `3000:3000`              | Kpow (Web UI for Kafka monitoring and management)         |
| `schema`     | `8081:8081`              | Confluent Schema Registry (manages Kafka message schemas) |
| `connect`    | `8083:8083`              | Kafka Connect (framework for Kafka connectors)            |
| `zookeeper`  | `2181:2181`              | ZooKeeper (coordination service for Kafka)                |
| `kafka-1`    | `9092:9092`              | Kafka Broker 1 (message broker instance)                  |
| `kafka-2`    | `9093:9093`              | Kafka Broker 2 (message broker instance)                  |
| `kafka-3`    | `9094:9094`              | Kafka Broker 3 (message broker instance)                  |

### Flink with Flex

| Service Name  | Port(s) (Host:Container) | Description                                                       |
| :------------ | :----------------------- | :---------------------------------------------------------------- |
| `flex`        | `3001:3000`              | Flex (Web UI for Flink management, using host port 3001)          |
| `jobmanager`  | `8082:8081`              | Apache Flink JobManager (coordinates Flink jobs, Web UI/REST API) |
| `sql-gateway` | `9090:9090`              | Apache Flink SQL Gateway (REST endpoint for SQL queries)          |

_(Note: `taskmanager-1`, `taskmanager-2`, `taskmanager-3` do not expose ports to the host)_

### Analytics & Lakehouse

| Service Name    | Port(s) (Host:Container)      | Description                                           |
| :-------------- | :---------------------------- | :---------------------------------------------------- |
| `spark-iceberg` | `4040:4040`,<br>`18080:18080` | Spark Web UI<br>Spark History Server                  |
| `rest`          | `8181:8181`                   | Apache Iceberg REST Catalog Service                   |
| `minio`         | `9001:9001`, `9000:9000`      | MinIO S3 Object Storage (9000: API, 9001: Console UI) |
| `postgres`      | `5432:5432`                   | PostgreSQL Database Server                            |

_(Note: `mc` does not expose ports to the host)_

### Apache Pinot OLAP

| Service Name       | Port(s) (Host:Container) | Description                                                 |
| :----------------- | :----------------------- | :---------------------------------------------------------- |
| `pinot-controller` | `19000:9000`             | Apache Pinot Controller (manages cluster state, UI/API)     |
| `pinot-broker`     | `18099:8099`             | Apache Pinot Broker (handles query routing and results)     |
| `pinot-server`     | `18098:8098`             | Apache Pinot Server (hosts data segments, executes queries) |

## Custom Flink Docker Image

We provide a custom Docker image ([`factorhouse/flink`](https://hub.docker.com/r/factorhouse/flink)) - a multi-architecture (**amd64**, **arm64**) Apache Flink environment based on the LTS release (`flink:1.20.1` as of May 2025). This image is specially optimized for running Flink jobs, including PyFlink and Flink SQL, and comes with out-of-the-box support for key data ecosystem components such as S3, Hadoop, Apache Iceberg, and Parquet.

### Key Features:

- **Flink Version:** Apache Flink LTS (`1.20.1`).
- **Java Runtime:** Uses **Adoptium Temurin OpenJDK 11** (`11.0.27+6`), installed in `/opt/java`. The appropriate architecture version is downloaded and verified during the build. `JAVA_HOME` is set accordingly.
  - _Note:_ This specific JDK setup is necessary for reliably building PyFlink dependencies on `arm64` architectures.
- **Python Support:**
  - Python 3, `pip`, and essential build tools are installed.
  - **PyFlink** (`apache-flink` package) version `1.20.1`, matching the Flink release, is installed via pip.
- **Bundled Dependencies:** Includes pre-downloaded JAR files for common Flink SQL use cases, placed in dedicated directories:
  - `/tmp/hadoop/`: Hadoop 3.3.6 core, HDFS client, MapReduce client, Auth, AWS connector (`hadoop-aws`), and necessary dependencies (Woodstox, Jackson, Guava, AWS SDK Bundle, etc.).
  - `/tmp/iceberg/`: Apache Iceberg 1.8.1 runtime for Flink 1.20 (`iceberg-flink-runtime-1.20`) and the AWS bundle (`iceberg-aws-bundle`).
  - `/tmp/parquet/`: Flink SQL Parquet format connector (`flink-sql-parquet`) version 1.20.1.
- **S3 Filesystem Plugins:** The standard Flink S3 filesystem connectors (`flink-s3-fs-hadoop` and `flink-s3-fs-presto`) are copied into the `/opt/flink/plugins/` directory for easy activation.
- **Custom Flink Scripts:** Core Flink startup scripts (`config.sh`, `flink-console.sh`, `flink-daemon.sh`, `sql-client.sh`) located in `/opt/flink/bin/` have been **replaced with custom versions**. These scripts enable the custom dependency loading mechanism described below.
- **Custom Hadoop Configuration:** A `core-site.xml` file is copied to `/opt/hadoop/etc/hadoop/`, allowing for pre-configuration of Hadoop/S3 settings (e.g., S3 endpoints, credentials providers via `HADOOP_CONF_DIR`).

### 📌 Custom Dependency Loading for SQL Client/Gateway

The `factorhouse/flink` image simplifies using Flink SQL with common formats and filesystems by pre-packaging essential JARs (Hadoop, Iceberg, Parquet). However, these JARs reside in `/tmp/*` directories, **not** in the standard `/opt/flink/lib` directory scanned by default by the Flink SQL Client and SQL Gateway.

To bridge this gap, this image utilizes a **custom class loading mechanism** implemented via the modified Flink scripts in `/opt/flink/bin/`.

**How it Works:**

1.  The custom startup scripts check for the presence of the environment variable `CUSTOM_JARS_DIRS`.
2.  If `CUSTOM_JARS_DIRS` is set, the scripts scan the specified directories (separated by semicolons `;`) and add any found JAR files to the Flink classpath before launching the service (JobManager, TaskManager, SQL Client, SQL Gateway).

**Default Configuration:**

This image is designed to work out-of-the-box for SQL Client/Gateway scenarios involving the bundled dependencies. This is typically achieved by setting the environment variable in the Flink Docker Compose files: `compose-flex-trial.yml` and `compose-flex-community.yml`:

```yaml
x-common-environment: &flink_common_env_vars
  AWS_REGION: us-east-1
  HADOOP_CONF_DIR: /opt/hadoop/etc/hadoop
  CUSTOM_JARS_DIRS: "/tmp/hadoop;/tmp/iceberg;/tmp/parquet"

services:
  jobmanager:
    image: factorhouse/flink:latest
    container_name: jobmanager
    pull_policy: always
    command: jobmanager
    ports:
      - "8082:8081"
    networks:
      - factorhouse
    environment:
      <<: *flink_common_env_vars
    volumes:
      - ./resources/flex/flink/flink-conf.yaml:/opt/flink/conf/flink-conf.yaml:ro
      - ./resources/flex/flink/sql-client-defaults.yaml:/opt/flink/conf/sql-client-defaults.yaml:ro
      - ./resources/flex/connector:/tmp/connector
```

Setting **CUSTOM_JARS_DIRS** as shown ensures the Hadoop, Iceberg, and Parquet JARs are loaded when needed by the SQL Client or Gateway.

**Verifying Classpath Loading:**

You can observe the difference in the classpath reported in the logs:

1. With **CUSTOM_JARS_DIRS** Set (Default recommended for SQL Client/Gateway):

   ```yaml
   x-common-environment: &flink_common_env_vars
     AWS_REGION: us-east-1
     HADOOP_CONF_DIR: /opt/hadoop/etc/hadoop
     CUSTOM_JARS_DIRS: "/tmp/hadoop;/tmp/iceberg;/tmp/parquet"
   ```

   JobManager Log Output:

   ```log
   Starting Job Manager
   [INFO] Added custom JARs from /tmp/hadoop
   [INFO] Added custom JARs from /tmp/iceberg
   [INFO] Added custom JARs from /tmp/parquet
   Classpath Output:
   /opt/flink/lib/flink-cep-1.20.1.jar:/opt/flink/lib/flink-connector-files-1.20.1.jar:/opt/flink/lib/flink-csv-1.20.1.jar:/opt/flink/lib/flink-json-1.20.1.jar:/opt/flink/lib/flink-scala_2.12-1.20.1.jar:/opt/flink/lib/flink-table-api-java-uber-1.20.1.jar:/opt/flink/lib/flink-table-planner-loader-1.20.1.jar:/opt/flink/lib/flink-table-runtime-1.20.1.jar:/opt/flink/lib/log4j-1.2-api-2.17.1.jar:/opt/flink/lib/log4j-api-2.17.1.jar:/opt/flink/lib/log4j-core-2.17.1.jar:/opt/flink/lib/log4j-slf4j-impl-2.17.1.jar:/tmp/hadoop/stax2-api-4.2.1.jar:/tmp/hadoop/hadoop-shaded-guava-1.1.1.jar:/tmp/hadoop/aws-java-sdk-bundle-1.11.1026.jar:/tmp/hadoop/commons-configuration2-2.8.0.jar:/tmp/hadoop/hadoop-auth-3.3.6.jar:/tmp/hadoop/hadoop-mapreduce-client-core-3.3.6.jar:/tmp/hadoop/woodstox-core-6.5.1.jar:/tmp/hadoop/hadoop-aws-3.3.6.jar:/tmp/hadoop/hadoop-common-3.3.6.jar:/tmp/hadoop/hadoop-hdfs-client-3.3.6.jar:/tmp/iceberg/iceberg-aws-bundle-1.8.1.jar:/tmp/iceberg/iceberg-flink-runtime-1.20-1.8.1.jar:/tmp/parquet/flink-sql-parquet-1.20.1.jar:/opt/flink/lib/flink-dist-1.20.1.jar
   ...
   ```

2. Without **CUSTOM_JARS_DIRS** Set (e.g., Commented Out):

   ```yaml
   x-common-environment: &flink_common_env_vars
     AWS_REGION: us-east-1
     #HADOOP_CONF_DIR: /opt/hadoop/etc/hadoop
     #CUSTOM_JARS_DIRS: "/tmp/hadoop;/tmp/iceberg;/tmp/parquet"
   ```

   JobManager Log Output:

   ```log
   Starting Job Manager
   Classpath Output:
   /opt/flink/lib/flink-cep-1.20.1.jar:/opt/flink/lib/flink-connector-files-1.20.1.jar:/opt/flink/lib/flink-csv-1.20.1.jar:/opt/flink/lib/flink-json-1.20.1.jar:/opt/flink/lib/flink-scala_2.12-1.20.1.jar:/opt/flink/lib/flink-table-api-java-uber-1.20.1.jar:/opt/flink/lib/flink-table-planner-loader-1.20.1.jar:/opt/flink/lib/flink-table-runtime-1.20.1.jar:/opt/flink/lib/log4j-1.2-api-2.17.1.jar:/opt/flink/lib/log4j-api-2.17.1.jar:/opt/flink/lib/log4j-core-2.17.1.jar:/opt/flink/lib/log4j-slf4j-impl-2.17.1.jar:/opt/flink/lib/flink-dist-1.20.1.jar
   ```

## Support

Any issues? Contact [support](https://factorhouse.io/support/) or view our [docs](https://docs.factorhouse.io/).

## License

This repository is released under the Apache 2.0 License.

Copyright © Factor House.
