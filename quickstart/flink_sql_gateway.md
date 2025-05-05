## Flink SQL Gateway

[flink_sql_gateway.py](./flink_sql_gateway.py) interacts with the **Flink SQL Gateway REST API** to perform the following tasks:

1. **Create a Session**

   - Uses a POST request to `/v1/sessions` to create a new Flink SQL session.
   - Retrieves and returns the `sessionHandle`.

2. **Submit SQL Statements**

   - Sends SQL statements to the Flink session using a POST request.
   - Returns an `operationHandle` to track execution status.

3. **Fetch and Display Results**
   - Polls the results endpoint using the `operationHandle`.
   - Supports paginated results using `nextResultUri`.
   - Prints results using `pprint`.

### SQL Statements Executed:

- `CREATE TABLE orders`:
  - Uses the `datagen` connector to generate 10 rows of sample data.
- `SELECT` query:
  - Selects and formats data from the `orders` table.

We can execute the script from your terminal with the following command:

```bash
python quickstart/flink_sql_gateway.py
```

The logs will resemble the following:

```bash
Session Handle: af5f1755-21e8-4a0e-82fe-d719d1c415fc

Running CREATE statement...

Operation Handle: df4ccade-e72f-4e6f-bf9e-d5630cca7d4a
{'columns': [{'comment': None,
              'logicalType': {'length': 2147483647,
                              'nullable': True,
                              'type': 'VARCHAR'},
              'name': 'result'}],
 'data': [{'fields': ['OK'], 'kind': 'INSERT'}],
 'rowFormat': 'JSON'}
{'columns': [{'comment': None,
              'logicalType': {'length': 2147483647,
                              'nullable': True,
                              'type': 'VARCHAR'},
              'name': 'result'}],
 'data': [],
 'rowFormat': 'JSON'}

Running SELECT query...

Operation Handle: 9ad2ecb2-c7c0-438b-b968-7a2de0e464ea
{'columns': [{'comment': None,
              'logicalType': {'nullable': True, 'type': 'SMALLINT'},
              'name': 'order_number'},
             {'comment': None,
              'logicalType': {'nullable': True,
                              'precision': 4,
                              'scale': 2,
                              'type': 'DECIMAL'},
              'name': 'price'},
             {'comment': None,
              'logicalType': {'length': 2147483647,
                              'nullable': True,
                              'type': 'VARCHAR'},
              'name': 'buyer'},
             {'comment': None,
              'logicalType': {'nullable': True,
                              'precision': 3,
                              'type': 'TIMESTAMP_WITHOUT_TIME_ZONE'},
              'name': 'order_time'}],
 'data': [{'fields': [21984, 96.34, '442 8fac', '2025-05-05T05:30:35.966'],
           'kind': 'INSERT'},
          {'fields': [27054, 30.35, '732 7b08', '2025-05-05T05:30:35.967'],
           'kind': 'INSERT'},
          {'fields': [-29012, 5.9, '21f 91c4', '2025-05-05T05:30:35.967'],
           'kind': 'INSERT'},
          {'fields': [9619, 2.01, 'f10 5d17', '2025-05-05T05:30:35.967'],
           'kind': 'INSERT'},
          {'fields': [5319, 3.92, '579 f17b', '2025-05-05T05:30:35.967'],
           'kind': 'INSERT'},
          {'fields': [13830, 54.98, '9db 2654', '2025-05-05T05:30:35.967'],
           'kind': 'INSERT'},
          {'fields': [27488, 68.9, '46c bfb4', '2025-05-05T05:30:35.968'],
           'kind': 'INSERT'},
          {'fields': [3936, 98.91, '2e3 5fcc', '2025-05-05T05:30:35.968'],
           'kind': 'INSERT'},
          {'fields': [-28836, 40.85, 'c0e e48d', '2025-05-05T05:30:35.968'],
           'kind': 'INSERT'},
          {'fields': [5872, 78.11, '0f9 0e26', '2025-05-05T05:30:35.969'],
           'kind': 'INSERT'}],
 'rowFormat': 'JSON'}
{'columns': [{'comment': None,
              'logicalType': {'nullable': True, 'type': 'SMALLINT'},
              'name': 'order_number'},
             {'comment': None,
              'logicalType': {'nullable': True,
                              'precision': 4,
                              'scale': 2,
                              'type': 'DECIMAL'},
              'name': 'price'},
             {'comment': None,
              'logicalType': {'length': 2147483647,
                              'nullable': True,
                              'type': 'VARCHAR'},
              'name': 'buyer'},
             {'comment': None,
              'logicalType': {'nullable': True,
                              'precision': 3,
                              'type': 'TIMESTAMP_WITHOUT_TIME_ZONE'},
              'name': 'order_time'}],
 'data': [],
 'rowFormat': 'JSON'}
```
