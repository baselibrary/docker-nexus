FROM sonatype/nexus3:3.14.0

ENV NEXUS_CERT=${NEXUS_HOME}/etc/ssl
ENV NEXUS_CERT_CN=localhost
ENV NEXUS_CERT_PASSWORD=password

ARG NEXUS_VERSION=3.14.0-04
ARG NEXUS_FEATURES_FILE=/opt/sonatype/nexus/system/org/sonatype/nexus/assemblies/nexus-core-feature/${NEXUS_VERSION}/nexus-core-feature-${NEXUS_VERSION}-features.xml
ARG NEXUS_APT_VERSION=1.0.7
ARG NEXUS_APT_TARGET=/opt/sonatype/nexus/system/net/staticsnow/nexus-repository-apt/${NEXUS_APT_VERSION}/
ARG NEXUS_HELM_VERSION=0.0.7
ARG NEXUS_HELM_TARGET=/opt/sonatype/nexus/system/org/sonatype/nexus/plugins/nexus-repository-helm/${NEXUS_HELM_VERSION}/
ARG NEXUS_COMP_VERSION=1.18
ARG NEXUS_XZ_VERSION=1.8

USER root
RUN \
  mkdir -p ${NEXUS_APT_TARGET}; \
  sed -i 's@nexus-repository-maven</feature>@nexus-repository-maven</feature>\n        <feature prerequisite="false" dependency="false" version="${NEXUS_APT_VERSION}">nexus-repository-apt</feature>@g' ${NEXUS_FEATURES_FILE}; \
  sed -i 's@<feature name="nexus-repository-maven"@<feature name="nexus-repository-apt" description="net.staticsnow:nexus-repository-apt" version="${NEXUS_APT_VERSION}">\n        <details>net.staticsnow:nexus-repository-apt</details>\n        <bundle>mvn:net.staticsnow/nexus-repository-apt/${NEXUS_APT_VERSION}</bundle>\n        <bundle>mvn:org.apache.commons/commons-compress/${NEXUS_COMP_VERSION}</bundle>\n        <bundle>mvn:org.tukaani/xz/${NEXUS_XZ_VERSION}</bundle>\n    </feature>\n    <feature name="nexus-repository-maven"@g' ${NEXUS_FEATURES_FILE};
COPY nexus-repository-apt-${NEXUS_APT_VERSION}.jar ${NEXUS_APT_TARGET}
RUN \
  mkdir -p ${NEXUS_HELM_TARGET}; \
  sed -i 's@nexus-repository-maven</feature>@nexus-repository-maven</feature>\n        <feature prerequisite="false" dependency="false">nexus-repository-helm</feature>@g' ${NEXUS_FEATURES_FILE}; \
  sed -i 's@<feature name="nexus-repository-maven"@<feature name="nexus-repository-helm" description="org.sonatype.nexus.plugins:nexus-repository-helm" version="${NEXUS_HELM_VERSION}">\n        <details>org.sonatype.nexus.plugins:nexus-repository-helm</details>\n        <bundle>mvn:org.sonatype.nexus.plugins/nexus-repository-helm/${NEXUS_HELM_VERSION}</bundle>\n        <bundle>mvn:org.apache.commons/commons-compress/${NEXUS_COMP_VERSION}</bundle>\n        <bundle>mvn:org.tukaani/xz/1.8</bundle>\n    </feature>\n    <feature name="nexus-repository-maven"@g' ${NEXUS_FEATURES_FILE};
COPY nexus-repository-helm-${NEXUS_HELM_VERSION}.jar ${NEXUS_HELM_TARGET}



RUN sed \
  -e '/^nexus-args/ s:$:,${jetty.etc}/jetty-https.xml:' \
  -e '/^application-port/a application-port-ssl=8443' \
  -i ${NEXUS_HOME}/etc/nexus-default.properties

ADD entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

EXPOSE 8443

VOLUME [ "${NEXUS_CERT}" ]

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "/opt/sonatype/nexus/bin/nexus", "run"]
