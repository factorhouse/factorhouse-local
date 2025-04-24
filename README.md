![factorhouse](./images/factorhouse.jfif)

# Factor House Local

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
  && docker compose -p flex -f compose-flex-trial.yml up -d

## Start Flex on its own by setting USE_EXT=false
USE_EXT=false docker compose -f compose-flex-trial.yml up -d
```

## Stop/Remove Resources

```bash
## Stop and remove Kpow, Flex and associated resources
##  - Kpow should be removed last because it contains the Docker network
##  - Ensure to use the same project names
docker compose -p flex -f compose-flex-trial.yml down \
  && docker compose -p kpow -f compose-kpow-trial.yml down

## Stop and remove Flex on its own by setting USE_EXT=false
USE_EXT=false docker compose -f compose-flex-trial.yml down
```
