FROM asos/openjdk8
MAINTAINER Louran <louran@asosgaming.com>

ARG CROWD_VERSION=2.10.1
# permissions
ARG CONTAINER_UID=1000
ARG CONTAINER_GID=1000

ENV CROWD_HOME=/var/atlassian/crowd \
    CROWD_INSTALL=/opt/crowd \
    CROWD_PROXY_NAME= \
    CROWD_PROXY_PORT= \
    CROWD_PROXY_SCHEME=

RUN export MYSQL_DRIVER_VERSION=5.1.38 && \
    export POSTGRESQL_DRIVER_VERSION=9.4.1207 && \
    export CONTAINER_USER=crowd &&  \
    export CONTAINER_GROUP=crowd &&  \
    addgroup -g $CONTAINER_GID $CONTAINER_GROUP &&  \
    adduser -u $CONTAINER_UID \
            -G $CONTAINER_GROUP \
            -h /home/$CONTAINER_USER \
            -s /bin/bash \
            -S $CONTAINER_USER &&  \
    apk add --update \
      ca-certificates \
      gzip \
      curl \
      wget &&  \
    # Install xmlstarlet
    export XMLSTARLET_VERSION=1.6.1-r1              &&  \
    wget --directory-prefix=/tmp https://github.com/menski/alpine-pkg-xmlstarlet/releases/download/${XMLSTARLET_VERSION}/xmlstarlet-${XMLSTARLET_VERSION}.apk && \
    apk add --allow-untrusted /tmp/xmlstarlet-${XMLSTARLET_VERSION}.apk && \
    wget -O /tmp/crowd.tar.gz https://www.atlassian.com/software/crowd/downloads/binary/atlassian-crowd-${CROWD_VERSION}.tar.gz && \
    tar zxf /tmp/crowd.tar.gz -C /tmp && \
    ls -A /tmp && \
    mv /tmp/atlassian-crowd-${CROWD_VERSION} /tmp/crowd && \
    ls -A /tmp && \
    mkdir -p /opt && \
    mv /tmp/crowd /opt/crowd && \
    mkdir -p ${CROWD_HOME} && \
    mkdir -p ${CROWD_INSTALL}/crowd-webapp/WEB-INF/classes && \
    mkdir -p ${CROWD_INSTALL}/apache-tomcat/lib && \
    mkdir -p ${CROWD_INSTALL}/apache-tomcat/webapps/ROOT && \
    mkdir -p ${CROWD_INSTALL}/apache-tomcat/conf/Catalina/localhost && \
    echo "crowd.home=${CROWD_HOME}" > ${CROWD_INSTALL}/crowd-webapp/WEB-INF/classes/crowd-init.properties && \
    # Install database drivers
    rm -f \
      ${CROWD_INSTALL}/apache-tomcat/lib/mysql-connector-java*.jar &&  \
    wget -O /tmp/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz \
      http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz && \
    tar xzf /tmp/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz \
      -C /tmp && \
    cp /tmp/mysql-connector-java-${MYSQL_DRIVER_VERSION}/mysql-connector-java-${MYSQL_DRIVER_VERSION}-bin.jar \
      ${CROWD_INSTALL}/apache-tomcat/lib/mysql-connector-java-${MYSQL_DRIVER_VERSION}-bin.jar  &&  \
    rm -f ${CROWD_INSTALL}/lib/postgresql-*.jar &&  \
    wget -O ${CROWD_INSTALL}/apache-tomcat/lib/postgresql-${POSTGRESQL_DRIVER_VERSION}.jar \
      https://jdbc.postgresql.org/download/postgresql-${POSTGRESQL_DRIVER_VERSION}.jar && \
    # Adjusting directories
    mv ${CROWD_INSTALL}/apache-tomcat/webapps/ROOT /opt/crowd/splash-webapp && \
    mv ${CROWD_INSTALL}/apache-tomcat/conf/Catalina/localhost /opt/crowd/webapps && \
    mkdir -p ${CROWD_INSTALL}/apache-tomcat/conf/Catalina/localhost && \
    # Adding letsencrypt-ca to truststore
    export KEYSTORE=$JAVA_HOME/jre/lib/security/cacerts && \
    wget -P /tmp/ https://letsencrypt.org/certs/letsencryptauthorityx1.der && \
    wget -P /tmp/ https://letsencrypt.org/certs/letsencryptauthorityx2.der && \
    wget -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x1-cross-signed.der && \
    wget -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x2-cross-signed.der && \
    wget -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.der && \
    wget -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x4-cross-signed.der && \
    keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias isrgrootx1 -file /tmp/letsencryptauthorityx1.der && \
    keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias isrgrootx2 -file /tmp/letsencryptauthorityx2.der && \
    keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx1 -file /tmp/lets-encrypt-x1-cross-signed.der && \
    keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx2 -file /tmp/lets-encrypt-x2-cross-signed.der && \
    keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx3 -file /tmp/lets-encrypt-x3-cross-signed.der && \
    keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx4 -file /tmp/lets-encrypt-x4-cross-signed.der && \
    # Install atlassian ssl tool
    wget -O /home/${CONTAINER_USER}/SSLPoke.class https://confluence.atlassian.com/kb/files/779355358/779355357/1/1441897666313/SSLPoke.class && \
    chown -R crowd:crowd /home/${CONTAINER_USER}
ADD splash-context.xml /opt/crowd/webapps/splash.xml
RUN chown -R crowd:crowd ${CROWD_HOME} && \
    chown -R crowd:crowd ${CROWD_INSTALL} && \
    # Install Tini Zombie Reaper And Signal Forwarder
    export TINI_VERSION=0.9.0 && \
    curl -fsSL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static -o /bin/tini && \
    chmod +x /bin/tini && \
    # Remove obsolete packages
    apk del \
      ca-certificates \
      gzip \
      curl \
      wget &&  \
    # Clean caches and tmps
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/* && \
    rm -rf /var/log/*

ENV CROWD_URL=http://localhost:8095/crowd \
    LOGIN_BASE_URL=http://localhost:8095 \
    CROWD_CONTEXT=crowd \
    CROWDID_CONTEXT=openidserver \
    OPENID_CLIENT_CONTEXT=openidclient \
    DEMO_CONTEXT=demo \
    SPLASH_CONTEXT=ROOT

USER crowd
WORKDIR /var/atlassian/crowd
VOLUME ["/var/atlassian/crowd"]
EXPOSE 8095
COPY imagescripts /home/crowd
ENTRYPOINT ["/bin/tini","--","/home/crowd/docker-entrypoint.sh"]
CMD ["crowd"]
