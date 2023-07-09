# START STAGE 1
FROM openjdk:8-jdk-slim as builder

USER root

ENV ANT_VERSION 1.10.12
ENV ANT_HOME /etc/ant-${ANT_VERSION}

WORKDIR /tmp

RUN apt-get update && apt-get install -y \
    git \
    curl

RUN curl -L -o apache-ant-${ANT_VERSION}-bin.tar.gz http://www.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz \
    && mkdir ant-${ANT_VERSION} \
    && tar -zxvf apache-ant-${ANT_VERSION}-bin.tar.gz \
    && mv apache-ant-${ANT_VERSION} ${ANT_HOME} \
    && rm apache-ant-${ANT_VERSION}-bin.tar.gz \
    && rm -rf ant-${ANT_VERSION} \
    && rm -rf ${ANT_HOME}/manual \
    && unset ANT_VERSION

ENV PATH ${PATH}:${ANT_HOME}/bin

# Comment in if you need nodejs and npm to build, e.g. if you want to 
# self-host the web components
# RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
#     && apt-get install -y nodejs \
#     && curl -L https://www.npmjs.com/install.sh | sh

FROM builder as tei

ARG TEMPLATING_VERSION=1.1.0
ARG PUBLISHER_LIB_VERSION=3.0.0
ARG ROUTER_VERSION=1.8.0

# replace with name of your edition repository and choose branch to build
ARG STONESUTRAS_VERSION=master

# add key
RUN  mkdir -p ~/.ssh && ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

# Replace git URL below to point to your git repository 
RUN  git clone https://github.com/StoneSutras/stonesutras7.git \
    # replace my-edition with name of your app
    && cd stonesutras7 \
    && echo Checking out ${STONESUTRAS_VERSION} \
    && git checkout ${STONESUTRAS_VERSION} \
    && ant

RUN curl -L -o /tmp/roaster-${ROUTER_VERSION}.xar http://exist-db.org/exist/apps/public-repo/public/oas-router-${ROUTER_VERSION}.xar
RUN curl -L -o /tmp/tei-publisher-lib-${PUBLISHER_LIB_VERSION}.xar http://exist-db.org/exist/apps/public-repo/public/tei-publisher-lib-${PUBLISHER_LIB_VERSION}.xar
RUN curl -L -o /tmp/templating-${TEMPLATING_VERSION}.xar http://exist-db.org/exist/apps/public-repo/public/templating-${TEMPLATING_VERSION}.xar

FROM eclipse-temurin:11-jre-alpine

ARG EXIST_VERSION=6.2.0

RUN apk add curl

RUN curl -L -o /tmp/exist-distribution-${EXIST_VERSION}-unix.tar.bz2 https://github.com/eXist-db/exist/releases/download/eXist-${EXIST_VERSION}/exist-distribution-${EXIST_VERSION}-unix.tar.bz2 \
    && tar xfj /tmp/exist-distribution-${EXIST_VERSION}-unix.tar.bz2 -C /tmp \
    && rm /tmp/exist-distribution-${EXIST_VERSION}-unix.tar.bz2 \
    && mv /tmp/exist-distribution-${EXIST_VERSION} /exist

# replace my-edition with name of your app
COPY --from=tei /tmp/stonesutras7/build/*.xar /exist/autodeploy/
COPY --from=tei /tmp/*.xar /exist/autodeploy/

WORKDIR /exist

ARG ADMIN_PASS=none

ARG HTTP_PORT=8080
ARG HTTPS_PORT=8443

ENV NER_ENDPOINT=http://localhost:8001
ENV CONTEXT_PATH=auto
ENV PROXY_CACHING=false

ENV JAVA_OPTS \
    -Djetty.port=${HTTP_PORT} \
    -Djetty.ssl.port=${HTTPS_PORT} \
    -Dfile.encoding=UTF8 \
    -Dsun.jnu.encoding=UTF-8 \
    -XX:+UseG1GC \
    -XX:+UseStringDeduplication \
    -XX:+UseContainerSupport \
    -XX:MaxRAMPercentage=${JVM_MAX_RAM_PERCENTAGE:-75.0} \ 
    -XX:+ExitOnOutOfMemoryError

# pre-populate the database by launching it once
RUN bin/client.sh -l --no-gui --xpath "system:get-version()"

RUN if [ "${ADMIN_PASS}" != "none" ]; then bin/client.sh -l --no-gui --xpath "sm:passwd('admin', '${ADMIN_PASS}')"; fi

EXPOSE ${HTTP_PORT}

ENTRYPOINT JAVA_OPTS="${JAVA_OPTS} -Dteipublisher.ner-endpoint=${NER_ENDPOINT} -Dteipublisher.context-path=${CONTEXT_PATH}" /exist/bin/startup.sh