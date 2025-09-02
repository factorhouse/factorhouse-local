package io.factorhouse.smt

import io.confluent.kafka.schemaregistry.client.CachedSchemaRegistryClient
import io.confluent.kafka.schemaregistry.client.SchemaRegistryClient
import io.confluent.kafka.schemaregistry.client.rest.RestService
import io.confluent.kafka.schemaregistry.client.rest.exceptions.RestClientException
import io.openlineage.client.OpenLineage
import io.openlineage.client.transports.HttpTransport
import org.apache.avro.Schema
import org.apache.kafka.common.config.ConfigDef
import org.apache.kafka.connect.connector.ConnectRecord
import org.apache.kafka.connect.transforms.Transformation
import org.slf4j.LoggerFactory
import java.net.URI
import java.time.ZoneOffset
import java.time.ZonedDateTime
import java.util.UUID

class OpenLineageLifecycleSmt<R : ConnectRecord<R>> : Transformation<R> {
    private val logger = LoggerFactory.getLogger(OpenLineageLifecycleSmt::class.java)
    private lateinit var ol: OpenLineage
    private lateinit var transport: HttpTransport
    private lateinit var jobNamespace: String
    private lateinit var kafkaNamespace: String
    private lateinit var jobName: String
    private lateinit var runId: UUID
    private lateinit var connectorClass: String
    private lateinit var topics: List<String>
    private lateinit var icebergTables: List<String>

    // Sink-specific properties
    private var s3Bucket: String? = null
    private var icebergCatalog: String? = null
    private var icebergCatalogUri: String? = null

    // State Machine Flags
    private var isConfigured: Boolean = false
    private var hasEmittedStartEvent: Boolean = false
    private var hasEmittedDataset: Boolean = false

    private var keySchemaRegistryClient: SchemaRegistryClient? = null
    private var valueSchemaRegistryClient: SchemaRegistryClient? = null
    private var readKeySchema: Boolean = false
    private var readValueSchema: Boolean = false

