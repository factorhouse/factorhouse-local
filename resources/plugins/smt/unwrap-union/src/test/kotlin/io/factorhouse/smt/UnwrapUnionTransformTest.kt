package io.factorhouse.smt

import io.confluent.connect.avro.AvroData
import org.apache.avro.Schema
import org.apache.avro.generic.GenericData
import org.apache.avro.generic.GenericRecord
import org.apache.kafka.connect.data.Struct
import org.apache.kafka.connect.sink.SinkRecord
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test

class UnwrapUnionTransformTest {
    private val avroData = AvroData(100)
    private val transform = UnwrapUnionTransform<SinkRecord>()

    @Test
    fun `should unwrap Avro union schema with record`() {
        // Avro record schema
        val recordSchema = Schema.createRecord("TestRecord", null, "io.factorhouse.test", false)
        recordSchema.fields =
            listOf(
                Schema.Field("field1", Schema.create(Schema.Type.STRING), null, null as Any?),
            )

        // Avro union schema [null, recordSchema]
        val unionSchema = Schema.createUnion(listOf(Schema.create(Schema.Type.NULL), recordSchema))

        // Create Avro record
        val avroRecord: GenericRecord =
            GenericData.Record(recordSchema).apply {
                put("field1", "test-value")
            }

        // Wrap in union (simulated; the union itself isn't expressed in the object, only the schema)
        val connectData = avroData.toConnectData(unionSchema, avroRecord)
        val connectSchema = connectData.schema()
        val connectValue = connectData.value()

        // Create a SinkRecord
        val originalRecord =
            SinkRecord(
                "test-topic",
                0,
                null,
                null,
                connectSchema,
                connectValue,
                0,
            )

        // Apply transform
        val transformed = transform.apply(originalRecord)

        val resultSchema = transformed.valueSchema()
        val resultValue = transformed.value() as Struct

        println("New value schema: $resultSchema")
        println("New value: $resultValue")
        println("Field names: ${resultSchema.fields().map { it.name() }}")

        assertEquals("test-value", resultValue.getString("field1"))
        assertEquals("field1", resultSchema.fields()[0].name())
    }
}
