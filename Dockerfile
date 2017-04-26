FROM ubuntu:14.04

USER root
RUN useradd -ms /bin/bash distelli

WORKDIR /home/distelli

RUN sudo apt-get update -y \
    && sudo apt-get -y install build-essential checkinstall git mercurial \
    && sudo apt-get -y install libssl-dev openssh-client openssh-server \
    && sudo apt-get -y install curl apt-transport-https ca-certificates chromium-browser

RUN sudo sh -c "ssh-keyscan -H github.com bitbucket.org >> /etc/ssh/ssh_known_hosts"

# Install Distelli CLI to coordinate the build in the container
RUN curl -sSL https://www.distelli.com/download/client | sh

# Install docker
RUN sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D \
    && sudo sh -c "echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' > /etc/apt/sources.list.d/docker.list" \
    && sudo apt-get update -y \
    && sudo apt-get purge -y lxc-docker \
    && sudo apt-get -y install docker-engine \
    && sudo sh -c 'curl -L https://github.com/docker/compose/releases/download/1.6.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose' \
    && sudo chmod +x /usr/local/bin/docker-compose \
    && sudo docker -v

# Setup a volume for writing docker layers/images
VOLUME /var/lib/docker

# Install gosu
ENV GOSU_VERSION 1.9
RUN sudo curl -o /bin/gosu -sSL "https://github.com/tianon/gosu/releases/download/1.9/gosu-$(dpkg --print-architecture)" \
     && sudo chmod +x /bin/gosu

# Install Python3.5
RUN sudo apt-get -y install software-properties-common \
    python-software-properties
RUN sudo add-apt-repository ppa:fkrull/deadsnakes \
    && sudo apt-get update -y \
    && sudo apt-get -y install python3.5 python3.5-dev
RUN wget https://bootstrap.pypa.io/get-pip.py \
    && sudo python3.5 get-pip.py

# Install node version manager as distelli user
USER distelli
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash

# Ensure the final USER statement is "USER root"
USER root

RUN sudo sh -c "echo 'Distelli Python3 Build Image maintained by Brant Wheeler brant.wheeler@swimlane.com' >> /distelli_build_image.info"

CMD ["/bin/bash"]
