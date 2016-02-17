FROM sjoerdmulder/teamcity-agent

ENV AGENT_NAME firefox_esr

# Instal firefox & xvfb
RUN apt-get update && apt-get install -y --no-install-recommends \
    xvfb \
    firefox \
    && apt-get clean autoclean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV FIREFOX_VERSION 38.6.1esr

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