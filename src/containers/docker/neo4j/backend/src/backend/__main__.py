import os

from loguru import logger
from neo4j import GraphDatabase

HOSTNAME = os.getenv("HOSTNAME", "localhost")
logger.info(HOSTNAME)

URI = f"neo4j://{HOSTNAME}:7687"
AUTH = ("neo4j", "password")

with GraphDatabase.driver(URI, auth=AUTH) as driver:
    logger.info(driver.verify_connectivity())
    create_cmds = [
        "CREATE CONSTRAINT products IF NOT EXISTS FOR (p:Product) REQUIRE p.name IS UNIQUE",
        "CREATE CONSTRAINT keywords IF NOT EXISTS FOR (k:Keyword) REQUIRE k.name IS UNIQUE",
        "CREATE CONSTRAINT dosage_forms IF NOT EXISTS FOR (d:Dosage_Form) REQUIRE d.name IS UNIQUE",
        "CREATE CONSTRAINT moieties IF NOT EXISTS FOR (m:Moiety) REQUIRE m.name IS UNIQUE"
    ]
    query = '''
        UNWIND $rows AS row
        MERGE (p:Product {name: row})
        RETURN row
    '''
    print(driver.verify_connectivity())
    with driver.session(database="neo4j") as session:
        for cmd in create_cmds:
            resp = list(session.run(cmd, None))
            print(resp)

        resp = list(session.run(query, parameters={'rows': ["d"]}))

    query = '''
        UNWIND $row.table_keywords AS keyword
        MERGE (k:Keyword {name: keyword})

        WITH k
        MATCH (p:Product {name: $row.product})
        MERGE (p)-[:CONTAINS]->(k)
        RETURN k.name AS name
    '''
    with driver.session(database="neo4j") as session:
        for record in [
            {
                "table_keywords": ["a", "c", "b"],
                "product": "d",
            }
        ]:
            resp = list(session.run(query, parameters={'row': record}))
