FROM baselibrary/java:8
MAINTAINER ShawnMa <qsma@thoughtworks.com>

## Version
ENV NEXUS_MAJOR   3.0
ENV NEXUS_VERSION 3.0.0-b2015110601

## Packages
RUN \
  mkdir -p /usr/share/nexus &&\
  mkdir -p /var/lib/nexus   &&\
  curl -fsSL "http://sonatype-download.global.ssl.fastly.net/nexus/oss/nexus-${NEXUS_VERSION}-bundle.tar.gz" | tar -zxvf - --strip-components=1 -C /usr/share/nexus

## Environments
ENV PATH       /usr/share/nexus/bin:$PATH
ENV KARAF_HOME /usr/share/nexus
ENV KARAF_DATA /var/lib/nexus

EXPOSE 5000 8081 

VOLUME ["/var/lib/nexus"]

CMD ["nexus", "server"]