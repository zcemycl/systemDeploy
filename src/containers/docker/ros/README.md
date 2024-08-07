```
# terminal 1
./run_docker.sh run
roscore
# terminal 2
./run_docker.sh exec
export TURTLEBOT3_MODEL=burger
roslaunch turtlebot3_gazebo turtlebot3_empty_world.launch # initialize the gazebo world
# terminal 3
./run_docker.sh exec
export TURTLEBOT3_MODEL=burger
roslaunch turtlebot3_teleop turtlebot3_teleop_key.launch
```

## References

1. https://foxglove.dev/blog/installing-ros1-on-macos-with-docker
2. https://foxglove.dev/blog/installing-ros2-on-macos-with-docker
