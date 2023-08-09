#!/bin/bash
mode=$1

xhost local:root

XAUTH=/tmp/.docker.xauth
NAME=r1_turtlebot3


if [ $mode = run ]
then
    docker run -it \
        --name=$NAME \
        --env="DISPLAY=$DISPLAY" \
        --env="QT_X11_NO_MITSHM=1" \
        --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
        --env="XAUTHORITY=$XAUTH" \
        --volume="$XAUTH:$XAUTH" \
        --net=host \
        --privileged \
        ros-turtlebot-sim \
        bash
elif [ $mode = exec ]
then
    docker exec -it \
        `docker ps | grep "r1_turtlebot3" | awk '{ print $1 }'` \
        bash
fi
