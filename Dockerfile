FROM ros:melodic-robot-bionic

ENV HOME /home/developer
WORKDIR /home/developer

# Replace 1000 with your user / group id
RUN export uid=1000 gid=1000 && \
	mkdir -p /home/developer && \
	mkdir -p /etc/sudoers.d && \
	echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
	echo "developer:x:${uid}:" >> /etc/group && \
	echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
	chmod 0440 /etc/sudoers.d/developer && \
	chown ${uid}:${gid} -R /home/developer && \
	apt-get update && apt-get install -y \
	software-properties-common wget openjdk-11-jre \
	xvfb xz-utils sudo \
	git	curl libgl1-mesa-glx libgl1-mesa-dri mesa-utils unzip inetutils-ping emacs25 \
	bison flex build-essential g++ libfl-dev \
	libxrender1 libxtst6 libxi6 \
	autoconf gperf \
	tcl-dev tk-dev libgtk2.0-dev \
	ros-melodic-mavros* ros-melodic-joy ros-melodic-rosserial ros-melodic-rosserial-arduino \
	python-pip python-dev build-essential \
	python-rosinstall python-rosinstall-generator python-wstool \
	ros-melodic-rosemacs \
	&& add-apt-repository ppa:ubuntuhandbook1/apps \
	&& apt-get update \
	&& apt-get install -y avrdude avrdude-doc \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* && \
	pip install --upgrade python pip virtualenv

# Add developer user to the dialout group to be ale to write the serial USB device
RUN sed "s/^dialout.*/&developer/" /etc/group -i \
    && sed "s/^root.*/&developer/" /etc/group -i

ENV ARDUINO_IDE_VERSION 1.8.5
RUN (wget -q -O- https://downloads.arduino.cc/arduino-${ARDUINO_IDE_VERSION}-linux64.tar.xz \
	| tar xJC /usr/local/share \
	&& ln -s /usr/local/share/arduino-${ARDUINO_IDE_VERSION} /usr/local/share/arduino \
	&& ln -s /usr/local/share/arduino-${ARDUINO_IDE_VERSION}/arduino /usr/local/bin/arduino)

COPY ./ros_entrypoint.sh /ros_entrypoint.sh
RUN chmod +x /ros_entrypoint.sh

ENV DISPLAY :1.0

USER developer
