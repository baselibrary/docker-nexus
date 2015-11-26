FROM baselibrary/java:8
MAINTAINER ShawnMa <qsma@thoughtworks.com>

## Version
ENV NEXUS_MAJOR   2.0
ENV NEXUS_VERSION 2.11.4-01

## Packages
RUN \
  mkdir -p /usr/share/nexus &&\
  mkdir -p /var/lib/nexus   &&\
  curl -fsSL "http://sonatype-download.global.ssl.fastly.net/nexus/oss/nexus-${NEXUS_VERSION}-bundle.tar.gz" | tar -zxvf - --strip-components=1 -C /usr/share/nexus
## Configurations
ADD config/nexus.properties /usr/share/nexus/conf/nexus.properties
RUN \
  sed -i 's/#RUN_AS_USER=/RUN_AS_USER=root/' /usr/share/nexus/bin/nexus

## Environments
ENV PATH       /usr/share/nexus/bin:$PATH
ENV NEXUS_HOME /usr/share/nexus

EXPOSE 8081 

VOLUME ["/var/lib/nexus"]

CMD ["nexus", "console"]