FROM baselibrary/java:8
MAINTAINER ShawnMa <qsma@thoughtworks.com>

## Version
ENV NEXUS_MAJOR   3.0
ENV NEXUS_VERSION 3.2.0-01

## Packages
RUN \
  mkdir -p /usr/share/nexus &&\
  mkdir -p /var/lib/nexus   &&\
  curl -fsSL "http://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz" | tar -zxvf - --strip-components=1 -C /usr/share/nexus

## Environments
ENV PATH /usr/share/nexus/bin:$PATH

EXPOSE 8081

VOLUME ["/usr/share/nexus/data"]

CMD ["nexus", "run"]
