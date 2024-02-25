#!/bin/bash
bucket=leo-trial-batch

s3fs ${bucket} /data -o ecs \
    -o url=https://s3.eu-west-2.amazonaws.com \
    -o endpoint=eu-west-2 \
    -o uid=1000,gid=1000,umask=0007,mp_umask=0007 \
    -o enable_content_md5 \
    -o dbglevel="debug" \
    -f

# unmount -u /data
# s3fs -o ecs leo-trial-batch /data
sleep 30

echo "Mounted ${bucket} to /data"

# ls /data/**/*
ls /data

exec "$@"
