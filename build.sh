#!/bin/bash -x

docker build  --tag nhk2021_ilias --build-arg workspace="/root/catkin_ws" .
