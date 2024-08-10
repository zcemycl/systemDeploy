#!/bin/bash
export TURTLEBOT3_MODEL=burger
source /opt/ros/noetic/setup.bash
source /catkin_ws/devel/setup.bash
roslaunch turtlebot3_slam turtlebot3_slam.launch slam_methods:=gmapping
