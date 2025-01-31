#!/bin/bash
export TURTLEBOT3_MODEL=burger
source /opt/ros/noetic/setup.bash
source /catkin_ws/devel/setup.bash
roslaunch turtlebot3_gazebo turtlebot3_house.launch
