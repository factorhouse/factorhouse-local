FROM docker.getcollate.io/openmetadata/ingestion:1.11.4

USER root

COPY --chown=airflow:0 ./connectors/custom_flink /tmp/custom_flink

USER airflow

RUN pip install /tmp/custom_flink
