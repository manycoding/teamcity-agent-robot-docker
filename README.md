Teamcity build agent with headless Robot Framework
========================
Thanks to https://github.com/sjoerdmulder, it's a bit modified https://github.com/sjoerdmulder/teamcity-agent-docker image containing necessary tools to run Robot Framework tests in headless Firefox ESR.

When starting the image as a container you must set the TEAMCITY_SERVER environment variable to point to the teamcity server e.g.
```
docker run -e TEAMCITY_SERVER=http://localhost:8111
```
Linking example
--------
```
docker run -d --name=teamcity_agent_firefoxesr --link teamcity:teamcity --privileged -e TEAMCITY_SERVER=http://localhost:8111 -e AGENT_NAME=firefox_esr manycoding/teamcity-agent-robotframework:latest
```
