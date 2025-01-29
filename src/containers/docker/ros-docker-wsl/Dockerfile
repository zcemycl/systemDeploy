FROM osrf/ros:noetic-desktop

RUN apt-get update
RUN apt-get install -y git && apt-get install -y python3-pip
RUN apt-get install -y ros-noetic-ros-control && \
    apt-get install -y ros-noetic-ros-controllers && \
    apt-get install -y ros-noetic-gazebo-ros-control && \
    apt-get install -y ros-noetic-joint-state-publisher-gui && \
    apt-get install -y ros-noetic-rqt-robot-steering

RUN mkdir -p /root/limo_ws/src && cd /root/limo_ws/src && \
    git clone https://github.com/limo-agx/limo.git && \
    git clone https://github.com/limo-agx/limo_desktop.git && \
    git clone https://github.com/limo-agx/limo_simulator.git && \ 
    cd /root/limo_ws &&\
    rosdep install --from-paths src --ignore-src -r -y

SHELL ["/bin/bash", "-c"]

RUN cd /root/limo_ws &&\
    source /opt/ros/noetic/setup.bash && \
    catkin_make && \
    echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
    