FROM osrf/ros:melodic-desktop-full
ARG USER=initial
ARG GROUP=initial
ARG workspace=initial
ARG UID=1000
#FROM $base_image
RUN echo base image: ${base_image}

#######################################################################
##                            Speeding up                            ##
#######################################################################
RUN sed -i 's@archive.ubuntu.com@ftp.jaist.ac.jp/pub/Linux@g' /etc/apt/sources.list

#######################################################################
##                      install common packages                      ##
#######################################################################
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
   pkg-config \
   apt-utils \
   wget \
   curl \
   git \
   build-essential \ 
   net-tools \
   gedit \
   terminator \
   nautilus \
   software-properties-common \
   apt-transport-https \
   libopencv-dev \
   ffmpeg \
   x264 \
   libx264-dev \
   zip \
   unzip \
   usbutils \
   sudo \
   libusb-1.0-0-dev \
   dbus-x11 \
   python-rosinstall python-rosinstall-generator python-rosdep python-wstool \
   ninja-build liburdfdom-tools \
   libceres-dev libprotobuf-dev protobuf-compiler libprotoc-dev \
   python-catkin-tools

#######################################################################
##                           install font                            ##
#######################################################################
RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections 
RUN apt-get update && apt-get install -y ttf-mscorefonts-installer \
    ttf-ubuntu-font-family \
    msttcorefonts -qq

#######################################################################
##                       install nvidia docker                       ##
#######################################################################
RUN add-apt-repository ppa:kisak/turtle
RUN apt-get install -y --no-install-recommends \
    libxau-dev \
    libxdmcp-dev \
    libxcb1-dev \
    libxext-dev \
    libx11-dev \
    mesa-utils \
    x11-apps

RUN sudo apt update
RUN sudo apt upgrade -y 
RUN sudo apt install mesa-utils
# if you wouldn't update mesa, you could not activate gazebo9
#see: https://github.com/osrf/docker_images/issues/566

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

# Required for non-glvnd setups.
ENV LD_LIBRARY_PATH /usr/lib/x86_64-linux-gnu:/usr/lib/i386-linux-gnu${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}:/usr/local/nvidia/lib:/usr/local/nvidia/lib64

#######################################################################
##                   install additional packages                     ##
#######################################################################
# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

#######################################################################
##                            delete cash                            ##
#######################################################################
RUN rm -rf /var/lib/apt/lists/*

RUN echo "export PS1='\[\e[1;31;40m\]NHK2021_ILIAS\[\e[0m\] \u:\w\$ '">> /root/.bashrc
RUN echo "source /ros_setting.sh">> /root/.bashrc

#######################################################################
##                      install nhk2021 ilias                        ##
#######################################################################

COPY ./nhk2021_ilias ${workspace}/src/nhk2021_ilias
# install from git repository
RUN cd ${workspace}/src && git clone https://github.com/anhquanvgu/bno055_usb_stick.git
RUN cd ${workspace}/src && git clone https://github.com/yoshito-n-students/bno055_usb_stick_msgs.git
RUN cd ${workspace}/src && git clone -b noetic https://github.com/KeioRoboticsAssociation/wheelctrl_ros.git
RUN cd ${workspace}/src && git clone https://github.com/moden3/serial_test.git
RUN cd ${workspace}/src && git clone -b melodic-devel https://github.com/pal-robotics/realsense_gazebo_plugin.git

# install from apt repository
RUN apt update
RUN apt-get install -y ros-melodic-realsense2-description
RUN apt-get install -y ros-melodic-robot-localization
RUN apt-get install -y ros-melodic-navigation
RUN apt-get install -y ros-melodic-rplidar-ros
RUN apt-get install -y ros-melodic-roswww
RUN apt-get install -y ros-melodic-tf2-web-republisher

## install pyrealsense2
RUN apt install -y python-pip
RUN pip install pyrealsense2

WORKDIR ${workspace}
