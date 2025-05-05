## QuickStart Examples

1. [Kafka Iceberg Sink](./kafka-iceberg-sink.md)  
   Streams data from Kafka into an Apache Iceberg table stored in MinIO. Topics are created, an Iceberg table is defined via Spark SQL, and the Iceberg Sink Connector is deployed and monitored using **Kpow**. Ingested records are validated in the MinIO-backed Iceberg table.

2. [Flink SQL Client](./flink-sql-client.md)  
   Uses the [Flink Faker](https://github.com/knaufk/flink-faker) connector to simulate streaming data with randomized fields. Demonstrates creating a mock `orders` table and running a tumbling window Top-N query to identify top suppliers, showcasing real-time Flink SQL analytics.

3. [Flink SQL Gateway](./flink_sql_gateway.md)  
   A Python script that interacts with Flink SQL Gateway via REST API using `urllib3`. It automates session handling, statement submission (e.g., with `datagen`), and paginated result fetching, enabling programmatic control over Flink SQL.

4. [Flink Parquet Sink](./flink-sql-sink-parquet.md)  
   Shows how to write streaming data to Parquet files in MinIO using Flink SQL. Synthetic data is generated via Flink Faker, partitioned by time, and stored using the filesystem connector. Checkpointing ensures reliability; results are visualized with **Flex**.

5. [Flink Iceberg Sink](./flink-sql-sink-iceberg.md)  
   Demonstrates setting up an Iceberg catalog on MinIO and creating a Parquet-backed `db.users` table. Sample records are inserted and queried via Flink SQL, validating the use of Iceberg as a Flink table sink with S3-compatible storage.

6. [Spark SQL Iceberg](./spark-sql-iceberg.md)  
   Illustrates using Spark SQL with an Iceberg catalog. After verifying the `demo` catalog, a `db.users` table is created and queried, confirming successful data insertion and storage in MinIO through Iceberg.

7. [Pinot Analytics](./pinot-analytics.md)  
   Walks through table creation, batch ingestion, and analytical querying in Apache Pinot. A `baseballStats` table is set up using schema and config files, data is loaded via ingestion job, and queries are run to aggregate and display player stats.
