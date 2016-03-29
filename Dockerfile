FROM sjoerdmulder/teamcity-agent

ENV AGENT_NAME firefox_esr

# Instal firefox & xvfb
RUN apt-get update && apt-get install -y --no-install-recommends \
    xvfb \
    xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic \
    firefox \
    && apt-get clean autoclean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /tmp
RUN wget "https://download.mozilla.org/?product=firefox-esr-latest&os=linux64&lang=en-US" -O - | tar -xj \
    && mv /usr/bin/firefox /usr/bin/firefox_prev \
    && ln -s /tmp/firefox/firefox /usr/bin/firefox

# Install pip and robot libraries
COPY requirements.txt /tmp/
RUN pip install -Ur /tmp/requirements.txt \
    && rm /tmp/requirements.txt
WORKDIR /robot

ADD docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]