    companion object {
        private const val KEY_PREFIX = "key.converter."
        private const val VALUE_PREFIX = "value.converter."
        private const val DEFAULT_CACHE_CAPACITY = 1000
        private const val CONNECTOR_NAME_CONFIG = "connector.name"
        private const val CONNECTOR_CLASS_CONFIG = "connector.class"
        private const val TOPICS_CONFIG = "topics"
        private const val S3_BUCKET_CONFIG = "s3.bucket.name"
        private const val ICEBERG_CATALOG_CONFIG = "iceberg.catalog"
        private const val ICEBERG_CATALOG_URI_CONFIG = "iceberg.catalog.uri"
        private const val ICEBERG_TABLES_CONFIG = "iceberg.tables"

        val CONFIG_DEF: ConfigDef =
            ConfigDef()
                .define(
                    CONNECTOR_NAME_CONFIG,
                    ConfigDef.Type.STRING,
                    null,
                    ConfigDef.Importance.HIGH,
                    "The name of the Kafka Connect connector.",
                ).define(
                    CONNECTOR_CLASS_CONFIG,
                    ConfigDef.Type.STRING,
                    null,
                    ConfigDef.Importance.HIGH,
                    "The class of the Kafka Connect connector.",
                ).define(
                    TOPICS_CONFIG,
                    ConfigDef.Type.STRING,
                    "",
                    ConfigDef.Importance.HIGH,
                    "Comma-separated list of Kafka topics used by the connector.",
                ).define(
                    S3_BUCKET_CONFIG,
                    ConfigDef.Type.STRING,
                    "",
                    ConfigDef.Importance.MEDIUM,
                    "The S3 bucket name for S3 sink connectors.",
                ).define(
                    ICEBERG_CATALOG_CONFIG,
                    ConfigDef.Type.STRING,
                    "",
                    ConfigDef.Importance.MEDIUM,
                    "The Iceberg catalog name for Iceberg sink connectors.",
                ).define(
                    ICEBERG_CATALOG_URI_CONFIG,
                    ConfigDef.Type.STRING,
                    "",
                    ConfigDef.Importance.MEDIUM,
                    "The full URI of the Iceberg catalog (e.g., thrift://localhost:9083).",
                ).define(
                    ICEBERG_TABLES_CONFIG,
                    ConfigDef.Type.STRING,
                    "",
                    ConfigDef.Importance.MEDIUM,
                    "Comma-separated list of target Iceberg tables, corresponding to the 'topics' list.",
                ).define(
                    KEY_PREFIX + "schema.read",
                    ConfigDef.Type.BOOLEAN,
                    false,
                    ConfigDef.Importance.MEDIUM,
                    "Whether to read the key schema from the registry.",
                ).define(
                    KEY_PREFIX + "schema.registry.url",
                    ConfigDef.Type.STRING,
                    "",
                    ConfigDef.Importance.MEDIUM,
                    "URL for key schema registry.",
                ).define(
                    KEY_PREFIX + "basic.auth.credentials.source",
                    ConfigDef.Type.STRING,
                    "",
                    ConfigDef.Importance.MEDIUM,
                    "Auth source for key schema registry.",
                ).define(
                    KEY_PREFIX + "basic.auth.user.info",
                    ConfigDef.Type.PASSWORD,
                    "",
                    ConfigDef.Importance.MEDIUM,
                    "Auth user info for key schema registry.",
                ).define(
                    VALUE_PREFIX + "schema.read",
                    ConfigDef.Type.BOOLEAN,
                    true,
                    ConfigDef.Importance.MEDIUM,
                    "Whether to read the value schema from the registry.",
                ).define(
                    VALUE_PREFIX + "schema.registry.url",
                    ConfigDef.Type.STRING,
                    "",
                    ConfigDef.Importance.MEDIUM,
                    "URL for value schema registry.",
                ).define(
                    VALUE_PREFIX + "basic.auth.credentials.source",
                    ConfigDef.Type.STRING,
                    "",
                    ConfigDef.Importance.MEDIUM,
                    "Auth source for value schema registry.",
                ).define(
                    VALUE_PREFIX + "basic.auth.user.info",
                    ConfigDef.Type.PASSWORD,
                    "",
                    ConfigDef.Importance.MEDIUM,
                    "Auth user info for value schema registry.",
                )
    }

    override fun configure(configs: Map<String, *>) {
        val originalJobName = configs[CONNECTOR_NAME_CONFIG]?.toString()
        if (originalJobName.isNullOrBlank()) {
            logger.warn("OpenLineage SMT is being configured without a '${CONNECTOR_NAME_CONFIG}' property. Skipping initialization.")
            return
        }

        this.jobName = originalJobName
        logger.info("OpenLineage SMT configuring for job '$jobName'.")

        val lineageUri = URI(System.getenv("OPENLINEAGE_URL") ?: "http://marquez-api:5000")
        jobNamespace = System.getenv("OPENLINEAGE_NAMESPACE") ?: "fh-local"
        kafkaNamespace = "kafka://${System.getenv("BOOTSTRAP") ?: "kafka-1:19092"}"

        ol = OpenLineage(URI.create("https://github.com/OpenLineage/OpenLineage"))
        transport = HttpTransport.builder().uri(lineageUri).build()

        this.connectorClass = configs[CONNECTOR_CLASS_CONFIG]?.toString() ?: ""
        this.topics = configs[TOPICS_CONFIG]
            ?.toString()
            ?.split(",")
            ?.map { it.trim() }
            ?.filter { it.isNotEmpty() } ?: emptyList()
        this.s3Bucket = configs[S3_BUCKET_CONFIG]?.toString()
        this.icebergCatalog = configs[ICEBERG_CATALOG_CONFIG]?.toString()
        this.icebergCatalogUri = configs[ICEBERG_CATALOG_URI_CONFIG]?.toString()
        this.icebergTables = configs[ICEBERG_TABLES_CONFIG]
            ?.toString()
            ?.split(",")
            ?.map { it.trim() }
            ?.filter { it.isNotEmpty() } ?: emptyList()

        this.readKeySchema = configs[KEY_PREFIX + "schema.read"]?.toString()?.toBoolean() ?: false
        this.readValueSchema = configs[VALUE_PREFIX + "schema.read"]?.toString()?.toBoolean() ?: true
        if (readKeySchema) this.keySchemaRegistryClient = initializeSchemaRegistryClient(KEY_PREFIX, configs)
        if (readValueSchema) this.valueSchemaRegistryClient = initializeSchemaRegistryClient(VALUE_PREFIX, configs)

        isConfigured = true
    }

