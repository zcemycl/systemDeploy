## How to run?
1. Clone `bitnami` containers repo, and build `kafka` from scratch.
2. `docker compose up` to spin up database, kafka, redis.
3. Move to backend directory `cd backend` and install with `pip install -r requirements.txt`.
4. In `backend` directory, run fastapi server `uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload`.

## How to test GraphQL subscriptions?
1. Open a graphql window for mutation. `localhost:8000/graphql`
    ```graphql
    mutation {
        createMember(name:"Limmo",age:211){
            id
            name
            age
        }
    }
    ```
2. Open two windows for subscription.
    ```graphql
    subscription {
        memberStream {
            id,
            name,
            age
        }
    }
    ```

## How to use gRPC?
1. Define `.proto` file in `protos` directory.
2. Generate grpc files `*_pb2.py` and `*_pb2_grpc.py`.
    ```
    GRPC_DIR=./app/grpc
    python -m grpc_tools.protoc \
        -I $GRPC_DIR/protos/ \
        --python_out=$GRPC_DIR/generated \
        --grpc_python_out=$GRPC_DIR/generated/ \
        $GRPC_DIR/protos/member.proto
    ```
