import json
import urllib3
import time
import inspect
from pprint import pprint


def get_session_handle(http: urllib3.PoolManager, base_url: str) -> str:
    # Creates a session by sending a POST request to the Flink SQL REST API
    resp = http.request("POST", f"{base_url}/v1/sessions")
    data = json.loads(resp.data.decode())
    session_handle = data.get("sessionHandle")
    if not session_handle:
        raise RuntimeError("Failed to retrieve session handle.")
    print(f"\nSession Handle: {session_handle}")
    return session_handle


def get_operation_handle(
    http: urllib3.PoolManager, base_url: str, session_handle: str, statement: str
) -> str:
    # Submits a SQL statement and returns the operation handle to track its execution
    resp = http.request(
        "POST",
        f"{base_url}/v1/sessions/{session_handle}/statements/",
        body=json.dumps({"statement": statement}).encode("utf-8"),
        headers={"Content-Type": "application/json"},
    )
    data = json.loads(resp.data.decode())
    operation_handle = data.get("operationHandle")
    if not operation_handle:
        raise RuntimeError("Failed to retrieve operation handle.")
    print(f"\nOperation Handle: {operation_handle}")
    return operation_handle


def show_results(
    http: urllib3.PoolManager, base_url: str, session_handle: str, statement: str
):
    # Executes the SQL statement, waits for results, and handles pagination if necessary
    operation_handle = get_operation_handle(http, base_url, session_handle, statement)
    time.sleep(2)

    result_url = f"{base_url}/v1/sessions/{session_handle}/operations/{operation_handle}/result/0"
    while result_url:
        resp = http.request("GET", result_url)
        result = json.loads(resp.data.decode())
        pprint(result.get("results", result))
        next_uri = result.get("nextResultUri")
        result_url = f"{base_url}{next_uri}" if next_uri else None


if __name__ == "__main__":
    HTTP = urllib3.PoolManager()
    BASE_URL = "http://localhost:9090"

    session_handle = get_session_handle(HTTP, BASE_URL)

    create_stmt = inspect.cleandoc("""
        CREATE TABLE orders (
            order_number SMALLINT,
            price        DECIMAL(4,2),
            buyer        ROW<first_name STRING, last_name STRING>,
            order_time   TIMESTAMP(3)
        ) WITH (
            'connector' = 'datagen',
            'number-of-rows' = '10'
        );
    """)
    print("\nRunning CREATE statement...")
    show_results(HTTP, BASE_URL, session_handle, create_stmt)

    query_stmt = inspect.cleandoc("""
        SELECT order_number,
               price,
               SUBSTRING(buyer.first_name FROM 1 FOR 3) || ' ' || SUBSTRING(buyer.last_name FROM 1 FOR 4) AS buyer,
               order_time
        FROM orders;
    """)
    print("\nRunning SELECT query...")
    show_results(HTTP, BASE_URL, session_handle, query_stmt)
