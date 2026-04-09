import json
import logging
from typing import Iterable, Optional, Union, Dict, Type
from typing_extensions import Annotated
from pydantic import Field, ConfigDict

from metadata.generated.schema.entity.automations.workflow import (
    Workflow as AutomationWorkflow,
)
from metadata.generated.schema.entity.data.pipeline import Pipeline
from metadata.generated.schema.entity.data.table import Table
from metadata.generated.schema.entity.data.topic import Topic
from metadata.generated.schema.entity.data.container import Container
from metadata.generated.schema.api.lineage.addLineage import AddLineageRequest
from metadata.generated.schema.type.entityLineage import EntitiesEdge
from metadata.generated.schema.type.entityReference import EntityReference
from metadata.generated.schema.entity.services.connections.pipeline.flinkConnection import (
    FlinkConnection,
)
from metadata.generated.schema.entity.services.connections.pipeline.customPipelineConnection import (
    CustomPipelineConnection,
    CustomPipelineType,
)
from metadata.generated.schema.entity.services.connections.testConnectionResult import (
    TestConnectionResult,
)
from metadata.generated.schema.metadataIngestion.workflow import (
    Source as WorkflowSource,
)
from metadata.generated.schema.entity.services.pipelineService import (
    PipelineServiceType,
)
from metadata.ingestion.api.models import Either
from metadata.ingestion.api.steps import InvalidSourceException
from metadata.ingestion.connections.test_connections import test_connection_steps
from metadata.ingestion.ometa.ometa_api import OpenMetadata
from metadata.utils.service_spec import BaseSpec
from metadata.utils.constants import THREE_MIN
from metadata.utils import fqn
from metadata.ingestion.source.pipeline.flink.metadata import FlinkSource
from metadata.ingestion.source.pipeline.flink.client import FlinkClient
from metadata.ingestion.source.pipeline.flink.models import FlinkPipeline

logger = logging.getLogger("CustomFlinkSource")

# Map string types from JSON to OpenMetadata Entity Classes
ENTITY_TYPE_MAP: Dict[str, Type] = {
    "table": Table,
    "topic": Topic,
    "pipeline": Pipeline,
    "container": Container,
}


class CustomFlinkConnection(FlinkConnection):
    model_config = ConfigDict(extra="allow")

    type: Annotated[
        CustomPipelineType,
        Field(CustomPipelineType.CustomPipeline, description="Service Type"),
    ]

    sourcePythonClass: Optional[str] = Field(
        None, description="Path to the Python class implementing the source"
    )


