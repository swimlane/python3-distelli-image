FROM ubuntu:16.04

USER root
RUN useradd -ms /bin/bash distelli

WORKDIR /home/distelli

RUN apt-get update -y \
    && apt-get -y install build-essential checkinstall git mercurial sudo curl software-properties-common \
    && apt-get -y install libssl-dev openssh-client openssh-server \
    && apt-get -y install apt-transport-https ca-certificates zip lsb-release

ENV CHROME_BIN /usr/bin/google-chrome

# Install docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    && echo 'deb https://apt.dockerproject.org/repo ubuntu-xenial main' > /etc/apt/sources.list.d/docker.list \
    && apt-get update -y \
    && apt-get purge -y lxc-docker \
    && apt-get -y install docker-ce \
    && docker -v \
    && mkdir -p /etc/ssh 

RUN ssh-keyscan -H github.com bitbucket.org >> /etc/ssh/ssh_known_hosts

# Setup a volume for writing docker layers/images
VOLUME /var/lib/docker

# Install gosu
ENV GOSU_VERSION 1.9
RUN curl -o /bin/gosu -sSL "https://github.com/tianon/gosu/releases/download/1.9/gosu-$(dpkg --print-architecture)" \
     && sudo chmod +x /bin/gosu

# Install Python3.5
RUN apt-get -y install software-properties-common \
    python-software-properties
RUN add-apt-repository ppa:fkrull/deadsnakes \
    && apt-get update -y \
    && apt-get -y install python3.5 python3.5-dev
RUN wget https://bootstrap.pypa.io/get-pip.py \
    && python3.5 get-pip.py

RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo 'deb http://dl.google.com/linux/chrome/deb/ stable main' >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && echo "CHROME_BIN=/usr/bin/google-chrome" >> /etc/environment
    #&& apt-get install --no-install-recommends -y google-chrome-stable

# Install Distelli CLI to coordinate the build in the container
RUN curl -sSL https://www.distelli.com/download/client | sh

# Install node version manager as distelli user
USER distelli
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash

# Ensure the final USER statement is "USER root"
USER root

RUN sudo sh -c "echo 'Distelli Python3 Build Image maintained by Brant Wheeler <brant.wheeler@swimlane.com> and Brian Kosick <brian.kosick@swimlane.com>' >> /distelli_build_image.info"

CMD ["/bin/bash"]