    override fun apply(record: R): R {
        if (!isConfigured) return record

        // On first deployment, schemas may not yet exist, so OpenLineage emission waits until all schemas are available.
        // This ensures the initial dataset versions align with the schema registry.
        // On subsequent deployments, however, schemas may have changed.
        // Currently, only schema existence is checked, not their correctness, which can result in outdated schemas being used for dataset version creation.
        // Additional logic is needed to ensure the correct, up-to-date schemas are used.
        val schemaIsReady = checkIfSchemaIsReady()
        if (schemaIsReady) {
            if (!hasEmittedStartEvent) {
                try {
                    logger.info("First record received for job '$jobName'. Emitting minimal START event.")
                    this.runId = UUID.randomUUID()
                    val runningEvent = buildRichLifeCycleEvent()
                    transport.emit(runningEvent)
                    logger.info("OpenLineage RUNNING event emitted for job '$jobName' with runId '$runId'.")
                    hasEmittedStartEvent = true
                } catch (e: Exception) {
                    logger.error("Failed to emit OpenLineage START event for job '$jobName'", e)
                }
            }
        } else {
            logger.info("Not every schema is yet to be available. OpenLineage metadata is not emitted.")
        }

        try {
            return record
        } catch (e: Exception) {
            logger.error("Caught exception in OpenLineage SMT for job '$jobName'. Emitting FAIL event.", e)
            try {
                if (this::runId.isInitialized) {
                    val failEvent = buildMinimalLifeCycleEvent(OpenLineage.RunEvent.EventType.FAIL)
                    transport.emit(failEvent)
                }
            } catch (olError: Exception) {
                logger.error("Failed to emit OpenLineage FAIL event", olError)
            }
            throw e
        }
    }

    override fun close() {
        if (!isConfigured || !hasEmittedStartEvent) {
            // This case handles SMT instances that were configured but never processed a record.
            if (isConfigured) {
                logger.info("OpenLineage SMT closing for job '$jobName', but no records were processed. No events will be emitted.")
            }
            return
        }

        logger.info("OpenLineage SMT closing for job '$jobName'. Emitting minimal COMPLETE event.")
        try {
            // A Kafka Connect SMT cannot distinguish between a user-initiated stop (ABORT)
            // and a graceful shutdown for reconfiguration. In a streaming context, any clean
            // shutdown is considered a completion of that specific run. Therefore, we always
            // emit a COMPLETE event.
            val completeEvent = buildMinimalLifeCycleEvent(OpenLineage.RunEvent.EventType.COMPLETE)
            transport.emit(completeEvent)
        } catch (e: Exception) {
            logger.error("Failed to emit OpenLineage COMPLETE event for job '$jobName'", e)
        } finally {
            if (this::transport.isInitialized) {
                transport.close()
            }
            // Reset the state flags to allow this instance to be cleanly reused by Kafka Connect.
            this.hasEmittedStartEvent = false
            this.hasEmittedDataset = false
        }
    }

    private fun checkIfSchemaIsReady(): Boolean {
        if (!readKeySchema && !readValueSchema) return true
        return topics.all { topic ->
            (!readKeySchema || schemaExists(topic, "key")) && (!readValueSchema || schemaExists(topic, "value"))
        }
    }

