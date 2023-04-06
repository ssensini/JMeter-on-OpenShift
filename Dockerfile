FROM registry.access.redhat.com/ubi8/s2i-core

LABEL org.opencontainers.image.authors="Serena Sensini, Claudio Prato" \
      version=0.0.1 \
      description="JMeter image to test applications inside OpenShift"


ARG JMETER_VERSION="5.5"
ARG JMETER_PLUGINS_MANAGER="1.8"
ARG JMETER_CMD_RUNNER="2.3"
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV JMETER_CUSTOM_PLUGINS_FOLDER /plugins
ENV	JMETER_BIN	${JMETER_HOME}/bin
ENV	JMETER_DOWNLOAD_URL  https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz
ENV	JMETER_PLUGINS_MANAGER_URL  https://repo1.maven.org/maven2/kg/apc/jmeter-plugins-manager/${JMETER_PLUGINS_MANAGER}/jmeter-plugins-manager-${JMETER_PLUGINS_MANAGER}.jar;
ENV	JMETER_CMD_RUNNER_URL  https://repo1.maven.org/maven2/kg/apc/cmdrunner/${JMETER_CMD_RUNNER}/cmdrunner-${JMETER_CMD_RUNNER}.jar
ENV JAVA_HOME /usr

# Set TimeZone, See: https://github.com/gliderlabs/docker-alpine/issues/136#issuecomment-612751142
ARG TZ="Europe/Amsterdam"
ENV TZ ${TZ}

WORKDIR	${JMETER_HOME}

RUN yum -y install tzdata curl unzip wget bash; \
    yum -y install java-1.8.0-openjdk-devel; \
	mkdir -p /tmp/dependencies; \
	curl -L --silent ${JMETER_DOWNLOAD_URL} >  /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz; \
	mkdir -p /opt ; \
	tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt; \
    curl -L --silent ${JMETER_CMD_RUNNER_URL} > lib/cmdrunner-${JMETER_CMD_RUNNER}.jar; \
    curl -L --silent ${JMETER_PLUGINS_MANAGER_URL} > lib/ext/jmeter-add-plugins-manager-${JMETER_PLUGINS_MANAGER}.jar; \
	rm -rf /tmp/dependencies; \
    rm -rf ./docs ./printable_docs; \
    mkdir /tmp/.systemPrefs;

ENV PATH $PATH:$JMETER_BIN

COPY add-plugins/ ${JMETER_CUSTOM_PLUGINS_FOLDER}
COPY plugins-manager/ lib/

COPY entrypoint.sh ./entrypoint.sh

RUN chgrp -R 0 ${JMETER_BIN} && \
    chmod -R g=u ${JMETER_BIN} && \
    chown -R 1001:0 ${JMETER_BIN} && \
    chgrp -R 0 ${JMETER_HOME} && \
    chmod -R g=u ${JMETER_HOME} && \
    chown -R 1001:0 ${JMETER_HOME} && \
    chgrp -R 0  /tmp/.systemPrefs && \
    chmod -R g=u  /tmp/.systemPrefs && \
    chown -R 1001:0  /tmp/.systemPrefs;

USER 1001

ENTRYPOINT ["./entrypoint.sh"]
