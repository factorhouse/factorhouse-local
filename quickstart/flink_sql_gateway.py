import json
import urllib3
import time
import inspect
from pprint import pprint


def get_session_handle(http: urllib3.PoolManager, base_url: str):
    resp = http.request("POST", f"{base_url}/v1/sessions")
    session_handle = json.loads(resp.data.decode())["sessionHandle"]
    print(f"Session Handle - {session_handle}")
    return session_handle


def get_operation_handle(
    http: urllib3.PoolManager,
    base_url: str,
    session_handle: str,
    statement: str,
):
    resp = http.request(
        "POST",
        f"{base_url}/v1/sessions/{session_handle}/statements/",
        body=json.dumps({"statement": statement}).encode("utf-8"),
        headers={"Content-Type": "application/json"},
    )
    operation_handle = json.loads(resp.data.decode())["operationHandle"]
    print(f"Operation Handle - {operation_handle}")
    return operation_handle


def get_results(
    http: urllib3.PoolManager,
    base_url: str,
    session_handle: str,
    statement: str,
):
    operation_handle = get_operation_handle(http, base_url, session_handle, statement)
    time.sleep(2)
    resp = http.request(
        "GET",
        f"{base_url}/v1/sessions/{session_handle}/operations/{operation_handle}/result/0",
    )
    result = json.loads(resp.data.decode())
    pprint(result)
    while True:
        if result.get("nextResultUri") is not None:
            resp = http.request("GET", f"{base_url}{result['nextResultUri']}")
            result = json.loads(resp.data.decode())
            pprint(result)
        else:
            break


if __name__ == "__main__":
    HTTP = urllib3.PoolManager()
    BASE_URL = "http://localhost:9090"

    session_handle = get_session_handle(HTTP, BASE_URL)

    CREATE_STMT = inspect.cleandoc("""
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
    result = get_results(HTTP, BASE_URL, session_handle, CREATE_STMT)
    pprint(result)

    QUREY_STMT = inspect.cleandoc("""
    SELECT order_number
           , price
           , SUBSTRING(buyer.first_name FROM 1 FOR 3) || ' ' || SUBSTRING(buyer.last_name FROM 1 FOR 4) AS buyer
           , order_time
    FROM orders
    """)
    result = get_results(HTTP, BASE_URL, session_handle, QUREY_STMT)
    pprint(result)
