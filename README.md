# Dockerized Atlassian Crowd

[![Docker Stars](https://img.shields.io/docker/stars/asos/crowd.svg)](https://hub.docker.com/r/asos/crowd/) [![Docker Pulls](https://img.shields.io/docker/pulls/asos/crowd.svg)](https://hub.docker.com/r/asos/crowd/)

"Users can come from anywhere: Active Directory, LDAP, Crowd itself, or any mix thereof. Control permissions to all your applications in one place – Atlassian, Subversion, Google Apps, or your own apps." - [[Source](https://www.atlassian.com/software/crowd/overview)]

## Related Images

You may also like:

* [jira](https://github.com/asosgaming/jira): The #1 software development tool used by agile teams
* [confluence](https://github.com/asosgaming/confluence): Create, organize, and discuss work with your team
* [bitbucket](https://github.com/asosgaming/bitbucket): Code, Manage, Collaborate
* [crowd](https://github.com/asosgaming/crowd): Identity management for web apps

# Make It Short

Docker-Compose:

~~~~
$ curl -O https://raw.githubusercontent.com/asosgaming/crowd/master/docker-compose.yml
$ docker-compose up -d
~~~~

> Crowd will be available at http://yourdockerhost:8095


# Disabling The Splash Context

Set the Splash Screens context to empty string and crowd to root context.

~~~~
$ docker run -d --name crowd \
    -e "CROWD_URL=http://localhost:8095" \
	  -e "SPLASH_CONTEXT=" \
    -e "CROWD_CONTEXT=ROOT" \
	  -p 8095:8095 asos/crowd
~~~~

> Splash context will never be shown, crowd will be shown under http://youdockerhost:8095/

# Disabling OpenID & Demo Contexts

Disable all contexts to make sub application inaccessible (e.g. you do not use them)

You can disable applications by setting their context to empty string:

* Crowd: CROWD_CONTEXT
* Splash: SPLASH_CONTEXT
* OpenID server: CROWDID_CONTEXT
* OpenID client: OPENID_CLIENT_CONTEXT

Example:

~~~~
$ docker run -d --name crowd \
    -e "CROWD_URL=http://localhost:8095" \
    -e "SPLASH_CONTEXT=" \
    -e "CROWD_CONTEXT=ROOT" \
    -e "CROWDID_CONTEXT=" \
    -e "OPENID_CLIENT_CONTEXT=" \
	  -p 8095:8095 asos/crowd
~~~~

> Subapplications will not be accessible anymore. Crowd will run under root context under http://youdockerhost:8095/

# Proxy Configuration

You can specify your proxy host and proxy port with the environment variables CROWD_PROXY_NAME and CROWD_PROXY_PORT. The value will be set inside the Atlassian server.xml at startup!

When you use https then you also have to include the environment variable CROWD_PROXY_SCHEME.

Example HTTPS:

* Proxy Name: myhost.example.com
* Proxy Port: 443
* Poxy Protocol Scheme: https

Just type:

~~~~
$ docker run -d --name crowd \
    -e "CROWD_PROXY_NAME=myhost.example.com" \
    -e "CROWD_PROXY_PORT=443" \
    -e "CROWD_PROXY_SCHEME=https" \
    asos/crowd
~~~~

> Will set the values inside the server.xml in /opt/crowd/.../server.xml

# NGINX HTTP Proxy

This is an example on running Atlassian Crowd behind NGINX with 2 Docker commands!

First start Crowd:

~~~~
$ docker run -d --name crowd \
    -e "CROWD_PROXY_NAME=192.168.99.100" \
    -e "CROWD_PROXY_PORT=80" \
    -e "CROWD_PROXY_SCHEME=http" \
    asos/crowd
~~~~

> Example with dockertools

Then start NGINX:

~~~~
$ docker run -d \
    -p 80:80 \
    --name nginx \
    --link crowd:crowd \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://crowd:8095" \
    asos/nginx
~~~~

> Crowd will be available at http://192.168.99.100.

# NGINX HTTPS Proxy

This is an example on running Atlassian Crowd behind NGINX-HTTPS with2 Docker commands!

Note: This is a self-signed certificate! Trusted certificates by letsencrypt are supported. Documentation can be found here: [asosgaming/nginx](https://github.com/asosgaming/nginx)

First start Crowd:

~~~~
$ docker run -d --name crowd \
    -e "CROWD_PROXY_NAME=192.168.99.100" \
    -e "CROWD_PROXY_PORT=80" \
    -e "CROWD_PROXY_SCHEME=http" \
    asos/crowd
~~~~

> Example with dockertools

Then start NGINX:

~~~~
$ docker run -d \
    -p 443:443 \
    --name nginx \
    --link crowd:crowd \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://crowd:8095" \
    -e "SERVER1CERTIFICATE_DNAME=/CN=CrustyClown/OU=SpringfieldEntertainment/O=crusty.springfield.com/L=Springfield/C=US" \
    -e "SERVER1HTTPS_ENABLED=true" \
    -e "SERVER1HTTP_ENABLED=false" \
    asos/nginx
~~~~

> Crowd will be available at https://192.168.99.100.

# More In-Depth Features

The full feature list is documented here as this image is feature identical with the atlassian example: [Readme.md](https://bitbucket.org/atlassianlabs/atlassian-docker/src/ee4a3434b1443ed4d9cfbf721ba7d4556da8c005/crowd/?at=master)

# Support & Feature Requests

Leave a message and ask questions on Hipchat: [asosgaming/hipchat](https://www.hipchat.com/geogBFvEM)

# Credits

This project is very grateful for code and examples from the repositories:

* [atlassianlabs/atlassian-docker](https://bitbucket.org/atlassianlabs/atlassian-docker)

# References

* [Atlassian Crowd](https://www.atlassian.com/software/crowd/overview/)
* [Docker Homepage](https://www.docker.com/)
* [Docker Compose](https://docs.docker.com/compose/)
* [Docker Userguide](https://docs.docker.com/userguide/)
* [Oracle Java](https://java.com/de/download/)