    private fun schemaExists(
        topicName: String,
        type: String,
    ): Boolean {
        val client = if (type == "key") keySchemaRegistryClient else valueSchemaRegistryClient
        if (client == null) return false
        val subject = "$topicName-$type"
        return try {
            client.getLatestSchemaMetadata(subject)
            true
        } catch (_: RestClientException) {
            false
        } catch (e: Exception) {
            logger.error("Unexpected error checking schema for subject '$subject'", e)
            false
        }
    }

    private fun buildMinimalLifeCycleEvent(eventType: OpenLineage.RunEvent.EventType): OpenLineage.RunEvent {
        val jobTypeFacet = ol.newJobTypeJobFacet("STREAMING", "KAFKA_CONNECT", "CUSTOM_CONNECTOR_TASK")
        return ol
            .newRunEventBuilder()
            .eventTime(ZonedDateTime.now(ZoneOffset.UTC))
            .eventType(eventType)
            .run(ol.newRunBuilder().runId(this.runId).build())
            .job(
                ol
                    .newJobBuilder()
                    .namespace(jobNamespace)
                    .name(this.jobName)
                    .facets(ol.newJobFacetsBuilder().jobType(jobTypeFacet).build())
                    .build(),
            ).build()
    }

    private fun buildRichLifeCycleEvent(): OpenLineage.RunEvent {
        val jobTypeFacet = ol.newJobTypeJobFacet("STREAMING", "KAFKA_CONNECT", "CUSTOM_CONNECTOR_TASK")

        return ol
            .newRunEventBuilder()
            .eventTime(ZonedDateTime.now(ZoneOffset.UTC))
            .eventType(OpenLineage.RunEvent.EventType.RUNNING) // This method is now only for RUNNING events
            .run(ol.newRunBuilder().runId(this.runId).build())
            .job(
                ol
                    .newJobBuilder()
                    .namespace(jobNamespace)
                    .name(this.jobName)
                    .facets(ol.newJobFacetsBuilder().jobType(jobTypeFacet).build())
                    .build(),
            ).inputs(buildInputs())
            .outputs(buildOutputs())
            .build()
    }

    private fun buildInputs(): List<OpenLineage.InputDataset> =
        if (isSink()) {
            topics.map { topic -> buildKafkaDataset(topic) as OpenLineage.InputDataset }
        } else {
            emptyList()
        }

    private fun buildOutputs(): List<OpenLineage.OutputDataset> {
        val inputTopicSchema = if (isSink() && topics.isNotEmpty()) buildSchemaFacet(topics.first()) else null

        return when {
            isSource() -> topics.map { topic -> buildKafkaDataset(topic) as OpenLineage.OutputDataset }
            isSink("S3Sink") -> {
                val bucket = this.s3Bucket ?: "unknown"
                val dsFacet = ol.newDatasourceDatasetFacet("s3", URI.create("s3://$bucket"))
                val facets =
                    ol
                        .newDatasetFacetsBuilder()
                        .schema(inputTopicSchema)
                        .dataSource(dsFacet)
                        .build()
                topics.map { topic ->
                    ol
                        .newOutputDatasetBuilder()
                        .namespace("s3://$bucket")
                        .name(topic)
                        .facets(facets)
                        .build()
                }
            }
            isSink("IcebergSink") -> {
                val icebergNamespace = this.icebergCatalogUri ?: "iceberg://${this.icebergCatalog ?: "unknown"}"
                val dsFacet = ol.newDatasourceDatasetFacet("iceberg", URI.create(icebergNamespace))
                val facets =
                    ol
                        .newDatasetFacetsBuilder()
                        .schema(inputTopicSchema)
                        .dataSource(dsFacet)
                        .build()
                icebergTables.map { table ->
                    ol
                        .newOutputDatasetBuilder()
                        .namespace(icebergNamespace)
                        .name(table)
                        .facets(facets)
                        .build()
                }
            }
            else -> emptyList()
        }
    }

