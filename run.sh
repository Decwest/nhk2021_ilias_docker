#!/bin/bash

cd `dirname $0`

# xhost +
xhost +local:user
docker run -it \
    --privileged \
    --runtime=nvidia \
    --env=DISPLAY=$DISPLAY \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    -v "/home/${USER}/.Xauthority:/root/.Xauthority" \
    --env="QT_X11_NO_MITSHM=1" \
    --rm \
    -v "/$(pwd)/global_ros_setting.sh:/ros_setting.sh" \
    -v "/$(pwd)/ws_cache:/root/catkin_ws/" \
    -v "/home/${USER}/.gazebo:/root/.gazebo" \
    -v "/$(pwd)/nhk2021_ilias:/root/catkin_ws/src/nhk2021_ilias" \
    -v /etc/group:/etc/group:ro \
    -v /etc/passwd:/etc/passwd:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -v /media:/media \
    -v /dev:/dev \
    --net host \
    nhk2021_ilias
