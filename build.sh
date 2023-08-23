#!/bin/bash -x

docker build  --tag ${USER}/nhk2021_ilias --build-arg USER=${USER} --build-arg USER_ID=`id -u` --build-arg workspace="/home/${USER}/catkin_ws" .
