CREATE CATALOG demo_hv WITH (
  'type' = 'hive',
  'hive-conf-dir' = '/opt/flink/conf',
  'default-database' = 'default'
);

CREATE CATALOG demo_ib WITH (
  'type' = 'iceberg',
  'catalog-type' = 'hive',
  'uri' = 'thrift://hive-metastore:9083'
);