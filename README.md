Teamcity build agent with headless Robot Framework
========================
Thanks to https://github.com/sjoerdmulder, it's a bit modified https://github.com/sjoerdmulder/teamcity-agent-docker image containing necessary tools to run Robot Framework tests in headless Firefox ESR.

When starting the image as a container you must set the TEAMCITY_SERVER environment variable to point to the teamcity server e.g.
```
docker run -e TEAMCITY_SERVER=http://localhost:8111
```

Optionally you can specify your own address using the `TEAMCITY_OWN_ADDRESS` variable.

Linking example
--------
```
docker run -d --name=teamcity-agent-1 --link teamcity:teamcity_alias --privileged -e TEAMCITY_SERVER=http://teamcity:8111 manycoding/teamcity-agent-robotframework:latest
```
