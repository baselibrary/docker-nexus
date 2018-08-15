FROM sonatype/nexus3:3.13.0

ENV NEXUS_SSL=${NEXUS_HOME}/etc/ssl
ENV PUBLIC_CERT=${NEXUS_SSL}/cacert.pem
ENV PUBLIC_CERT_SUBJ=/CN=localhost
ENV PRIVATE_KEY=${NEXUS_SSL}/cakey.pem
ENV PRIVATE_KEY_PASSWORD=password

ARG NEXUS_VERSION=3.13.0-01
ARG NEXUS_FEATURES_FILE=/opt/sonatype/nexus/system/org/sonatype/nexus/assemblies/nexus-core-feature/${NEXUS_VERSION}/nexus-core-feature-${NEXUS_VERSION}-features.xml
ARG NEXUS_APT_VERSION=1.0.7
ARG NEXUS_APT_TARGET=/opt/sonatype/nexus/system/net/staticsnow/nexus-repository-apt/${NEXUS_APT_VERSION}/
ARG NEXUS_HELM_VERSION=0.0.1
ARG NEXUS_HELM_TARGET=/opt/sonatype/nexus/system/org/sonatype/nexus/plugins/nexus-repository-helm/${NEXUS_HELM_VERSION}/

USER root
RUN \
  mkdir -p ${NEXUS_APT_TARGET}; \
  sed -i 's@nexus-repository-maven</feature>@nexus-repository-maven</feature>\n        <feature prerequisite="false" dependency="false" version="1.0.7">nexus-repository-apt</feature>@g' ${NEXUS_FEATURES_FILE}; \
  sed -i 's@<feature name="nexus-repository-maven"@<feature name="nexus-repository-apt" description="net.staticsnow:nexus-repository-apt" version="1.0.7">\n        <details>net.staticsnow:nexus-repository-apt</details>\n        <bundle>mvn:net.staticsnow/nexus-repository-apt/1.0.7</bundle>\n        <bundle>mvn:org.apache.commons/commons-compress/1.16.1</bundle>\n        <bundle>mvn:org.tukaani/xz/1.8</bundle>\n    </feature>\n    <feature name="nexus-repository-maven"@g' ${NEXUS_FEATURES_FILE};
COPY nexus-repository-apt-${NEXUS_APT_VERSION}.jar ${NEXUS_APT_TARGET}
RUN \
  mkdir -p ${NEXUS_HELM_TARGET}; \
  sed -i 's@nexus-repository-maven</feature>@nexus-repository-maven</feature>\n        <feature prerequisite="false" dependency="false">nexus-repository-helm</feature>@g' ${NEXUS_FEATURES_FILE}; \
  sed -i 's@<feature name="nexus-repository-maven"@<feature name="nexus-repository-helm" description="org.sonatype.nexus.plugins:nexus-repository-helm" version="0.0.1">\n        <details>org.sonatype.nexus.plugins:nexus-repository-helm</details>\n        <bundle>mvn:org.sonatype.nexus.plugins/nexus-repository-helm/0.0.1</bundle>\n        <bundle>mvn:org.apache.commons/commons-compress/1.16.1</bundle>\n        <bundle>mvn:org.tukaani/xz/1.8</bundle>\n    </feature>\n    <feature name="nexus-repository-maven"@g' ${NEXUS_FEATURES_FILE};
COPY nexus-repository-helm-${NEXUS_HELM_VERSION}.jar ${NEXUS_HELM_TARGET}

RUN \
  yum -y update &&\
  yum install -y openssl libxml2 libxslt &&\
  yum clean all

RUN sed \
  -e '/^nexus-args/ s:$:,${jetty.etc}/jetty-https.xml:' \
  -e '/^application-port/a application-port-ssl=8443' \
  -i ${NEXUS_HOME}/etc/nexus-default.properties

ADD entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

EXPOSE 8443

VOLUME [ "${NEXUS_SSL}" ]

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "${NEXUS_HOME}/bin/nexus", "run"]