class CustomFlinkSource(FlinkSource):
    @classmethod
    def create(
        cls, config_dict, metadata: OpenMetadata, pipeline_name: Optional[str] = None
    ):
        config: WorkflowSource = WorkflowSource.model_validate(config_dict)
        connection = config.serviceConnection.root.config

        if isinstance(connection, CustomPipelineConnection):
            options = (
                connection.connectionOptions.root
                if connection.connectionOptions
                else {}
            )

            raw_lineage = options.get("custom_lineage_config", {})
            parsed_lineage = {}

            if isinstance(raw_lineage, str):
                try:
                    parsed_lineage = json.loads(raw_lineage)
                    logger.info("Successfully parsed custom lineage config JSON.")
                except Exception as e:
                    logger.error(f"Failed to parse lineage config: {e}")
                    parsed_lineage = {}
            elif isinstance(raw_lineage, dict):
                parsed_lineage = raw_lineage

            custom_connection = CustomFlinkConnection(
                type=CustomPipelineType.CustomPipeline,
                hostPort=options.get("hostPort"),
                verifySSL=options.get("verifySSL", "no-ssl"),
                sslConfig=options.get("sslConfig"),
                supportsMetadataExtraction=connection.supportsMetadataExtraction,
                sourcePythonClass=connection.sourcePythonClass,
            )

            config.serviceConnection.root.config = custom_connection
            cls.custom_lineage_config = parsed_lineage

        elif not isinstance(connection, FlinkConnection):
            raise InvalidSourceException(
                f"Expected CustomPipelineConnection or FlinkConnection, but got {type(connection)}"
            )

        return cls(config, metadata)

    def yield_pipeline_lineage_details(
        self, pipeline_details: FlinkPipeline
    ) -> Iterable[Either[AddLineageRequest]]:
        # Standard Lineage
        try:
            yield from super().yield_pipeline_lineage_details(pipeline_details)
        except Exception as e:
            logger.debug(f"Standard lineage skipped: {e}")

        # Generic Custom Lineage
        pipeline_name = pipeline_details.name
        lineage_map = getattr(self, "custom_lineage_config", {})

        if pipeline_name in lineage_map:
            config = lineage_map[pipeline_name]

            # Build Pipeline FQN
            pipeline_fqn = fqn.build(
                self.metadata,
                entity_type=Pipeline,
                service_name=self.context.get().pipeline_service,
                pipeline_name=pipeline_name,
            )

            # Get Pipeline Entity
            pipeline_entity = self.metadata.get_by_name(
                entity=Pipeline, fqn=pipeline_fqn
            )

            if pipeline_entity:
                pipeline_ref = EntityReference(id=pipeline_entity.id, type="pipeline")

                # Helper to process lists
                def process_direction(items, direction="upstream"):
                    for item in items:
                        # Extract data from new generic JSON structure
                        target_fqn = item.get("fqn")
                        target_type_str = item.get("type", "").lower()

                        target_class = ENTITY_TYPE_MAP.get(target_type_str)

                        if not target_class or not target_fqn:
                            logger.warning(f"Invalid config item: {item}")
                            continue

                        # Fetch the entity (Topic, Table, etc.)
                        target_entity = self.metadata.get_by_name(
                            entity=target_class, fqn=target_fqn
                        )

                        if target_entity:
                            target_ref = EntityReference(
                                id=target_entity.id, type=target_type_str
                            )

                            # Determine Edge Direction
                            if direction == "upstream":
                                from_ref = target_ref
                                to_ref = pipeline_ref
                            else:
                                from_ref = pipeline_ref
                                to_ref = target_ref

                            logger.info(
                                f"Yielding {direction}: {from_ref.type} -> {to_ref.type}"
                            )

                            yield Either(
                                right=AddLineageRequest(
                                    edge=EntitiesEdge(
                                        fromEntity=from_ref, toEntity=to_ref
                                    )
                                )
                            )
                        else:
                            logger.warning(
                                f"Entity not found: {target_type_str} - {target_fqn}"
                            )

                # Process Upstream
                yield from process_direction(
                    config.get("upstream", []), direction="upstream"
                )

                # Process Downstream
                yield from process_direction(
                    config.get("downstream", []), direction="downstream"
                )


def get_connection(
    connection: Union[CustomFlinkConnection, CustomPipelineConnection],
) -> FlinkClient:
    if isinstance(connection, CustomPipelineConnection):
        options = (
            connection.connectionOptions.root if connection.connectionOptions else {}
        )
        connection = CustomFlinkConnection(
            type=CustomPipelineType.CustomPipeline,
            hostPort=options.get("hostPort"),
            verifySSL=options.get("verifySSL", "no-ssl"),
            sslConfig=options.get("sslConfig"),
        )
    return FlinkClient(connection)


def test_connection(
    metadata: OpenMetadata,
    client: FlinkClient,
    service_connection: Union[CustomFlinkConnection, CustomPipelineConnection],
    automation_workflow: Optional[AutomationWorkflow] = None,
    timeout_seconds: Optional[int] = THREE_MIN,
) -> TestConnectionResult:
    return test_connection_steps(
        metadata=metadata,
        test_fn={"GetPipelines": client.get_jobs},
        service_type=PipelineServiceType.Flink.value,
        automation_workflow=automation_workflow,
        timeout_seconds=timeout_seconds,
    )


ServiceSpec = BaseSpec(metadata_source_class=CustomFlinkSource)
