FROM ubuntu:14.04

ENV AGENT_DIR /opt/buildAgent
ENV AGENT_NAME firefox_esr

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		lxc iptables aufs-tools ca-certificates curl wget software-properties-common language-pack-en \
	&& rm -rf /var/lib/apt/lists/*

# Fix locale
ENV LANG en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
RUN locale-gen en_US && update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8

# Grab gosu for easy step-down from root
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.6/gosu-$(dpkg --print-architecture)" \
	&& curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.6/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu

# Install java-8-oracle
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
	&& echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections \
	&& add-apt-repository -y ppa:webupd8team/java \
	&& apt-get update \
  	&& apt-get install -y --no-install-recommends \
      oracle-java8-installer ca-certificates-java \
  	&& rm -rf /var/lib/apt/lists/* /var/cache/oracle-jdk8-installer/*.tar.gz /usr/lib/jvm/java-8-oracle/src.zip /usr/lib/jvm/java-8-oracle/javafx-src.zip \
      /usr/lib/jvm/java-8-oracle/jre/lib/security/cacerts \
  	&& ln -s /etc/ssl/certs/java/cacerts /usr/lib/jvm/java-8-oracle/jre/lib/security/cacerts \
  	&& update-ca-certificates

# Install docker
RUN wget -O /usr/local/bin/docker https://get.docker.com/builds/Linux/x86_64/docker-1.9.1 && chmod +x /usr/local/bin/docker

RUN groupadd docker && adduser --disabled-password --gecos "" teamcity \
	&& sed -i -e "s/%sudo.*$/%sudo ALL=(ALL:ALL) NOPASSWD:ALL/" /etc/sudoers \
	&& usermod -a -G docker,sudo teamcity

# Install ruby and node.js build repositories
RUN apt-add-repository ppa:chris-lea/node.js \
	&& apt-add-repository ppa:brightbox/ruby-ng \
	&& apt-get update \
    && apt-get upgrade -y \
	&& apt-get install -y nodejs ruby2.1 ruby2.1-dev ruby ruby-switch unzip \
	iptables lxc fontconfig libffi-dev build-essential git jq python-dev libssl-dev python-pip \
	&& rm -rf /var/lib/apt/lists/*

# Install httpie (with SNI), awscli, docker-compose
RUN pip install --upgrade pyopenssl pyasn1 ndg-httpsclient httpie awscli docker-compose==1.5.1
RUN ruby-switch --set ruby2.1
RUN npm install -g bower grunt-cli
RUN gem install rake bundler compass --no-ri --no-rdoc

# Install the magic wrapper.
ADD wrapdocker /usr/local/bin/wrapdocker

# Instal firefox & xvfb
RUN apt-get update && apt-get install -y --no-install-recommends \
    xvfb \
    firefox \
    && apt-get clean autoclean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV FIREFOX_VERSION 38.4.0esr

WORKDIR /tmp
RUN curl -sSL "https://ftp.mozilla.org/pub/mozilla.org/firefox/releases/${FIREFOX_VERSION}/linux-x86_64/en-US/firefox-${FIREFOX_VERSION}.tar.bz2" | tar -xj \
    && mv /usr/bin/firefox /usr/bin/firefox_prev \
    && ln -s /tmp/firefox/firefox /usr/bin/firefox 

# Install pip and robot libraries
COPY requirements.txt /tmp/
RUN pip install -Ur /tmp/requirements.txt \
    && rm /tmp/requirements.txt
WORKDIR /robot

ADD docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

VOLUME /var/lib/docker
VOLUME /opt/buildAgent

EXPOSE 9090