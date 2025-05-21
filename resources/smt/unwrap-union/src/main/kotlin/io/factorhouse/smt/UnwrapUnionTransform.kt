package io.factorhouse.smt

import io.confluent.connect.avro.AvroData
import mu.KotlinLogging
import org.apache.avro.Schema
import org.apache.kafka.common.config.ConfigDef
import org.apache.kafka.connect.connector.ConnectRecord
import org.apache.kafka.connect.data.Struct
import org.apache.kafka.connect.transforms.Transformation

class UnwrapUnionTransform<R : ConnectRecord<R>> : Transformation<R> {
    private val logger = KotlinLogging.logger {}
    private val avroData = AvroData(100)

    override fun configure(configs: Map<String?, *>?) {
        logger.debug { "UnwrapUnionTransform configured with: $configs" }
    }

    override fun apply(record: R): R {
        val value = record.value()
        val connectSchema = record.valueSchema()

        if (value == null || connectSchema == null) {
            logger.debug { "Skipping null value or schema." }
            return record
        }

        val avroSchema = avroData.fromConnectSchema(connectSchema)

        if (avroSchema.type != Schema.Type.UNION) {
            logger.debug { "Schema is not UNION; skipping." }
            return record
        }

        val nonNullAvroSchema = avroSchema.types.find { it.type != Schema.Type.NULL }
        if (nonNullAvroSchema == null) {
            logger.warn { "No non-null schema found in union; skipping." }
            return record
        }

        val newSchema = avroData.toConnectSchema(nonNullAvroSchema).schema()

        val originalStruct = value as? Struct
        if (originalStruct == null) {
            logger.warn { "Value is not Struct: ${value::class}; skipping." }
            return record
        }

        val newStruct = Struct(newSchema)
        newSchema.fields().forEach { field ->
            newStruct.put(field, originalStruct.get(field.name()))
        }

        logger.info { "Unwrapped record for topic ${record.topic()}" }

        return record.newRecord(
            record.topic(),
            record.kafkaPartition(),
            record.keySchema(),
            record.key(),
            newSchema,
            newStruct,
            record.timestamp(),
        )
    }

    override fun config(): ConfigDef = ConfigDef()

    override fun close() {
        logger.debug { "UnwrapUnionTransform closed." }
    }
}
