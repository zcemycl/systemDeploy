FROM osrf/ros:noetic-desktop-full
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install wget git python3-pip python3-catkin-tools -y
RUN apt-get install ros-noetic-joy ros-noetic-control-toolbox \
    ros-noetic-robot-controllers ros-noetic-gazebo-ros \
    ros-noetic-gazebo-plugins ros-noetic-rgbd-launch -y
WORKDIR /
RUN mkdir -p catkin_ws/src/
WORKDIR /catkin_ws/src/
RUN git clone https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git
RUN git clone -b noetic-devel https://github.com/ROBOTIS-GIT/turtlebot3.git
RUN git clone https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git
RUN echo "export TURTLEBOT3_MODEL=burger" > ~/.bashrc
RUN echo "source /opt/ros/noetic/setup.bash" > ~/.bashrc
RUN echo "source /catkin_ws/devel/setup.bash" > ~/.bashrc
RUN pip install rospkg
RUN /bin/bash -c 'source /opt/ros/noetic/setup.bash; \
    cd /catkin_ws/; catkin_make; source /catkin_ws/devel/setup.bash'
WORKDIR /
