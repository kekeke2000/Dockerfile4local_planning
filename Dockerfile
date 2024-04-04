FROM osrf/ros:noetic-desktop-full

RUN cp /etc/apt/sources.list /etc/apt/sources.list.ori && \
    sed -i s@/archive.ubuntu.com/@/mirrors.ustc.edu.cn/@g /etc/apt/sources.list && \
    sed -i s@/security.ubuntu.com/@/mirrors.ustc.edu.cn/@g /etc/apt/sources.list &&\
    apt update

ENV DEBIAN_FRONTEND=noninteractive 

## Dependencies
RUN apt install -y git unzip

#  freeglut3-dev clang-format build-essential cmake \
    # xorg-dev libglu1-mesa-dev lsb-release gnupg
RUN git config --global http.proxy http://127.0.0.1:15777 && git config --global https.proxy http://127.0.0.1:15777
RUN cd / && mkdir -p catkin_ws/src && cd catkin_ws/src && \ 
    git clone https://github.com/HongbiaoZ/autonomous_exploration_development_environment.git -b noetic-rgbd-camera && \
    cd autonomous_exploration_development_environment

COPY autonomous_exploration_environments.zip /catkin_ws/src/autonomous_exploration_development_environment/src/vehicle_simulator/mesh 
RUN cd /catkin_ws/src/autonomous_exploration_development_environment/src/vehicle_simulator/mesh && unzip *.zip && rm -rf *.zip

RUN apt install -y cmake libusb-dev python3-tk
RUN /bin/bash -c 'source /opt/ros/noetic/setup.bash; cd /catkin_ws; catkin_make'

RUN sed -i '/exec "$@"/i \
            source "/catkin_ws/devel/setup.bash"' /ros_entrypoint.sh
ENTRYPOINT ["./ros_entrypoint.sh"]