    private fun buildKafkaDataset(topicName: String): OpenLineage.Dataset {
        val schemaFacet = buildSchemaFacet(topicName)
        val dsFacet = ol.newDatasourceDatasetFacet("kafka", URI.create(kafkaNamespace))
        val facets =
            ol
                .newDatasetFacetsBuilder()
                .schema(schemaFacet)
                .dataSource(dsFacet)
                .build()

        return if (isSource()) {
            ol
                .newOutputDatasetBuilder()
                .namespace(kafkaNamespace)
                .name(topicName)
                .facets(facets)
                .build()
        } else {
            ol
                .newInputDatasetBuilder()
                .namespace(kafkaNamespace)
                .name(topicName)
                .facets(facets)
                .build()
        }
    }

    private fun initializeSchemaRegistryClient(
        prefix: String,
        configs: Map<String, *>,
    ): SchemaRegistryClient? {
        val srUrl = configs[prefix + "schema.registry.url"]?.toString() ?: return null
        return try {
            val srConfig = mutableMapOf<String, Any>()
            val authSource = configs[prefix + "basic.auth.credentials.source"]?.toString()
            if (authSource == "USER_INFO") {
                srConfig["basic.auth.credentials.source"] = authSource
                srConfig["basic.auth.user.info"] = configs[prefix + "basic.auth.user.info"]?.toString() ?: ""
            }
            val restService = RestService(listOf(srUrl))
            restService.configure(srConfig)
            CachedSchemaRegistryClient(restService, DEFAULT_CACHE_CAPACITY)
        } catch (e: Exception) {
            logger.error("Failed to initialize Schema Registry client for prefix '$prefix'.", e)
            null
        }
    }

    private fun buildSchemaFacet(topicName: String): OpenLineage.SchemaDatasetFacet? {
        val keyFields = if (readKeySchema) buildSchemaFields(topicName, "key") else emptyList()
        val valueFields = if (readValueSchema) buildSchemaFields(topicName, "value") else emptyList()
        val allFields = keyFields + valueFields
        return if (allFields.isNotEmpty()) ol.newSchemaDatasetFacetBuilder().fields(allFields).build() else null
    }

    private fun buildSchemaFields(
        topicName: String,
        type: String,
    ): List<OpenLineage.SchemaDatasetFacetFields> {
        val client = if (type == "key") keySchemaRegistryClient else valueSchemaRegistryClient
        if (client == null) return emptyList()
        val subject = "$topicName-$type"
        return try {
            logger.info("Fetching schema for subject '$subject'.")
            val schemaMetadata = client.getLatestSchemaMetadata(subject)
            val parsedSchema = client.getSchemaById(schemaMetadata.id)
            if (parsedSchema.schemaType() == "AVRO") {
                val avroSchema = parsedSchema.rawSchema() as Schema
                avroSchema.fields.map { field ->
                    val fieldSchema = field.schema()
                    val fieldType: String
                    // Unwrap nullable union types to get the base type.
                    if (fieldSchema.isUnion) {
                        val nonNullType = fieldSchema.types.find { it.type != Schema.Type.NULL }
                        fieldType = nonNullType?.type?.name ?: fieldSchema.type.name
                    } else {
                        fieldType = fieldSchema.type.name
                    }

                    ol
                        .newSchemaDatasetFacetFieldsBuilder()
                        .name(field.name())
                        .type(fieldType.lowercase())
                        .build()
                }
            } else {
                emptyList()
            }
        } catch (e: RestClientException) {
            logger.warn("Could not find schema for subject '$subject': ${e.message}")
            emptyList()
        } catch (e: Exception) {
            logger.error("Error fetching schema for subject '$subject'.", e)
            emptyList()
        }
    }

    private fun isSink(sinkType: String? = null): Boolean =
        if (sinkType != null) {
            connectorClass.contains(sinkType, ignoreCase = true)
        } else {
            connectorClass.contains("Sink", ignoreCase = true)
        }

    private fun isSource(): Boolean =
        connectorClass.contains("Source", ignoreCase = true) || connectorClass.contains("DataGen", ignoreCase = true)

    override fun config(): ConfigDef = CONFIG_DEF
}
