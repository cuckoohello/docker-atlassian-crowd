ARG BASE_IMAGE=adoptopenjdk/openjdk8:slim
FROM $BASE_IMAGE

ENV RUN_USER                                        crowd
ENV RUN_GROUP                                       crowd
ENV RUN_UID                                         2000
ENV RUN_GID                                         2000

# https://confluence.atlassian.com/crowd/important-directories-and-files-78676537.html
ENV CROWD_HOME                                       /var/atlassian/application-data/crowd
ENV CROWD_INSTALL_DIR                                /opt/atlassian/crowd

WORKDIR $CROWD_HOME

# Expose HTTP port
EXPOSE 8095

CMD ["/entrypoint.py"]
ENTRYPOINT ["/tini", "--"]

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends fontconfig python3 python3-jinja2 \
    && apt-get clean autoclean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

ARG TINI_VERSION=v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

ARG CROWD_VERSION
ARG ARTEFACT_NAME=atlassian-crowd
ARG DOWNLOAD_URL=https://product-downloads.atlassian.com/software/crowd/downloads/${ARTEFACT_NAME}-${CROWD_VERSION}.tar.gz

RUN groupadd --gid ${RUN_GID} ${RUN_GROUP} \
    && useradd --uid ${RUN_UID} --gid ${RUN_GID} --home-dir ${CROWD_HOME} --shell /bin/bash ${RUN_USER} \
    && echo PATH=$PATH > /etc/environment \
    \
    && mkdir -p                                     ${CROWD_INSTALL_DIR} \
    && curl -L --silent                             ${DOWNLOAD_URL} | tar -xz --strip-components=1 -C "${CROWD_INSTALL_DIR}" \
    && chmod -R "u=rwX,g=rX,o=rX"                   ${CROWD_INSTALL_DIR}/ \
    && chown -R root.                               ${CROWD_INSTALL_DIR}/ \
    && chown -R ${RUN_USER}:${RUN_GROUP}            ${CROWD_INSTALL_DIR}/apache-tomcat/logs \
    && chown -R ${RUN_USER}:${RUN_GROUP}            ${CROWD_INSTALL_DIR}/apache-tomcat/temp \
    && chown -R ${RUN_USER}:${RUN_GROUP}            ${CROWD_INSTALL_DIR}/apache-tomcat/work \
    && chown -R ${RUN_USER}:${RUN_GROUP}            ${CROWD_HOME}

VOLUME ["${CROWD_HOME}"] # Must be declared after setting perms

COPY entrypoint.py \
     shared-components/image/entrypoint_helpers.py  /
COPY shared-components/support                      /opt/atlassian/support
COPY config/*                                       /opt/atlassian/etc/
